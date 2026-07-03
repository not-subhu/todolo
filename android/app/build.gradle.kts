plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kawaiiquest.kawaii_quest"
    compileSdk = flutter.compileSdkVersion

    // Pin to the NDK version required by flutter_local_notifications,
    // path_provider_android, shared_preferences_android, and url_launcher_android.
    // NDK versions are backward-compatible, so using the highest required version is safe.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications (uses Java 8+ APIs via desugaring)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.kawaiiquest.kawaii_quest"
        // Desugaring requires minSdk 21+
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now.
            // To publish to the Play Store, replace this with your own signing config.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring — lets flutter_local_notifications use modern Java
    // time APIs on Android devices running below API 26.
    // v1.2.3 is used instead of 2.x because 2.x uses an AAR metadata "variant"
    // field that Flutter 3.32.0's bundled AGP version cannot parse.
    coreLibraryDesugaring("com.android.tools.desugar_jdk_libs:1.2.3")
}
