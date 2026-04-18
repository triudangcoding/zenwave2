# Generated from R8 missing_rules.txt
-dontwarn com.alibaba.fastjson.JSONObject
-dontwarn com.alibaba.fastjson.TypeReference
-dontwarn com.alibaba.fastjson.parser.Feature
-dontwarn com.google.firebase.crashlytics.buildtools.reloc.org.apache.commons.codec.binary.Hex
-dontwarn org.apache.commons.lang3.StringUtils
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE

################YCBT Smart Ring SDK###############
# Keep entire YCBT SDK — required for BLE reconnect, callbacks, and JNI
-keep class com.yucheng.ycbtsdk.** { *; }
-keep interface com.yucheng.ycbtsdk.** { *; }
-dontwarn com.yucheng.ycbtsdk.**

# Keep the Flutter plugin bridge classes
-keep class com.example.yc_product_plugin.** { *; }
-keep interface com.example.yc_product_plugin.** { *; }

################FastJSON (used by YCBT SDK)###############
-keep class com.alibaba.fastjson.** { *; }
-dontwarn com.alibaba.fastjson.**

################MQTT (used by YCBT SDK)###############
-keep class org.eclipse.paho.client.mqttv3.** { *; }
-dontwarn org.eclipse.paho.client.mqttv3.**

################Nordic DFU (ring OTA)###############
-keep class no.nordicsemi.android.dfu.** { *; }
-dontwarn no.nordicsemi.android.dfu.**

################JL Watch SDK###############
-keep class com.jieli.** { *; }
-dontwarn com.jieli.**

################Ali Agent###############
-keep class com.alibaba.sdk.** { *; }
-dontwarn com.alibaba.sdk.**
