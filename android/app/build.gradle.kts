plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // ✅ ovde ide umesto apply plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.trendify"
    compileSdk = 34 // ili flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ⚠️ umesto jvmTarget = JavaVersion.VERSION_17.toString() koristi ovo
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.trendify"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}