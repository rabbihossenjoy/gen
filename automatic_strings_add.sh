#!/bin/bash

# This script automates adding new string constants to a Dart file.
# It formats keys as "Strings.key", copies them individually for clipboard managers,
# and displays a loading animation during processing.

# --- Loading Animation Function ---
show_loading() {
  local -r pid="${1}"
  local -r delay='0.1'
  local spinstr='|/-\'
  local temp
  echo -n "⏳ Processing strings... "
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
    temp="${spinstr#?}"
    printf "%c" "${spinstr}"
    spinstr="${temp}${spinstr%${temp}}"
    sleep "${delay}"
    printf "\b"
  done
  printf " \b\n"
}

# --- Main Script Logic ---
main() {
  input="$1"

  if [ -z "$input" ]; then
    echo "❌ No input provided. Please provide a comma-separated string of values."
    exit 1
  fi

  output_file="lib/languages/strings.dart"
  temp_constants_file=$(mktemp)
  temp_updated_file=$(mktemp)
  existing_constants_file=$(mktemp)
  new_keys_file=$(mktemp)

  # Function to clean up temporary files on exit
  cleanup() {
    rm -f "$temp_constants_file" "$temp_updated_file" "$existing_constants_file" "$new_keys_file"
  }
  trap cleanup EXIT

  # Converts a string to a smart camelCase key.
  to_smart_camel_case() {
    input_str="$1"
    limited_str=$(echo "$input_str" | tr -cd '[:alnum:][:space:]' | awk '{print $1, $2, $3}')
    echo "$limited_str" | awk '
      {
        if (NF==0) { print "" }
        else {
          printf tolower($1)
          for (i=2; i<=NF; i++) {
            printf toupper(substr($i,1,1)) tolower(substr($i,2))
          }
          print ""
        }
      }'
  }

  # --- Main Processing ---
  # Ensure the output directory and file exist.
  mkdir -p "$(dirname "$output_file")"
  if [ ! -f "$output_file" ]; then
    echo "class Strings {" > "$output_file"
    echo "}" >> "$output_file"
  fi

  # Extract existing constant keys.
  grep -oE 'static const String [a-zA-Z0-9_]+' "$output_file" | awk '{print $4}' > "$existing_constants_file"

  # Process input and prepare new constants.
  echo "$input" | tr ',' '\n' | while read -r line; do
    cleaned_line=$(echo "$line" | sed 's/[",]//g' | xargs)
    [ -z "$cleaned_line" ] && continue
    var_name=$(to_smart_camel_case "$cleaned_line")
    if grep -q "^$var_name$" "$existing_constants_file"; then
      echo "⚠️  Skipping duplicate key: $var_name"
      continue
    fi
    echo "  static const String $var_name = '$cleaned_line';" >> "$temp_constants_file"
    echo "$var_name" >> "$new_keys_file"
  done

  # Exit if no new strings were added.
  if [ ! -s "$new_keys_file" ]; then
    echo "✅ No new strings to add."
    exit 0
  fi

  # Insert new constants into the Dart file.
  inserted="false"
  while IFS= read -r line; do
    if echo "$line" | grep -q "^[[:space:]]*}$" && [ "$inserted" != "true" ]; then
      cat "$temp_constants_file" >> "$temp_updated_file"
      inserted="true"
    fi
    echo "$line" >> "$temp_updated_file"
  done < "$output_file"

  # Overwrite the original file.
  cat "$temp_updated_file" > "$output_file"

  # --- Copy keys to clipboard with the new format ---
  while IFS= read -r key; do
    if [ -n "$key" ]; then
      # Format the key as "Strings.key" and copy it.
      echo -n "Strings.$key" | pbcopy
      # Pause for Maccy to register the copy.
      sleep 0.1
    fi
  done < "$new_keys_file"
}

# --- Run the script ---
# Run the main function in the background and show the loading animation.
main "$@" &
show_loading $!

# --- Final Output ---
echo "✅ strings.dart updated successfully."
echo "📋 All new keys (formatted as Strings.key) are in your Maccy history!"
