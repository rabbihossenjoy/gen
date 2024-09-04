#!/bin/sh

# Path to your strings.txt file
file_path="lib/languages/strings.txt"

# Function to convert a string to camelCase with up to 3 words
to_camel_case() {
    local input="$1"
    local max_words=3
    # Extract up to 3 words
    local words=$(echo "$input" | awk -v max_words="$max_words" '
        {
            for (i=1; i<=NF; i++) {
                if (i > max_words) break
                if (i == 1) {
                    printf tolower($i)
                } else {
                    printf toupper(substr($i,1,1)) tolower(substr($i,2))
                }
            }
            print ""
        }' | sed 's/[^a-zA-Z0-9]//g')
    echo "$words"
}

# Temporary files to hold the output and existing constants
temp_file=$(mktemp)
existing_constants_file=$(mktemp)

# Start building the Strings class
echo "class Strings {" > "$temp_file"
echo >> "$temp_file"

# Read each line from the strings.txt file
while IFS= read -r line; do
    # Remove commas and trim whitespace
    cleaned_line=$(echo "$line" | sed 's/,//g' | xargs)
    
    # Skip empty lines
    if [ -z "$cleaned_line" ]; then
        continue
    fi

    # Convert to camelCase variable name with up to 3 words
    var_name=$(to_camel_case "$cleaned_line")

    # Check if the constant name already exists in the existing constants file
    if grep -q "^$var_name$" "$existing_constants_file"; then
        continue
    fi

    # Print the static const line and add it to the existing constants file
    echo "  static const String $var_name = '$cleaned_line';" >> "$temp_file"
    echo "$var_name" >> "$existing_constants_file"
done < "$file_path"

# Close the class definition
echo >> "$temp_file"
echo "}" >> "$temp_file"

# Display the output
cat "$temp_file"

# Detect OS and copy to clipboard
case "$(uname)" in
    Linux)
        if command -v xclip > /dev/null; then
            cat "$temp_file" | xclip -selection clipboard
        else
            echo "xclip not found. Please install xclip for clipboard support."
        fi
        ;;
    Darwin)
        if command -v pbcopy > /dev/null; then
            cat "$temp_file" | pbcopy
        else
            echo "pbcopy not found. Please install pbcopy for clipboard support."
        fi
        ;;
    MINGW*|MSYS*|MINGW32*|MINGW64*)
        if command -v clip > /dev/null; then
            cat "$temp_file" | clip
        else
            echo "clip not found. Please install clip for clipboard support."
        fi
        ;;
    *)
        echo "Unsupported OS."
        ;;
esac

# Clean up
rm "$temp_file" "$existing_constants_file"
