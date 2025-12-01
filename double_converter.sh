#!/bin/bash

#######################################################
# Auto Double Converter with Type Update
# Non-interactive mode: pass model name and comma-separated fields
# Usage: ./double_converter.sh model_file_name.dart "field1,field2,field3" [project_root]
#######################################################

INPUT_NAME="$1"
FIELDS_INPUT="$2"
PROJECT_ROOT="$3"

if [ -z "$INPUT_NAME" ] || [ -z "$FIELDS_INPUT" ]; then
  echo "❌ Usage: ./double_converter.sh model_file_name.dart \"field1,field2\" [project_root]"
  exit 1
fi

# If project root not provided, fallback to current working directory
if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT="$(pwd)"
fi

echo "📌 Searching for file: $INPUT_NAME"
echo "🔍 Project root: $PROJECT_ROOT"
echo ""

FOUND_PATH=$(find "$PROJECT_ROOT" -type f -name "$INPUT_NAME" | head -n 1)

if [ -z "$FOUND_PATH" ]; then
  echo "❌ File not found anywhere inside project."
  exit 1
fi

echo "📄 File found at: $FOUND_PATH"
FILE_PATH="$FOUND_PATH"
echo ""

# Convert input fields string to array
IFS=',' read -ra SELECTED_FIELDS <<< "$FIELDS_INPUT"

if [ ${#SELECTED_FIELDS[@]} -eq 0 ]; then
  echo "⚠️ No fields provided. Aborting."
  exit 1
fi

echo "✅ Fields to convert: ${SELECTED_FIELDS[*]}"
echo ""

# Backup file
cp "$FILE_PATH" "$FILE_PATH.bak"
echo "📦 Backup created: $FILE_PATH.bak"
echo ""

# Detect package name from pubspec.yaml
PUBSPEC="$PROJECT_ROOT/pubspec.yaml"
if [ ! -f "$PUBSPEC" ]; then
  echo "❌ pubspec.yaml not found!"
  exit 1
fi

PACKAGE_NAME=$(grep -E '^name:' "$PUBSPEC" | awk '{print $2}')
if [ -z "$PACKAGE_NAME" ]; then
  echo "❌ Could not detect package name from pubspec.yaml"
  exit 1
fi

echo "🏷️  Detected package: $PACKAGE_NAME"

IMPORT_LINE="import 'package:$PACKAGE_NAME/base/utils/basic_import.dart';"

if ! grep -q "$IMPORT_LINE" "$FILE_PATH"; then
  sed -i '' "1s|^|$IMPORT_LINE\n|" "$FILE_PATH"
  echo "📌 Added json extension import"
fi

echo ""

# UPDATE FIELDS
for field in "${SELECTED_FIELDS[@]}"; do
  if ! grep -q "$field:" "$FILE_PATH"; then
    echo "⚠️  Field '$field' not found in model. Skipping."
    continue
  fi

  echo "🔧 Converting \"$field\" → json.doubleValue(\"key\")"

  # Update type to double
  sed -i '' -E "s/(String|int|num|dynamic|double)[[:space:]]+$field;/double $field;/g" "$FILE_PATH"

  # Replace mapping to use .doubleValue()
  sed -i '' -E \
    "s|$field:[[:space:]]*json\[[[:space:]]*\"([^\"]+)\"[[:space:]]*\][^,]*|$field: json.doubleValue(\"\\1\")|g" \
    "$FILE_PATH"

  # Cleanup leftovers
  sed -i '' -E "s/\.asDouble\(\)//g" "$FILE_PATH"
  sed -i '' -E "s/\?\.\s*toDouble\(\)//g" "$FILE_PATH"
  sed -i '' -E "s/\.toDouble\(\)//g" "$FILE_PATH"
done

echo ""
echo "🎉 Done! Selected fields updated to json.doubleValue(\"key\")"
