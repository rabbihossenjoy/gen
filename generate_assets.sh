#!/bin/bash

# This script will generate a Dart file for asset classes with correct naming conventions
# and use AssetGen for PNG files.

# Asset folders
icons_folder="assets/icons"
logo_folder="assets/logo"
alert_folder="assets/alert"

# Output file
output_file="lib/assets/assets.dart"

# ---------------------------------------------
# WRITE HEADER
# ---------------------------------------------
echo "import 'package:flutter/material.dart';" >$output_file
echo "" >>$output_file

echo "class Assets {" >>$output_file
echo "  Assets._();" >>$output_file
echo "  static const \$Icons icons = \$Icons();" >>$output_file
echo "  static const \$Logo logo = \$Logo();" >>$output_file
echo "  static const \$Alert alert = \$Alert();" >>$output_file
echo "}" >>$output_file
echo "" >>$output_file

# ---------------------------------------------
# ASSETGEN CLASS
# ---------------------------------------------
cat << 'EOF' >> $output_file
class AssetGen {
  const AssetGen(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;
  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;
  String get keyName => _assetName;
}
EOF

echo "" >>$output_file

# ---------------------------------------------
# FUNCTION TO GENERATE CLASS FOR ANY FOLDER
# ---------------------------------------------
generate_class() {
    local folder=$1
    local className=$2

    echo "class \$$className {" >>$output_file
    echo "  const \$$className();" >>$output_file

    for file in $folder/*; do
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"
        camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')
        extension="${filename##*.}"

        if [ "$extension" == "png" ]; then
            echo "  AssetGen get $camel_case_name => const AssetGen('$file');" >>$output_file
        else
            echo "  String get $camel_case_name => '$file';" >>$output_file
        fi
    done

    echo "  List<dynamic> get values => [" >>$output_file

    for file in $folder/*; do
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"
        camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')
        echo "    $camel_case_name," >>$output_file
    done

    echo "  ];" >>$output_file
    echo "}" >>$output_file
    echo "" >>$output_file
}

# ---------------------------------------------
# GENERATE EACH ASSET CLASS
# ---------------------------------------------
generate_class "$icons_folder" "Icons"
generate_class "$logo_folder" "Logo"
generate_class "$alert_folder" "Alert"

echo "Assᴇᴛs Gᴇɴᴇʀᴀᴛɪᴏɴ Cᴏᴍᴘʟᴇᴛᴇᴅ 🚀"
