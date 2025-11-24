#!/bin/bash

svg_file="$1"
icon_name="$2"

# Add .svg if missing
if [[ ! "$icon_name" =~ \.svg$ ]]; then
  icon_name="${icon_name}.svg"
fi

ICON_DIR="assets/icons"
mkdir -p "$ICON_DIR"

file_path="$ICON_DIR/$icon_name"

# === Collision check ===
if [[ -f "$file_path" ]]; then
  echo "⚠ Icon '$icon_name' already exists."
  echo -n "Do you want to overwrite? (y = yes, n = no, s = skip): "
  read answer

  case "$answer" in
    y|Y)
      echo "✓ Overwriting..."
      ;;
    s|S)
      echo "⏩ Skipped adding icon."
      exit 0
      ;;
    n|N)
      # Auto rename (add "Icon" before .svg)
      base="${icon_name%.svg}"
      icon_name="${base}Icon.svg"
      file_path="$ICON_DIR/$icon_name"
      echo "➕ Renamed to: $icon_name"
      ;;
    *)
      echo "❌ Invalid option. Skipping."
      exit 0
      ;;
  esac
fi

# === Save file ===
cp "$svg_file" "$file_path"
echo "✓ Saved: $file_path"

# === Run asset generator ===
echo "➡ Running asset generator..."
curl -sSL https://raw.githubusercontent.com/rabbihossenjoy/gen/main/generate_assets.sh | bash

echo "🎉 Done — icon added successfully"
#!/bin/bash

svg_file="$1"
icon_name="$2"

# Add .svg if missing
if [[ ! "$icon_name" =~ \.svg$ ]]; then
  icon_name="${icon_name}.svg"
fi

ICON_DIR="assets/icons"
mkdir -p "$ICON_DIR"

file_path="$ICON_DIR/$icon_name"

# === Collision check ===
if [[ -f "$file_path" ]]; then
  echo "⚠ Icon '$icon_name' already exists."
  echo -n "Do you want to overwrite? (y = yes, n = no, s = skip): "
  read answer

  case "$answer" in
    y|Y)
      echo "✓ Overwriting..."
      ;;
    s|S)
      echo "⏩ Skipped adding icon."
      exit 0
      ;;
    n|N)
      # Auto rename (add "Icon" before .svg)
      base="${icon_name%.svg}"
      icon_name="${base}Icon.svg"
      file_path="$ICON_DIR/$icon_name"
      echo "➕ Renamed to: $icon_name"
      ;;
    *)
      echo "❌ Invalid option. Skipping."
      exit 0
      ;;
  esac
fi

# === Save file ===
cp "$svg_file" "$file_path"
echo "✓ Saved: $file_path"

# === Run asset generator ===
echo "➡ Running asset generator..."
curl -sSL https://raw.githubusercontent.com/rabbihossenjoy/gen/main/generate_assets.sh | bash


# Copy to clipboard
if command -v pbcopy &>/dev/null; then
  echo -n "$icon_name" | pbcopy
elif command -v xclip &>/dev/null; then
  echo -n "$icon_name" | xclip -selection clipboard
fi

echo "🎉 Done — icon added successfully"
