# mobile_scanner ProGuard rules
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit / CameraX
-keep class com.google.mlkit.** { *; }
-keep class androidx.camera.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}