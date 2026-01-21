plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties safely
val keystoreProperties = HashMap<String, String>()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.forEachLine { line ->
        val parts = line.split("=", limit = 2)
        if (parts.size == 2) {
            keystoreProperties[parts[0].trim()] = parts[1].trim()
        }
    }
}

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
        applicationId = "com.brother.taxi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 8
        versionName = "1.8"
    }

    signingConfigs {
        // Only create release config if all required properties exist
        val hasAllKeys = keystoreProperties.containsKey("storeFile") &&
                keystoreProperties.containsKey("storePassword") &&
                keystoreProperties.containsKey("keyAlias") &&
                keystoreProperties.containsKey("keyPassword")

        if (hasAllKeys) {
            create("release") {
                // Safe access – .get() returns String?, we check existence above
                keyAlias = keystoreProperties["keyAlias"]
                keyPassword = keystoreProperties["keyPassword"]
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"]
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Use release signing only if it was created, otherwise fallback to debug
            signingConfig = if (signingConfigs.findByName("release") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}