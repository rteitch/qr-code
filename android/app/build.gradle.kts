plugins { 
    id("com.android.application") 
    id("dev.flutter.flutter-gradle-plugin") 
} 
 
android { 
    namespace = "com.qrscannerpro.qr_scanner_pro" 
    compileSdk = flutter.compileSdkVersion 
    ndkVersion = flutter.ndkVersion 
 
    compileOptions { 
        sourceCompatibility = JavaVersion.VERSION_17 
        targetCompatibility = JavaVersion.VERSION_17 
    } 
 
    defaultConfig { 
        applicationId = "com.qrscannerpro.qr_scanner_pro" 
        minSdk = 26 
        targetSdk = flutter.targetSdkVersion 
        versionCode = flutter.versionCode 
        versionName = flutter.versionName 
    } 
 
    buildTypes { 
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    } 
} 
 
kotlin { 
    compilerOptions { 
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 
    } 
} 
 
flutter { 
    source = "../.." 
}
