#!/bin/bash

# Variables
KEYSTORE_PATH="android/app/key.jks"
KEYSTORE_ALIAS="key"
KEY_PASSWORD="12345678"
VALIDITY=10000
KEYSTORE_PROPS="android/key.properties"
BUILD_GRADLE="android/app/build.gradle"

# Create the directory for the keystore if it doesn't exist
mkdir -p "$(dirname "$KEYSTORE_PATH")"

# Generate the keystore (.jks)
keytool -genkey -v \
    -keystore $KEYSTORE_PATH \
    -alias $KEYSTORE_ALIAS \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY \
    -storepass $KEY_PASSWORD \
    -keypass $KEY_PASSWORD \
    -dname "CN=Your Name, OU=Your Organization, O=Your Company, L=Your City, ST=Your State, C=Your Country"

# Create the key.properties file
KEYSTORE_ABS_PATH=$(realpath "$KEYSTORE_PATH")
mkdir -p "$(dirname "$KEYSTORE_PROPS")"
echo "storePassword=$KEY_PASSWORD" >$KEYSTORE_PROPS
echo "keyPassword=$KEY_PASSWORD" >>$KEYSTORE_PROPS
echo "keyAlias=$KEYSTORE_ALIAS" >>$KEYSTORE_PROPS
echo "storeFile=$KEYSTORE_ABS_PATH" >>$KEYSTORE_PROPS

echo "Keystore and key.properties generated successfully!"

# Check for existing modifications in build.gradle
if grep -q "def keystoreProperties = new Properties()" $BUILD_GRADLE &&
    grep -q "def keystorePropertiesFile = rootProject.file(\"key.properties\")" $BUILD_GRADLE &&
    grep -q "if (keystorePropertiesFile.exists()) {" $BUILD_GRADLE &&
    grep -q "keystoreProperties.load(new FileInputStream(keystorePropertiesFile))" $BUILD_GRADLE &&
    grep -q "signingConfigs {" $BUILD_GRADLE &&
    grep -q "release {" $BUILD_GRADLE &&
    grep -q "keyAlias keystoreProperties\['keyAlias'\'];" $BUILD_GRADLE &&
    grep -q "keyPassword keystoreProperties\['keyPassword'\'];" $BUILD_GRADLE &&
    grep -q "storeFile file(keystoreProperties\['storeFile'\']);" $BUILD_GRADLE &&
    grep -q "storePassword keystoreProperties\['storePassword'\'];" $BUILD_GRADLE; then
    echo "build.gradle already modified. No changes made."
else
    # Modify build.gradle to include keystore configuration
    sed -i '' -e '/android {/i\
def keystoreProperties = new Properties()\
def keystorePropertiesFile = rootProject.file("key.properties")\
if (keystorePropertiesFile.exists()) {\
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\
}' -e '/buildTypes {/i\
    signingConfigs {\
        release {\
            keyAlias keystoreProperties['\''keyAlias'\''];\
            keyPassword keystoreProperties['\''keyPassword'\''];\
            storeFile file(keystoreProperties['\''storeFile'\'']);\
            storePassword keystoreProperties['\''storePassword'\''];\
        }\
    }' $BUILD_GRADLE

    sed -i '' -e 's/signingConfig signingConfigs.debug/signingConfig signingConfigs.release/' $BUILD_GRADLE

    echo "build.gradle updated successfully!"
fi

# Build the app bundle
flutter build appbundle --no-tree-shake-icons
