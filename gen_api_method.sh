#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: sh gen_api_method.sh <ModelClassName> <LoadingVariableName>"
    exit 1
fi

# Assign arguments to variables
MODEL_CLASS_NAME=$1
LOADING_VAR_NAME=$2

# Convert first letter of class name to lowercase for variable names
MODEL_VAR_NAME="$(tr '[:upper:]' '[:lower:]' <<< ${MODEL_CLASS_NAME:0:1})${MODEL_CLASS_NAME:1}"

# Ensure the loading variable name is properly capitalized with "Loading" appended
LOADING_VAR_NAME_WITH_LOADING="${LOADING_VAR_NAME}Loading"

# Create the Dart code
DART_CODE=$(cat <<EOF
  final _is$LOADING_VAR_NAME_WITH_LOADING = false.obs;
  bool get is$LOADING_VAR_NAME_WITH_LOADING => _is$LOADING_VAR_NAME_WITH_LOADING.value;

  late $MODEL_CLASS_NAME _$MODEL_VAR_NAME;
  $MODEL_CLASS_NAME get ${MODEL_VAR_NAME} => _$MODEL_VAR_NAME;

  Future<$MODEL_CLASS_NAME?> procceName() async {
    return RequestProcess().request<$MODEL_CLASS_NAME>(
      fromJson: $MODEL_CLASS_NAME.fromJson,
      apiEndpoint: ApiEndpoint.,
      isLoading: _is$LOADING_VAR_NAME_WITH_LOADING,
      onSuccess: (value) {
        _$MODEL_VAR_NAME = value!;
        var data = _$MODEL_VAR_NAME.data.bankBranches;
      },
    );
  }
EOF
)

# Copy the Dart code to clipboard
# Check the OS and use the appropriate clipboard tool
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "$DART_CODE" | pbcopy
    echo "Generated $MODEL_CLASS_NAME Method (macOS)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (check for xclip or xsel)
    if command -v xclip &> /dev/null; then
        echo "$DART_CODE" | xclip -selection clipboard
        echo "Generated $MODEL_CLASS_NAME Method (Linux, xclip)"
    elif command -v xsel &> /dev/null; then
        echo "$DART_CODE" | xsel --clipboard --input
        echo "Generated $MODEL_CLASS_NAME Method (Linux, xsel)"
    else
        echo "Clipboard copy tool not found. Please install xclip or xsel."
    fi
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash, Cygwin, or similar)
    echo "$DART_CODE" | clip
    echo "Generated $MODEL_CLASS_NAME Method (Windows)"
else
    echo "Unsupported OS. Manual copy required."
fi
