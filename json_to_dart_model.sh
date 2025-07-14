#!/bin/bash

set -e

VIEW_NAME="$1"
CLASS_NAME="$2"
JSON_FILE="$3"

if [ -z "$VIEW_NAME" ] || [ -z "$CLASS_NAME" ] || [ -z "$JSON_FILE" ]; then
    echo "❌ Usage: json_to_dart_model.sh view_name ClassName json_file_path"
    exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "❌ JSON file not found: $JSON_FILE"
    exit 1
fi

# Convert PascalCase to snake_case
to_snake_case() {
    echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

FILE_NAME="$(to_snake_case "$CLASS_NAME")"
MODEL_DIR="views/$VIEW_NAME/model"
RELATIVE_DART_FILE="$MODEL_DIR/${FILE_NAME}.dart"
ABSOLUTE_DART_FILE="$(pwd)/$RELATIVE_DART_FILE"

mkdir -p "$MODEL_DIR"

echo "🚀 Generating Dart model: $CLASS_NAME → $RELATIVE_DART_FILE"

if ! command -v quicktype &>/dev/null; then
    echo "❌ quicktype CLI not found. Install with: npm install -g quicktype"
    exit 1
fi

quicktype "$JSON_FILE" --lang dart --top-level "$CLASS_NAME" --out "$RELATIVE_DART_FILE"

if [[ -f "$RELATIVE_DART_FILE" ]]; then
    echo "✅ Model created at: $RELATIVE_DART_FILE"

    if command -v dart &>/dev/null; then
        dart format "$RELATIVE_DART_FILE" >/dev/null
        echo "✨ Formatted with dart format"
    fi

    if command -v pbcopy &>/dev/null; then
        echo -n "$CLASS_NAME" | pbcopy
        echo "📋 Class name copied to clipboard"
    fi

    if command -v code &>/dev/null; then
        code "$ABSOLUTE_DART_FILE"
        echo "🪟 Opened in VS Code"
    fi
else
    echo "❌ Failed to create Dart model file"
fi
