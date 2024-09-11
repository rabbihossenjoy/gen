#!/bin/sh

# Define paths
SOURCE_PATH="$1"
PROJECT_FILE="$SOURCE_PATH/project.txt"
LOGO_FOLDER="$SOURCE_PATH/logo"
DART_FILE="lib/backend/services/api_endpoint.dart"
NEW_LOGO_FOLDER="assets/logo"
GOOGLE_SERVICES_JSON="android/app/google-services.json"

# Check if source path is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_path>"
    exit 1
fi

# Check if project.txt exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "The file $PROJECT_FILE does not exist."
    exit 1
fi

# Extract values from project.txt
URL=$(grep 'URL="' "$PROJECT_FILE" | sed 's/URL="//' | sed 's/",//')
APP_NAME=$(grep 'APP_NAME="' "$PROJECT_FILE" | sed 's/APP_NAME="//' | sed 's/",//')
PACKAGE=$(grep 'PACKAGE="' "$PROJECT_FILE" | sed 's/PACKAGE="//' | sed 's/",//')
COLOR=$(grep 'COLOR="' "$PROJECT_FILE" | sed 's/COLOR="//' | sed 's/",//')

# Check if values were extracted
if [ -z "$URL" ] || [ -z "$APP_NAME" ] || [ -z "$PACKAGE" ] || [ -z "$COLOR" ]; then
    echo "One or more values missing in $PROJECT_FILE."
    exit 1
fi

# Update Dart file
if [ -f "$DART_FILE" ]; then
    sed -i.bak "s|static Color primaryDarkColor = const Color(0xFFFFFFFF);|static Color primaryDarkColor = const Color($COLOR);|g" "$DART_FILE"
    sed -i.bak "s|static Color primaryLightColor = const Color(0xFFFFFFFF);|static Color primaryLightColor = const Color($COLOR);|g" "$DART_FILE"
    sed -i.bak "s|static const String mainDomain = \".*\";|static const String mainDomain = \"$URL\";|g" "$DART_FILE"
    echo "Updated Dart file with URL and color."
else
    echo "The file $DART_FILE does not exist."
    exit 1
fi

# Copy logo folder
if [ -d "$LOGO_FOLDER" ]; then
    mkdir -p "$NEW_LOGO_FOLDER"
    cp -r "$LOGO_FOLDER/"* "$NEW_LOGO_FOLDER/"
    echo "Files copied successfully from $LOGO_FOLDER to $NEW_LOGO_FOLDER."
else
    echo "The folder $LOGO_FOLDER does not exist."
fi

# Update Google Services JSON
if [ -f "$GOOGLE_SERVICES_JSON" ]; then
    sed -i.bak "s|\"package_name\": \".*\"|\"package_name\": \"$PACKAGE\"|g" "$GOOGLE_SERVICES_JSON"
    echo "Updated Google Services JSON with package name."
else
    echo "The file $GOOGLE_SERVICES_JSON does not exist."
    exit 1
fi

# Run Flutter commands
flutter pub run flutter_launcher_icons
flutter pub run rename_app:main all="$APP_NAME"
flutter pub run change_app_package_name:main "$PACKAGE"

# Build APK
flutter build apk --split-per-abi --no-tree-shake-icons

# Install APK on connected Android device using adb
APK_PATH=$(find build/app/outputs/flutter-apk -name "*.apk" | head -n 1)

if [ -n "$APK_PATH" ]; then
    echo "Installing APK: $APK_PATH"
    adb install -r "$APK_PATH"
    echo "APK installed on device."
else
    echo "APK not found!"
    exit 1
fi
