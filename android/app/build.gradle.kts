import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    // key.properties must exist for release builds.
    // Copy key.properties.example to key.properties and fill in your credentials.
    logger.warn("WARNING: android/key.properties not found. Release signing will fail.")
}

android {
    namespace = "com.hercyclebloom.app"
    compileSdk = 36
    ndkVersion = "27.2.12479018"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hercyclebloom.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
                ?: error("key.properties is missing or 'storeFile' is not set. Cannot sign release build.")
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: error("'keyAlias' not set in key.properties.")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: error("'keyPassword' not set in key.properties.")
            storeFile = file(storeFilePath)
            storePassword = keystoreProperties["storePassword"] as String?
                ?: error("'storePassword' not set in key.properties.")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

configurations.all {
    resolutionStrategy {
        force("com.android.billingclient:billing:8.0.0")
    }
}
