#!/bin/sh

# Define the path where both project.txt and the logo folder are located
SOURCE_PATH="$1"

# Define the paths for project.txt, logo folder, and the Dart file
PROJECT_FILE="$SOURCE_PATH/project.txt"
LOGO_FOLDER="$SOURCE_PATH/logo"
DART_FILE="lib/backend/services/api_endpoint.dart"
NEW_LOGO_FOLDER="assets/logo"

# Check if the source path argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_path>"
    exit 1
fi

# Check if project.txt exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "The file $PROJECT_FILE does not exist."
    exit 1
fi

# Extract URL, APP_NAME, and PACKAGE from project.txt
URL=$(grep 'URL="' "$PROJECT_FILE" | sed 's/URL="//' | sed 's/",//')
APP_NAME=$(grep 'APP_NAME="' "$PROJECT_FILE" | sed 's/APP_NAME="//' | sed 's/",//')
PACKAGE=$(grep 'PACKAGE="' "$PROJECT_FILE" | sed 's/PACKAGE="//' | sed 's/",//')

# Check if the values were extracted
if [ -z "$URL" ]; then
    echo "No URL found in $PROJECT_FILE."
    exit 1
fi

if [ -z "$APP_NAME" ]; then
    echo "No APP_NAME found in $PROJECT_FILE."
    exit 1
fi

if [ -z "$PACKAGE" ]; then
    echo "No PACKAGE found in $PROJECT_FILE."
    exit 1
fi

# Check if the Dart file exists
if [ ! -f "$DART_FILE" ]; then
    echo "The file $DART_FILE does not exist."
    exit 1
fi

# Use sed to replace the mainDomain value in the Dart file
sed -i.bak "s|static const String mainDomain = \".*\";|static const String mainDomain = \"$URL\";|g" "$DART_FILE"

echo "Updated mainDomain with URL: $URL in $DART_FILE."

# Check if the logo folder exists
if [ -d "$LOGO_FOLDER" ]; then
    # Create the new folder (assets/logo) if it doesn't exist
    mkdir -p "$NEW_LOGO_FOLDER"

    # Copy the contents from the logo folder to the assets/logo folder
    cp -r "$LOGO_FOLDER/"* "$NEW_LOGO_FOLDER/"

    echo "Files copied successfully from $LOGO_FOLDER to $NEW_LOGO_FOLDER."
else
    echo "The folder $LOGO_FOLDER does not exist."
fi

# Run the Flutter commands to change app launcher
flutter pub run flutter_launcher_icons
# Run the Flutter commands to change app name and package name
echo "Running Flutter command to rename the app to: $APP_NAME"
flutter pub run rename_app:main all="$APP_NAME"

echo "Running Flutter command to change the package name to: $PACKAGE"
flutter pub run change_app_package_name:main "$PACKAGE"
flutter build apk --split-per-abi --no-tree-shake-icons
