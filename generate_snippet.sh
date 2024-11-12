#!/bin/bash

# Prompt user for prefix
read -p "Enter the prefix for your snippet: " prefix

# Prompt user for body input with a multi-line input option
echo "Enter your snippet body, followed by an empty line to finish:"
body_lines=()
while IFS= read -r line; do
    [[ -z "$line" ]] && break
    body_lines+=("$line")
done

# Generate JSON output
json_output=$(jq -n --arg prefix "$prefix" --argjson body "$(printf '%s\n' "${body_lines[@]}" | jq -R . | jq -s .)" '
{
    ($prefix): {
        "scope": "dart,flutter",
        "prefix": $prefix,
        "body": $body
    }
}')

# Output the JSON to a file or display it
echo -e "\nGenerated Snippet JSON:\n$json_output"
echo "$json_output" > snippet.json
echo "Snippet saved to snippet.json"
