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

  void appendRoute(String cpn, String topicName) {
    // Add route constant to routes.dart
    String routeConstant = '''
  static const String ${topicName}Screen = '/${topicName}Screen';
''';

    File routesFile = File('lib/routes/routes.dart');
    if (routesFile.existsSync()) {
      String routesContent = routesFile.readAsStringSync();
      int insertPosition = routesContent.lastIndexOf('}');

      if (insertPosition != -1) {
        String updatedRoutesContent =
            routesContent.substring(0, insertPosition) +
                routeConstant +
                routesContent.substring(insertPosition);
        routesFile.writeAsStringSync(updatedRoutesContent);
        print("Route constant for $cpn added to lib/routes/routes.dart");
      }
    } else {
      print("Routes file lib/routes/routes.dart does not exist.");
    }

    // Add route page (existing code)
    String routeCode = '''
    GetPage(
      name: Routes.${topicName}Screen,
      page: () => const ${cpn}Screen(),
      binding: ${cpn}Binding(),
    ),
    ''';

    File routeFile = File('lib/routes/route_pages.dart');
    if (routeFile.existsSync()) {
      String content = routeFile.readAsStringSync();
      int insertPosition = content.indexOf('static var list = [');

      if (insertPosition != -1) {
        int insertAfter = content.indexOf('[', insertPosition) + 1;
        String updatedContent = content.substring(0, insertAfter) +
            '\n' +
            routeCode +
            content.substring(insertAfter);
        routeFile.writeAsStringSync(updatedContent);
        print("Route page for $cpn added to lib/routes/route_pages.dart");
      } else {
        print("Could not find the list in lib/routes/route_pages.dart");
      }
    } else {
      print("Route file lib/routes/route_pages.dart does not exist.");
    }
  }

  for (var topicName in viewsList) {
    var cpn = capitalize(topicName);

    // Create directories
    Directory('lib/views/$topicName/controller').createSync(recursive: true);
    Directory('lib/views/$topicName/screen').createSync(recursive: true);
    Directory('lib/views/$topicName/widget').createSync(recursive: true);

    // Paths
    final controllerPath =
        'lib/views/$topicName/controller/${topicName}_controller.dart';
    final screenPath = 'lib/views/$topicName/screen/${topicName}_screen.dart';
    final mobileScreenPath =
        'lib/views/$topicName/screen/${topicName}_mobile_screen.dart';
    final tabletScreenPath =
        'lib/views/$topicName/screen/${topicName}_tablet_screen.dart';
    final bindingPath = 'lib/bindings/${topicName}_binding.dart';

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
    // Add binding content
    final bindingContent = '''
import 'package:get/get.dart';
import '../views/$topicName/controller/${topicName}_controller.dart';

class ${cpn}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ${cpn}Controller());
  }
}
''';
    // Write files
    writeFile(controllerPath, controllerContent);
    writeFile(screenPath, screenContent);
    writeFile(mobileScreenPath, mobileScreenContent);
    writeFile(tabletScreenPath, tabletScreenContent);
    writeFile(bindingPath, bindingContent);
    // Append routes (modified to pass topicName)
    appendRoute(cpn, topicName);
  }

  print('All files have been generated successfully!');
}
