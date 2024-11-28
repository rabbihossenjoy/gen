import 'dart:io';

void main(List<String> args) {
  List<String> viewsList = args;

  // Ensure the lib/views directory exists
  Directory('lib/views').createSync(recursive: true);

  // Clear the commands.text file at the beginning
  File('lib/views/commands.text').writeAsStringSync('');

  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  String src(String topicName, String cpn) {
    return '''
mkdir -p $topicName/controller && mkdir -p $topicName/screen && mkdir -p $topicName/widget && \\
touch $topicName/controller/${topicName}_controller.dart && \\
touch $topicName/screen/${topicName}_screen.dart && \\
touch $topicName/screen/${topicName}_mobile_screen.dart && \\
touch $topicName/screen/${topicName}_tablet_screen.dart && \\
echo "\\\"\\\"\\\"\\nimport 'package:get/get.dart';\\nclass ${cpn}Controller extends GetxController {}\\n\\\"\\\"\\\"" > $topicName/controller/${topicName}_controller.dart && \\
echo "\\\"\\\"\\\"\\nimport 'package:flutter/material.dart';\\nimport 'package:get/get.dart';\\nimport '../../../base/utils/basic_import.dart';\\nimport '../controller/${topicName}_controller.dart';\\npart '${topicName}_tablet_screen.dart';\\npart '${topicName}_mobile_screen.dart';\\nclass ${cpn}Screen extends GetView<${cpn}Controller> {\\n  const ${cpn}Screen({Key? key}) : super(key: key);\\n  @override\\n  Widget build(BuildContext context) {\\n    return ResponsiveLayout(\\n      mobile: ${cpn}MobileScreen(),\\n      tablet: ${cpn}TabletScreen(),\\n    );\\n  }\\n}\\n\\\"\\\"\\\"" > $topicName/screen/${topicName}_screen.dart && \\
echo "\\\"\\\"\\\"\\npart of '${topicName}_screen.dart';\\nclass ${cpn}TabletScreen extends GetView<${cpn}Controller> {\\n  const ${cpn}TabletScreen({super.key});\\n  @override\\n  Widget build(BuildContext context) {\\n    return Scaffold(\\n      appBar: const CustomAppBar('${cpn} Tablet Screen'),\\n      body: _bodyWidget(context),\\n    );\\n  }\\n  _bodyWidget(BuildContext context) {\\n    return const SafeArea(\\n      child: Column(\\n        children: [],\\n      ),\\n    );\\n  }\\n}\\n\\\"\\\"\\\"" > $topicName/screen/${topicName}_tablet_screen.dart && \\
echo "\\\"\\\"\\\"\\npart of '${topicName}_screen.dart';\\nclass ${cpn}MobileScreen extends GetView<${cpn}Controller> {\\n  const ${cpn}MobileScreen({super.key});\\n  @override\\n  Widget build(BuildContext context) {\\n    return Scaffold(\\n      appBar: const CustomAppBar('${cpn} Mobile Screen'),\\n      body: _bodyWidget(context),\\n    );\\n  }\\n  _bodyWidget(BuildContext context) {\\n    return const SafeArea(\\n      child: Column(\\n        children: [],\\n      ),\\n    );\\n  }\\n}\\n\\\"\\\"\\\"" > $topicName/screen/${topicName}_mobile_screen.dart
''';
  }

  void appendRoute(String cpn) {
    String routeCode = '''
    GetPage(
      name: Routes.${cpn}Screen,
      page: () => const ${cpn}Screen(),
    ),
    ''';

    File routeFile = File('lib/routes/route_pages.dart');

    if (routeFile.existsSync()) {
      // Read the content of the route file
      String content = routeFile.readAsStringSync();

      // Find the position to insert the new route code
      int insertPosition = content.indexOf('static var list = [');

      if (insertPosition != -1) {
        // Insert the new route code at the appropriate position
        int insertAfter = content.indexOf('[', insertPosition) + 1;
        String updatedContent = content.substring(0, insertAfter) +
            '\n' +
            routeCode +
            content.substring(insertAfter);

        // Write the updated content back to the route file
        routeFile.writeAsStringSync(updatedContent);

        print("Route for $cpn added to lib/routes/route_pages.dart");
      } else {
        print("Could not find the list in lib/routes/route_pages.dart");
      }
    } else {
      print("Route file lib/routes/route_pages.dart does not exist.");
    }
  }

  for (var topicName in viewsList) {
    var cpn = capitalize(topicName);
    String command = src(topicName, cpn);

    // Print to console for verification
    print(command);

    // Append generated commands to commands.text file
    File('lib/views/commands.text')
        .writeAsStringSync(command, mode: FileMode.append);

    // Append route in lib/routes/route_pages.dart
    appendRoute(cpn);
  }

  // Execute the generated commands
  Process.run('sh', ['-c', 'cd lib/views && bash commands.text']).then((result) {
    print(result.stdout);
    print(result.stderr);

    // Delete commands.text file after execution
    File('lib/views/commands.text').deleteSync();
  });
}
