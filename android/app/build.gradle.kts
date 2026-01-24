plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from key.properties file
val keystoreProperties = HashMap<String, String>()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.forEachLine { line ->
        val parts = line.split("=")
        if (parts.size == 2) {
            keystoreProperties[parts[0].trim()] = parts[1].trim()
        }
    }
}

// Check if keystore file exists (handle both absolute and relative paths)
val keystoreFileExists = if (keystoreProperties.containsKey("storeFile")) {
    val storeFilePath = keystoreProperties["storeFile"] as String
    val keystoreFile = if (storeFilePath.contains(":") || storeFilePath.startsWith("/")) {
        // Absolute path (Windows drive letter or Unix absolute path)
        file(storeFilePath)
    } else {
        // Relative path - resolve from android directory
        rootProject.file(storeFilePath)
    }
    keystoreFile.exists()
} else {
    false
}
val hasValidKeystore = keystoreProperties.containsKey("keyAlias") && 
    keystoreProperties.containsKey("keyPassword") && 
    keystoreProperties.containsKey("storePassword") && 
    keystoreFileExists

android {
    namespace = "com.brother.taxi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.brother.taxi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 8
        versionName = "1.8"
    }

    // Signing configurations
    signingConfigs {
        if (hasValidKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                val storeFilePath = keystoreProperties["storeFile"] as String
                storeFile = if (storeFilePath.contains(":") || storeFilePath.startsWith("/")) {
                    // Absolute path
                    file(storeFilePath)
                } else {
                    // Relative path
                    rootProject.file(storeFilePath)
                }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasValidKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
