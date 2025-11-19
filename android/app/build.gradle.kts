plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.meupreco.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Unique Application ID
        applicationId = "com.meupreco.app"
        // Garantir que o minSdkVersion seja pelo menos 21 para suportar todas as funcionalidades
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Configuração para assinatura de release
            // Você precisará criar uma keystore e configurar estas propriedades
            keyAlias = "meu_preco_key"
            keyPassword = "meu_preco_2025"
            storeFile = file("../keystore/meu_preco.jks")
            storePassword = "meu_preco_2025"
        }
    }

    buildTypes {
        release {
            // Configuração otimizada para release
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Configurações de otimização
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            isPseudoLocalesEnabled = false
            isZipAlignEnabled = true
        }
        debug {
            // Configuração para debug
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
    }

    // Configurações de bundle para otimização
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependências necessárias para o funcionamento adequado dos plugins
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
