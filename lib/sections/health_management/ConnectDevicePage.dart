import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/app_state_service.dart';
import 'RelaxPage.dart';

class ConnectDevicePage extends StatelessWidget {
  const ConnectDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppStateService.deviceConnectedNotifier,
      builder: (_, connected, __) {
        final bool? touchDetected = AppStateService.isTouchDetected;
        final String deviceName =
            AppStateService.connectedDeviceName ?? 'ESP32S3_TOUCH';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trạng thái pin',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutral800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                connected
                                    ? 'Thiết bị: $deviceName'
                                    : 'Chưa có thiết bị nào được kết nối',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: connected ? 0.78 : 0.0,
                                strokeWidth: 9,
                                backgroundColor: const Color(0xFFE4EFE4),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF67B56A),
                                ),
                              ),
                              Center(
                                child: Text(
                                  connected ? '78%' : '--',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF67B56A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 214,
                    height: 214,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFA7F0F1), width: 6),
                    ),
                    child: Center(
                      child: Container(
                        width: 156,
                        height: 156,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00B3BF),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sensors,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    connected ? 'ĐÃ KẾT NỐI' : 'CHƯA KẾT NỐI',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Color(0xFF4F9A67),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    !connected
                        ? 'Vui lòng kết nối ESP32 từ drawer ở Trang chủ.'
                        : touchDetected == null
                            ? 'Đã kết nối, đang chờ trạng thái cảm biến.'
                            : touchDetected
                                ? 'Thiết bị đang phát hiện chạm da.'
                                : 'Thiết bị chưa phát hiện chạm da.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.neutral700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: connected
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RelaxPage(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF129EAF),
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Bắt Đầu Phiên Thiền',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
