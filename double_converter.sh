#!/bin/bash

#######################################################
# Auto Double Converter with Type Update - macOS/Linux
# Usage: ./double_converter.sh model_file_name.dart
#######################################################

INPUT_NAME="$1"

if [ -z "$INPUT_NAME" ]; then
  echo "❌ Usage: ./double_converter.sh model_file_name.dart"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

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

# Extract fields in form: fieldName: json["field_key"]
FIELDS=($(grep -E '\w+[ ]*:[ ]*json\["' "$FILE_PATH" | sed -E 's/^ *([A-Za-z0-9_]+).*/\1/'))

if [ ${#FIELDS[@]} -eq 0 ]; then
  echo "❌ No fields found in model mapping."
  exit 1
fi

echo "✅ Fields detected:"
i=1
for f in "${FIELDS[@]}"; do
  echo "   $i) $f"
  ((i++))
done

echo ""
echo "👉 Select fields to convert to double (example: 1,3,5). Press ENTER to cancel."
read INPUT

# Stop if user pressed ENTER without selection
if [ -z "$INPUT" ]; then
  echo "⚠️  No fields selected. Aborting."
  exit 0
fi

IFS=',' read -ra SELECTED <<< "$INPUT"

# Backup file only when valid selection
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
for s in "${SELECTED[@]}"; do
  index=$((s-1))
  field="${FIELDS[$index]}"

  if [ -z "$field" ]; then
    echo "⚠️  Invalid selection: $s"
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
