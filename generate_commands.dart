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
mkdir -p $topicName/{controller,screen,widget} && \\
touch $topicName/controller/${topicName}_controller.dart \\
      $topicName/screen/{${topicName}_screen.dart,${topicName}_mobile_screen.dart,${topicName}_tablet_screen.dart} && \\
echo  \"""
import 'package:get/get.dart';
class ${cpn}Controller extends GetxController {}
\""" > $topicName/controller/${topicName}_controller.dart && \\

echo  \"""
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
\
/*
/// code for others 

 */

""" > $topicName/screen/${topicName}_screen.dart && \\
echo  \"""
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
\""" > $topicName/screen/${topicName}_tablet_screen.dart && \\
echo  \"""
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
\""" > $topicName/screen/${topicName}_mobile_screen.dart
''';
  }

  for (var topicName in viewsList) {
    var cpn = capitalize(topicName);
    String command = src(topicName, cpn);

    // Print to console for verification
    print(command);

    // Append generated commands to commands.text file
    File('lib/views/commands.text')
        .writeAsStringSync(command, mode: FileMode.append);
  }

  // Execute the generated commands
  Process.run('sh', ['-c', 'cd lib/views && sh commands.text']).then((result) {
    print(result.stdout);
    print(result.stderr);

    // Delete commands.text file after execution
    File('lib/views/commands.text').deleteSync();
  });
}


/*
 chmod +x run.sh   
./run.sh addMoney2  

static const String investmentScreen = '/investmentScreen';

 GetPage(
      name: Routes.investmentScreen,
      page: () => const InvestmentScreen(),
      binding: InvestmentBinding(),
),


import 'package:get/get.dart';
import '../views/investment/controller/investment_controller.dart';
class InvestmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(InvestmentController());
  }
}
 */

