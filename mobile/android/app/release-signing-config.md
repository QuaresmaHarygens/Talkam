# Android Release Signing Configuration

## Generate Keystore

```bash
cd mobile/android/app
keytool -genkey -v -keystore talkam-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias talkam
```

## Configure Signing

Create `mobile/android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=talkam
storeFile=../app/talkam-release-key.jks
```

## Update build.gradle

Add to `mobile/android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Build Release

```bash
cd mobile
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

## Security Notes

- **Never commit** `key.properties` or `.jks` files to Git
- Add to `.gitignore`:
  ```
  *.jks
  key.properties
  ```
- Store passwords securely
- Use CI/CD secrets for automated builds
