#!/bin/bash

# Step 1: Clone the Gen repository (if not already cloned)
GEN_DIR="$HOME/automatc_code/gen"

if [ ! -d "$GEN_DIR" ]; then
  echo "Cloning gen repository from GitHub..."
  git clone https://github.com/rabbihossenjoy/gen.git "$GEN_DIR"
else
  echo "Gen repository already exists at $GEN_DIR"
fi

# Step 2: Activate the gen package globally
echo "Activating gen package globally..."
dart pub global activate --source path "$GEN_DIR"

# Step 3: Ensure Dart global path is in the user's PATH
PUB_CACHE_PATH="$HOME/.pub-cache/bin"
if ! echo "$PATH" | grep -q "$PUB_CACHE_PATH"; then
  echo "Adding Dart global bin directory to PATH..."
  echo "export PATH=\"\$PATH:$PUB_CACHE_PATH\"" >> ~/.zshrc  # Use .bashrc for bash users
  source ~/.zshrc  # Apply the changes
else
  echo "Dart global bin directory is already in PATH."
fi

# Step 4: Verify installation
echo "Verifying gen command..."
gen --version
