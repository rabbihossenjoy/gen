import 'dart:io';

void main(List<String> args) {
  List<String> viewsList = args;

  // Ensure the lib/views directory exists
  Directory('lib/views').createSync(recursive: true);

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  void writeFile(String path, String content) {
    File(path).createSync(recursive: true);
    File(path).writeAsStringSync(content);
  }

  for (var topicName in viewsList) {
    var cpn = capitalize(topicName);

    // Paths
    final controllerPath = 'lib/views/$topicName/controller/${topicName}_controller.dart';
    final screenPath = 'lib/views/$topicName/screen/${topicName}_screen.dart';
    final mobileScreenPath = 'lib/views/$topicName/screen/${topicName}_mobile_screen.dart';
    final tabletScreenPath = 'lib/views/$topicName/screen/${topicName}_tablet_screen.dart';

    // Content
    final controllerContent = '''
import 'package:get/get.dart';

class ${cpn}Controller extends GetxController {}
''';

    final screenContent = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/${topicName}_controller.dart';
part '${topicName}_tablet_screen.dart';
part '${topicName}_mobile_screen.dart';

class ${cpn}Screen extends GetView<${cpn}Controller> {
  const ${cpn}Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ${cpn}MobileScreen(),
      tablet: ${cpn}TabletScreen(),
    );
  }
}
''';

    final mobileScreenContent = '''
part of '${topicName}_screen.dart';

class ${cpn}MobileScreen extends GetView<${cpn}Controller> {
  const ${cpn}MobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('${cpn} Mobile Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [],
      ),
    );
  }
}
''';

    final tabletScreenContent = '''
part of '${topicName}_screen.dart';

class ${cpn}TabletScreen extends GetView<${cpn}Controller> {
  const ${cpn}TabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('${cpn} Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [],
      ),
    );
  }
}
''';

    // Write files
    writeFile(controllerPath, controllerContent);
    writeFile(screenPath, screenContent);
    writeFile(mobileScreenPath, mobileScreenContent);
    writeFile(tabletScreenPath, tabletScreenContent);
  }

  print('All files have been generated successfully!');
}
