#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// =========================
// BLE UUIDs - GIỮ NGUYÊN
// =========================
#define SERVICE_UUID         "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID  "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// =========================
// TOUCH CONFIG
// =========================
// Chọn 1 chân touch hợp lệ trên ESP32-S3 board của anh.
// Ví dụ đang để GPIO4. Nếu board của anh không có touch ở GPIO4 thì đổi lại.
static const uint8_t TOUCH_PIN = 4;

// Số mẫu lấy để hiệu chuẩn baseline lúc khởi động / khi gọi lệnh cal
static const uint16_t TOUCH_CAL_SAMPLES = 64;
static const uint16_t TOUCH_CAL_DELAY_MS = 8;

// Chu kỳ giám sát touch
static const uint16_t TOUCH_POLL_MS = 10;   // ~100 Hz, phản hồi rất nhanh

// Hysteresis để tránh rung trạng thái
// ESP32-S3 thường dùng ngưỡng "touched khi giá trị tăng vượt threshold".
// Có thể phải tinh chỉnh 2 thông số này theo miếng đồng / dây đồng / kích thước pad thực tế.
static float TOUCH_ENTER_PERCENT   = 0.08f; // vào trạng thái touched khi > baseline + 8%
static float TOUCH_RELEASE_PERCENT = 0.04f; // nhả khi < baseline + 4%

// Ngưỡng tối thiểu cộng thêm để tránh baseline quá nhỏ
static const uint32_t TOUCH_MIN_ENTER_DELTA   = 200;
static const uint32_t TOUCH_MIN_RELEASE_DELTA = 100;

// =========================
// BLE OBJECTS
// =========================
BLEServer *pServer = nullptr;
BLECharacteristic *pCharacteristic = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;
volatile bool needNotifyOnConnect = false;

// =========================
// TOUCH STATE
// =========================
uint32_t touchBaseline = 0;
uint32_t touchEnterThreshold = 0;
uint32_t touchReleaseThreshold = 0;
uint32_t touchRaw = 0;

bool touchState = false;       // false = không chạm da, true = có chạm da
bool manualOverride = false;   // true = đang ép trạng thái bằng lệnh test
bool manualState = false;      // trạng thái ép khi test

unsigned long lastTouchPollMs = 0;
String serialBuffer;

// =========================
// UTILS
// =========================
const char* boolText(bool v) {
  return v ? "true" : "false";
}

void updateThresholds() {
  uint32_t enterDelta =
      max((uint32_t)(touchBaseline * TOUCH_ENTER_PERCENT), TOUCH_MIN_ENTER_DELTA);
  uint32_t releaseDelta =
      max((uint32_t)(touchBaseline * TOUCH_RELEASE_PERCENT), TOUCH_MIN_RELEASE_DELTA);

  touchEnterThreshold = touchBaseline + enterDelta;
  touchReleaseThreshold = touchBaseline + releaseDelta;
}

uint32_t calibrateTouchBaseline() {
  uint64_t sum = 0;
  for (uint16_t i = 0; i < TOUCH_CAL_SAMPLES; i++) {
    sum += touchRead(TOUCH_PIN);
    delay(TOUCH_CAL_DELAY_MS);
  }
  return (uint32_t)(sum / TOUCH_CAL_SAMPLES);
}

void printTouchConfig() {
  Serial.println("========== TOUCH CONFIG ==========");
  Serial.printf("TOUCH_PIN            : %u\n", TOUCH_PIN);
  Serial.printf("Baseline             : %lu\n", (unsigned long)touchBaseline);
  Serial.printf("Enter threshold      : %lu\n", (unsigned long)touchEnterThreshold);
  Serial.printf("Release threshold    : %lu\n", (unsigned long)touchReleaseThreshold);
  Serial.printf("Enter %%              : %.2f\n", TOUCH_ENTER_PERCENT * 100.0f);
  Serial.printf("Release %%            : %.2f\n", TOUCH_RELEASE_PERCENT * 100.0f);
  Serial.println("==================================");
}

void syncCharacteristicValue() {
  pCharacteristic->setValue(boolText(touchState));
}

void notifyPhone(const char* source) {
  syncCharacteristicValue();

  Serial.printf("[SEND][%s] state=%s, raw=%lu, baseline=%lu, enter=%lu, release=%lu, mode=%s\n",
                source,
                boolText(touchState),
                (unsigned long)touchRaw,
                (unsigned long)touchBaseline,
                (unsigned long)touchEnterThreshold,
                (unsigned long)touchReleaseThreshold,
                manualOverride ? "MANUAL" : "AUTO");

  if (deviceConnected) {
    pCharacteristic->notify();
  }
}

void setLogicalState(bool newState, bool forceNotify, const char* source) {
  bool changed = (touchState != newState);
  touchState = newState;
  syncCharacteristicValue();

  if (changed || forceNotify) {
    notifyPhone(source);
  }
}

bool evaluateTouchState(uint32_t rawValue, bool currentState) {
  // Hysteresis:
  // - nếu đang false, chỉ chuyển sang true khi vượt enterThreshold
  // - nếu đang true, chỉ nhả về false khi xuống dưới releaseThreshold
  if (!currentState && rawValue >= touchEnterThreshold) {
    return true;
  }
  if (currentState && rawValue <= touchReleaseThreshold) {
    return false;
  }
  return currentState;
}

void recalibrateTouch() {
  Serial.println("[CAL] Keep touch pad untouched. Calibrating...");
  delay(300);
  touchBaseline = calibrateTouchBaseline();
  updateThresholds();
  touchRaw = touchRead(TOUCH_PIN);
  printTouchConfig();
}

// =========================
// COMMAND HANDLER
// =========================
void handleCommand(String cmd, const char* source) {
  cmd.trim();
  if (cmd.length() == 0) return;

  Serial.printf("[CMD][%s] %s\n", source, cmd.c_str());

  if (cmd.equalsIgnoreCase("get")) {
    notifyPhone(source);
    return;
  }

  if (cmd.equalsIgnoreCase("1:true") || cmd.equalsIgnoreCase("true") || cmd == "1") {
    manualOverride = true;
    manualState = true;
    setLogicalState(manualState, true, source);
    return;
  }

  if (cmd.equalsIgnoreCase("0:false") || cmd.equalsIgnoreCase("false") || cmd == "0") {
    manualOverride = true;
    manualState = false;
    setLogicalState(manualState, true, source);
    return;
  }

  if (cmd.equalsIgnoreCase("auto")) {
    manualOverride = false;
    touchRaw = touchRead(TOUCH_PIN);
    bool sensed = evaluateTouchState(touchRaw, touchState);
    setLogicalState(sensed, true, source);
    return;
  }

  if (cmd.equalsIgnoreCase("cal")) {
    manualOverride = false;
    recalibrateTouch();
    bool sensed = evaluateTouchState(touchRaw, false);
    setLogicalState(sensed, true, source);
    return;
  }

  // Tùy chọn: chỉnh threshold theo % khi đang chạy
  // Ví dụ: pct:10,5  => enter=10%, release=5%
  if (cmd.startsWith("pct:")) {
    int comma = cmd.indexOf(',');
    if (comma > 4) {
      float enterPct = cmd.substring(4, comma).toFloat();
      float releasePct = cmd.substring(comma + 1).toFloat();

      if (enterPct > 0 && releasePct > 0 && enterPct > releasePct) {
        TOUCH_ENTER_PERCENT = enterPct / 100.0f;
        TOUCH_RELEASE_PERCENT = releasePct / 100.0f;
        updateThresholds();
        printTouchConfig();
        notifyPhone(source);
        return;
      }
    }
    Serial.println("[ERR] Use: pct:10,5");
    return;
  }

  Serial.println("[ERR] Unknown command. Use one of:");
  Serial.println("      get");
  Serial.println("      1:true");
  Serial.println("      0:false");
  Serial.println("      auto");
  Serial.println("      cal");
  Serial.println("      pct:10,5");
}

// =========================
// BLE CALLBACKS
// =========================
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) override {
    deviceConnected = true;
    needNotifyOnConnect = true;
    Serial.println("[BLE] Device connected");
  }

  void onDisconnect(BLEServer *pServer) override {
    deviceConnected = false;
    Serial.println("[BLE] Device disconnected");
  }
};

class CharacteristicCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override {
    String rx = pChar->getValue();
    rx.trim();

    if (rx.length() > 0) {
      handleCommand(rx, "BLE");
    }
  }

  void onRead(BLECharacteristic *pChar) override {
    syncCharacteristicValue();
    Serial.println("[BLE] Read current state");
  }
};

// =========================
// SERIAL INPUT
// =========================
void handleSerialInput() {
  while (Serial.available()) {
    char c = (char)Serial.read();

    if (c == '\n' || c == '\r') {
      if (serialBuffer.length() > 0) {
        handleCommand(serialBuffer, "SERIAL");
        serialBuffer = "";
      }
    } else {
      serialBuffer += c;
    }
  }
}

// =========================
// TOUCH MONITOR
// =========================
void monitorTouch() {
  unsigned long now = millis();
  if (now - lastTouchPollMs < TOUCH_POLL_MS) return;
  lastTouchPollMs = now;

  if (manualOverride) {
    // Đang test truyền thông bằng tay, bỏ qua cảm biến thật
    return;
  }

  touchRaw = touchRead(TOUCH_PIN);

  // Bù trôi baseline chậm khi đang không chạm
  if (!touchState && touchRaw < touchEnterThreshold) {
    touchBaseline = (touchBaseline * 31UL + touchRaw) / 32UL;
    updateThresholds();
  }

  bool newState = evaluateTouchState(touchRaw, touchState);

  if (newState != touchState) {
    setLogicalState(newState, true, "TOUCH");
  }
}

// =========================
// SETUP
// =========================
void setup() {
  Serial.begin(115200);
  delay(800);
  Serial.println();
  Serial.println("=== ESP32-S3 BLE Touch Monitor ===");

  // Touch calibration
  recalibrateTouch();
  touchRaw = touchRead(TOUCH_PIN);
  touchState = evaluateTouchState(touchRaw, false);

  // BLE init
  BLEDevice::init("ESP32S3_TOUCH");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ |
      BLECharacteristic::PROPERTY_WRITE |
      BLECharacteristic::PROPERTY_NOTIFY
  );

  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new CharacteristicCallbacks());
  syncCharacteristicValue();

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("[BLE] Advertising started");
  Serial.println("Commands via Serial or BLE Write:");
  Serial.println("  get");
  Serial.println("  1:true");
  Serial.println("  0:false");
  Serial.println("  auto");
  Serial.println("  cal");
  Serial.println("  pct:10,5");
}

// =========================
// LOOP
// =========================
void loop() {
  handleSerialInput();
  monitorTouch();

  // Gửi trạng thái hiện tại ngay khi điện thoại vừa kết nối
  if (deviceConnected && needNotifyOnConnect) {
    needNotifyOnConnect = false;
    notifyPhone("CONNECT");
  }

  // restart advertising khi điện thoại disconnect
  if (!deviceConnected && oldDeviceConnected) {
    delay(200);
    pServer->startAdvertising();
    Serial.println("[BLE] Restart advertising");
    oldDeviceConnected = false;
  }

  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = true;
  }
}