#!/bin/bash

# Prompt user for prefix
read -p "Enter the prefix for your snippet: " prefix

# Prompt user for body input with a multi-line input option
echo "Enter your snippet body, followed by an empty line to finish:"
body_lines=()
while IFS= read -r line; do
    [[ -z "$line" ]] && break
    # Escape double quotes and backslashes for JSON compatibility
    escaped_line=$(echo "$line" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    body_lines+=("\"$escaped_line\"")
done

# Generate JSON output manually
json_output=$(
    cat <<EOF
{
    "$prefix": {
        "scope": "dart,flutter",
        "prefix": "$prefix",
        "body": [
            $(
        IFS=,
        echo "${body_lines[*]}"
    )
        ]
    }
}
EOF
)

# Output the JSON to a file or display it
echo -e "\nGenerated Snippet JSON:\n$json_output"
echo "$json_output" >snippet.json
echo "Snippet saved to snippet.json"
