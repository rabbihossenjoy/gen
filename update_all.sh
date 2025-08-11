#!/bin/zsh
set -e

echo "🚀 Updating Flutter & Dart environment versions..."
# Set fixed Dart & Flutter SDK versions
sed -i '' 's/sdk: \".*\"/sdk: ">=3.8.1 <4.4.0"/' pubspec.yaml
sed -i '' 's/flutter: .*/flutter: 3.32.8/' pubspec.yaml

echo "📦 Updating all packages to latest..."
flutter pub upgrade --major-versions

echo "⚙️ Updating Gradle & Kotlin versions..."
sed -i '' 's/id "com.android.application" version ".*"/id "com.android.application" version "8.7.3"/' android/settings.gradle
sed -i '' 's/id "org.jetbrains.kotlin.android" version ".*"/id "org.jetbrains.kotlin.android" version "2.1.0"/' android/settings.gradle

echo "📂 Updating Gradle Wrapper..."
sed -i '' 's|distributionUrl=.*|distributionUrl=https\://services.gradle.org/distributions/gradle-8.12-all.zip|' android/gradle/wrapper/gradle-wrapper.properties

echo "📛 Updating namespace & SDK versions..."
BUILD_FILE="android/app/build.gradle"

# Extract applicationId
APP_ID=$(grep -E 'applicationId "' "$BUILD_FILE" | head -n 1 | sed -E 's/.*applicationId "(.*)".*/\1/')
if [[ -n "$APP_ID" ]]; then
    # If namespace exists, replace it; else insert after android {
    if grep -q 'namespace "' "$BUILD_FILE"; then
        sed -i '' "s/^[[:space:]]*namespace \".*\"/    namespace \"$APP_ID\"/" "$BUILD_FILE"
    else
        sed -i '' "/^android {/a\\
    namespace \"$APP_ID\"
" "$BUILD_FILE"
    fi
    echo "✅ Namespace set to: $APP_ID"
else
    echo "⚠️ Could not find applicationId in $BUILD_FILE"
fi

# Replace compileSdkVersion
sed -i '' -E 's/^[[:space:]]*compileSdkVersion[[:space:]]+[0-9]+/    compileSdkVersion flutter.compileSdkVersion/' "$BUILD_FILE"

# Replace ndkVersion only if not already flutter.ndkVersion
if ! grep -q 'ndkVersion flutter.ndkVersion' "$BUILD_FILE"; then
    sed -i '' -E 's/^[[:space:]]*ndkVersion[[:space:]]+.*/    ndkVersion flutter.ndkVersion/' "$BUILD_FILE"
fi

# Replace minSdkVersion
sed -i '' -E 's/^[[:space:]]*minSdkVersion[[:space:]]+[0-9]+/        minSdkVersion flutter.minSdkVersion/' "$BUILD_FILE"

# Replace targetSdkVersion
sed -i '' -E 's/^[[:space:]]*targetSdkVersion[[:space:]]+[0-9]+/        targetSdkVersion flutter.targetSdkVersion/' "$BUILD_FILE"


echo "🛠 Applying Dart fixes..."
dart fix --apply

echo "🔍 Updating deprecated .withOpacity to .withValues..."
find lib -type f -name "*.dart" -exec sed -i '' 's/\.withOpacity(\([^)]*\))/\.withValues(alpha: \1)/g' {} +

echo "🧹 Analyzing code..."
flutter analyze

echo "🧽 Cleaning project..."
flutter clean

echo "📥 Updating dependencies..."
flutter pub upgrade

echo "🎉 All set! Your project is updated, cleaned, analyzed, and running smoothly. 🚀"
