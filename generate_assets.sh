#!/bin/bash

# This script will generate a Dart file for asset classes with correct naming conventions and use AssetGen for PNG files.

# Folder containing the asset files (icons and logos).
icons_folder="assets/icons"
logo_folder="assets/logo"

# Output Dart file.
output_file="lib/assets/assets.dart"

# Start by writing the basic structure of the Dart file.
echo "import 'package:flutter/material.dart';" >$output_file
echo "" >>$output_file
echo "class Assets {" >>$output_file
echo "  Assets._();" >>$output_file
echo "  static const \$Icons icons = \$Icons();" >>$output_file
echo "  static const \$Logo logo = \$Logo();" >>$output_file
echo "}" >>$output_file
echo "" >>$output_file

# Include AssetGen class definition
echo "class AssetGen {" >>$output_file
echo "  const AssetGen(this._assetName, {this.size, this.flavors = const {}});" >>$output_file
echo "" >>$output_file
echo "  final String _assetName;" >>$output_file
echo "" >>$output_file
echo "  final Size? size;" >>$output_file
echo "  final Set<String> flavors;" >>$output_file
echo "" >>$output_file
echo "  Image image({" >>$output_file
echo "    Key? key," >>$output_file
echo "    AssetBundle? bundle," >>$output_file
echo "    ImageFrameBuilder? frameBuilder," >>$output_file
echo "    ImageErrorWidgetBuilder? errorBuilder," >>$output_file
echo "    String? semanticLabel," >>$output_file
echo "    bool excludeFromSemantics = false," >>$output_file
echo "    double? scale," >>$output_file
echo "    double? width," >>$output_file
echo "    double? height," >>$output_file
echo "    Color? color," >>$output_file
echo "    Animation<double>? opacity," >>$output_file
echo "    BlendMode? colorBlendMode," >>$output_file
echo "    BoxFit? fit," >>$output_file
echo "    AlignmentGeometry alignment = Alignment.center," >>$output_file
echo "    ImageRepeat repeat = ImageRepeat.noRepeat," >>$output_file
echo "    Rect? centerSlice," >>$output_file
echo "    bool matchTextDirection = false," >>$output_file
echo "    bool gaplessPlayback = false," >>$output_file
echo "    bool isAntiAlias = false," >>$output_file
echo "    String? package," >>$output_file
echo "    FilterQuality filterQuality = FilterQuality.low," >>$output_file
echo "    int? cacheWidth," >>$output_file
echo "    int? cacheHeight," >>$output_file
echo "  }) {" >>$output_file
echo "    return Image.asset(" >>$output_file
echo "      _assetName," >>$output_file
echo "      key: key," >>$output_file
echo "      bundle: bundle," >>$output_file
echo "      frameBuilder: frameBuilder," >>$output_file
echo "      errorBuilder: errorBuilder," >>$output_file
echo "      semanticLabel: semanticLabel," >>$output_file
echo "      excludeFromSemantics: excludeFromSemantics," >>$output_file
echo "      scale: scale," >>$output_file
echo "      width: width," >>$output_file
echo "      height: height," >>$output_file
echo "      color: color," >>$output_file
echo "      opacity: opacity," >>$output_file
echo "      colorBlendMode: colorBlendMode," >>$output_file
echo "      fit: fit," >>$output_file
echo "      alignment: alignment," >>$output_file
echo "      repeat: repeat," >>$output_file
echo "      centerSlice: centerSlice," >>$output_file
echo "      matchTextDirection: matchTextDirection," >>$output_file
echo "      gaplessPlayback: gaplessPlayback," >>$output_file
echo "      isAntiAlias: isAntiAlias," >>$output_file
echo "      package: package," >>$output_file
echo "      filterQuality: filterQuality," >>$output_file
echo "      cacheWidth: cacheWidth," >>$output_file
echo "      cacheHeight: cacheHeight," >>$output_file
echo "    );" >>$output_file
echo "  }" >>$output_file
echo "" >>$output_file
echo "  ImageProvider provider({" >>$output_file
echo "    AssetBundle? bundle," >>$output_file
echo "    String? package," >>$output_file
echo "  }) {" >>$output_file
echo "    return AssetImage(" >>$output_file
echo "      _assetName," >>$output_file
echo "      bundle: bundle," >>$output_file
echo "      package: package," >>$output_file
echo "    );" >>$output_file
echo "  }" >>$output_file
echo "" >>$output_file
echo "  String get path => _assetName;" >>$output_file
echo "" >>$output_file
echo "  String get keyName => _assetName;" >>$output_file
echo "}" >>$output_file
echo "" >>$output_file

# Generate the \$Icons class.
echo "class \$Icons {" >>$output_file
echo "  const \$Icons();" >>$output_file

# Loop through all icon files and create getters for them.
for file in $icons_folder/*; do
    # Extract file name without extension.
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    # Convert filename to camelCase (for example: app_launcher.png => appLauncher)
    camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')

    # Check if the file is a PNG file
    extension="${filename##*.}"
    if [ "$extension" == "png" ]; then
        # Use AssetGen for PNG files.
        echo "  AssetGen get $camel_case_name => const AssetGen('$file');" >>$output_file
    else
        # Use the regular string getter for other file types.
        echo "  String get $camel_case_name => '$file';" >>$output_file
    fi
done

# Add the list of values for icons.
echo "  List<dynamic> get values => [" >>$output_file
for file in $icons_folder/*; do
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')

    # Check if the file is a PNG file
    extension="${filename##*.}"
    if [ "$extension" == "png" ]; then
        # Use AssetGen for PNG files.
        echo "        $camel_case_name," >>$output_file
    else
        # Use the regular string getter for other file types.
        echo "        $camel_case_name," >>$output_file
    fi
done
echo "      ];" >>$output_file
echo "}" >>$output_file
echo "" >>$output_file

# Generate the \$Logo class.
echo "class \$Logo {" >>$output_file
echo "  const \$Logo();" >>$output_file

# Loop through all logo files and create getters for them.
for file in $logo_folder/*; do
    # Extract file name without extension.
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    # Convert filename to camelCase (for example: app_launcher.png => appLauncher)
    camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')

    # Check if the file is a PNG file
    extension="${filename##*.}"
    if [ "$extension" == "png" ]; then
        # Use AssetGen for PNG files.
        echo "  AssetGen get $camel_case_name => const AssetGen('$file');" >>$output_file
    else
        # Use the regular string getter for other file types.
        echo "  String get $camel_case_name => '$file';" >>$output_file
    fi
done

# Add the list of values for logos.
echo "  List<dynamic> get values => [" >>$output_file
for file in $logo_folder/*; do
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    camel_case_name=$(echo $filename_noext | sed -r 's/(_[a-z])/\U\1/g' | sed 's/_//g')

    # Check if the file is a PNG file
    extension="${filename##*.}"
    if [ "$extension" == "png" ]; then
        # Use AssetGen for PNG files.
        echo "        $camel_case_name," >>$output_file
    else
        # Use the regular string getter for other file types.
        echo "        $camel_case_name," >>$output_file
    fi
done
echo "      ];" >>$output_file
echo "}" >>$output_file

echo "Assᴇᴛs Gᴇɴᴇʀᴀᴛɪᴏɴ Cᴏᴍᴘʟᴇᴛᴇᴅ 🚀"
