#!/bin/sh

input="$1"

if [ -z "$input" ]; then
    echo "❌ No input provided."
    exit 1
fi

output_file="lib/languages/strings.dart"
temp_constants_file=$(mktemp)
temp_updated_file=$(mktemp)
existing_constants_file=$(mktemp)

# CamelCase converter (POSIX safe)
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

# Create the file if missing
if [ ! -f "$output_file" ]; then
    echo "class Strings {" >"$output_file"
    echo "}" >>"$output_file"
fi

# Extract all existing constants
grep -oE 'static const String [a-zA-Z0-9_]+' "$output_file" | awk '{print $4}' >"$existing_constants_file"

# Prepare new constants
echo "$input" | tr ',' '\n' | while read line; do
    cleaned_line=$(echo "$line" | sed 's/[",]//g' | xargs)
    if [ -z "$cleaned_line" ]; then continue; fi

    var_name=$(to_camel_case "$cleaned_line")
    if grep -q "^$var_name$" "$existing_constants_file"; then
        echo "⚠️  Skipping duplicate: $var_name"
        continue
    fi

    echo "  static const String $var_name = '$cleaned_line';" >>"$temp_constants_file"
done

# Exit if no new constants
if [ ! -s "$temp_constants_file" ]; then
    echo "✅ No new strings to add."
    rm "$temp_constants_file" "$temp_updated_file" "$existing_constants_file"
    exit 0
fi

# Insert new constants before the last `}` of the class
inserted="false"
while IFS= read -r line; do
    if echo "$line" | grep -q "^}$" && [ "$inserted" != "true" ]; then
        cat "$temp_constants_file" >>"$temp_updated_file"
        inserted="true"
    fi
    echo "$line" >>"$temp_updated_file"
done <"$output_file"

# Replace file
cat "$temp_updated_file" >"$output_file"

# Copy to clipboard
case "$(uname)" in
Darwin) cat "$output_file" | pbcopy ;;
Linux) command -v xclip >/dev/null && cat "$output_file" | xclip -selection clipboard ;;
MINGW* | MSYS* | CYGWIN*) cat "$output_file" | clip ;;
esac

echo "✅ strings.dart updated successfully."

rm "$temp_constants_file" "$temp_updated_file" "$existing_constants_file"
