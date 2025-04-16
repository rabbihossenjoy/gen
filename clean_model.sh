#!/bin/bash

# Usage: ./remove_unused_fields.sh <model_file_path>
# Example: ./remove_unused_fields.sh lib/views/doctor_booking/model/doctor_booking_model.dart

MODEL_FILE="$1"
FIELDS_FILE="model_fields.txt"
USED_FIELDS_FILE="used_model_fields.txt"
UNUSED_FIELDS_FILE="unused_model_fields.txt"
BACKUP_MODEL_FILE="${MODEL_FILE}.bak"

# Check if model file exists
if [ ! -f "$MODEL_FILE" ]; then
    echo "❌ Model file not found: $MODEL_FILE"
    exit 1
fi

# Extract view/module name from path (e.g. 'doctor_booking')
MODEL_BASENAME=$(echo "$MODEL_FILE" | sed -E 's|lib/views/([^/]+)/.*|\1|')
SEARCH_PATH_SCREEN="lib/views/$MODEL_BASENAME/screen"
SEARCH_PATH_WIDGET="lib/views/$MODEL_BASENAME/widget"

# Check if either screen or widget path exists
if [ ! -d "$SEARCH_PATH_SCREEN" ] && [ ! -d "$SEARCH_PATH_WIDGET" ]; then
    echo "❌ Neither $SEARCH_PATH_SCREEN nor $SEARCH_PATH_WIDGET exist."
    exit 1
fi

# Create a backup of the original model file
cp "$MODEL_FILE" "$BACKUP_MODEL_FILE"
echo "📦 Backup created at: $BACKUP_MODEL_FILE"

# Clear temp files
>"$FIELDS_FILE"
>"$USED_FIELDS_FILE"
>"$UNUSED_FIELDS_FILE"

# Extract model field names
awk '
/^[[:space:]]*(late)?[[:space:]]*(final)?[[:space:]]*(required)?[[:space:]]*[A-Za-z0-9_<>,?\[\]]+[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*;/ {
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[a-zA-Z_][a-zA-Z0-9_]*;/) {
            gsub(";", "", $i)
            print $i
            break
        }
    }
}' "$MODEL_FILE" | sort | uniq >"$FIELDS_FILE"

echo "🔍 Searching in:"
[ -d "$SEARCH_PATH_SCREEN" ] && echo "   📂 $SEARCH_PATH_SCREEN"
[ -d "$SEARCH_PATH_WIDGET" ] && echo "   📂 $SEARCH_PATH_WIDGET"

# Detect usage of each field
while IFS= read -r field; do
    echo "🔎 Checking usage for: $field"
    if grep -rw "$field" "$SEARCH_PATH_SCREEN" "$SEARCH_PATH_WIDGET" --exclude="$(basename "$MODEL_FILE")" >/dev/null 2>&1; then
        echo "$field" >>"$USED_FIELDS_FILE"
    else
        echo "$field" >>"$UNUSED_FIELDS_FILE"
    fi
done <"$FIELDS_FILE"

# Overwrite model file with only used fields
echo "⚙️ Updating model file: $MODEL_FILE"
TEMP_MODEL_FILE="${MODEL_FILE}.tmp"
>"$TEMP_MODEL_FILE"

while IFS= read -r line; do
    keep_line=true
    while IFS= read -r unused; do
        if echo "$line" | grep -w "$unused" >/dev/null; then
            keep_line=false
            break
        fi
    done <"$UNUSED_FIELDS_FILE"

    $keep_line && echo "$line" >>"$TEMP_MODEL_FILE"
done <"$BACKUP_MODEL_FILE"

mv "$TEMP_MODEL_FILE" "$MODEL_FILE"

# Summary
echo ""
if [ -s "$UNUSED_FIELDS_FILE" ]; then
    echo "❌ Unused fields removed:"
    cat "$UNUSED_FIELDS_FILE"
else
    echo "✅ No unused fields found."
fi

echo ""
echo "✅ Model file updated: $MODEL_FILE"
echo "🗂️  Original backup saved at: $BACKUP_MODEL_FILE"
# Remove temp files
rm -f "$FIELDS_FILE" "$USED_FIELDS_FILE" "$UNUSED_FIELDS_FILE" "$BACKUP_MODEL_FILE"

