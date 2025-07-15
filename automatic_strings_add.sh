#!/bin/bash

input="$1"

if [ -z "$input" ]; then
  echo "❌ No input provided."
  exit 1
fi

output_file="lib/languages/strings.dart"
temp_constants_file=$(mktemp)
temp_updated_file=$(mktemp)
existing_constants_file=$(mktemp)

# Converts a string like "Add Money" to "addMoney"
to_camel_case() {
  input_str="$1"
  cleaned=$(echo "$input_str" | tr -cd '[:alnum:] [:space:]')
  echo "$cleaned" | awk '
    {
      for (i=1; i<=NF; i++) {
        if (i == 1) printf tolower($i)
        else printf toupper(substr($i,1,1)) tolower(substr($i,2))
      }
      print ""
    }'
}

# Ensure strings.dart exists
if [ ! -f "$output_file" ]; then
  echo "class Strings {" > "$output_file"
  echo "}" >> "$output_file"
fi

# Extract existing keys
grep -oE 'static const String [a-zA-Z0-9_]+' "$output_file" | awk '{print $4}' > "$existing_constants_file"

# Prepare new constants
echo "$input" | tr ',' '\n' | while read -r line; do
  cleaned_line=$(echo "$line" | sed 's/[",]//g' | xargs)
  [ -z "$cleaned_line" ] && continue

  var_name=$(to_camel_case "$cleaned_line")
  if grep -q "^$var_name$" "$existing_constants_file"; then
    echo "⚠️  Skipping duplicate: $var_name"
    continue
  fi

  echo "  static const String $var_name = '$cleaned_line';" >> "$temp_constants_file"
done

# Exit if nothing to add
if [ ! -s "$temp_constants_file" ]; then
  echo "✅ No new strings to add."
  rm "$temp_constants_file" "$temp_updated_file" "$existing_constants_file"
  exit 0
fi

# Insert constants before final `}` in strings.dart
inserted="false"
while IFS= read -r line; do
  if echo "$line" | grep -q "^}$" && [ "$inserted" != "true" ]; then
    cat "$temp_constants_file" >> "$temp_updated_file"
    inserted="true"
  fi
  echo "$line" >> "$temp_updated_file"
done < "$output_file"

# Overwrite original file
cat "$temp_updated_file" > "$output_file"

# Copy to clipboard if supported
case "$(uname)" in
  Darwin) cat "$output_file" | pbcopy ;;
  Linux) command -v xclip > /dev/null && cat "$output_file" | xclip -selection clipboard ;;
  MINGW*|MSYS*|CYGWIN*) cat "$output_file" | clip ;;
esac

echo "✅ strings.dart updated successfully."

echo "✅ strings.dart updated successfully."

# Open file in VS Code if possible
if command -v code >/dev/null 2>&1; then
  code lib/languages/strings.dart
else
  echo "⚠️ VS Code CLI 'code' command not found. Open lib/languages/strings.dart manually."
fi

# Clean up
rm "$temp_constants_file" "$temp_updated_file" "$existing_constants_file"

