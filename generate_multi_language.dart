import 'dart:io';

void main(List<String> arguments) {
  // Check if there is an input text passed
  if (arguments.isEmpty) {
    print('No input text provided.');
    return;
  }

  String inputText = arguments[0];

  List<String> words =
      inputText.split('\n'); // Split the text by newline characters

  List<String> keys = [];
  List<String> values = [];
  String currentKey = '';
  String currentValue = ''; // To handle multiline values

  for (String line in words) {
    String trimmedLine = line.trim();
    if (trimmedLine.isNotEmpty) {
      // Check for the start of a new key-value assignment
      if (trimmedLine.startsWith('static const String') &&
          trimmedLine.contains('=')) {
        // If there's a previous key, add it to the list
        if (currentKey.isNotEmpty) {
          keys.add(currentKey);
          // Clean up the value
          values.add(currentValue
              .replaceAll("'", "")
              .replaceAll('"', '')
              .replaceAll(';', '')
              .trim());
        }

        // Extract the key
        int startIndex = trimmedLine.indexOf('String ') + 7;
        int endIndex = trimmedLine.indexOf('=');
        currentKey = trimmedLine.substring(startIndex, endIndex).trim();

        // Start capturing the value
        currentValue = trimmedLine.substring(endIndex + 1).trim();
      } else if (trimmedLine.endsWith(';')) {
        // Finalize the current value if the line ends with a semicolon
        currentValue +=
            ' ${trimmedLine.replaceAll("'", "").replaceAll('"', '').replaceAll(';', '').trim()}';
        keys.add(currentKey);
        values.add(currentValue.trim());
        currentKey = '';
        currentValue = '';
      } else {
        // Continue building the current value
        currentValue += ' ${trimmedLine.trim()}';
      }
    }
  }

  // Handle the last key-value pair if not already added
  if (currentKey.isNotEmpty) {
    keys.add(currentKey);
    values.add(currentValue
        .replaceAll("'", "")
        .replaceAll('"', '')
        .replaceAll(';', '')
        .trim());
  }

  // Print Formatted Keys
  print("Formatted Keys:");
  for (int i = 0; i < keys.length; i++) {
    // Use the original key as it is
    String originalKey = keys[i];

    // Generate formatted key value
    String formattedKeyValue =
        'appL${originalKey[0].toUpperCase()}${originalKey.substring(1)}';

    // Print formatted keys
    print('static const String $originalKey = "$formattedKeyValue";');
  }

  // Print Keys
  print("\nKeys:");
  for (int i = 0; i < keys.length; i++) {
    print("  ${keys[i]}");
  }

  // Print Values
  print("\nValues:");
  for (String value in values) {
    print("  $value");
  }

  // Create a CSV file
  File csvFile = File('strings.csv');
  IOSink sink = csvFile.openWrite();

  // Write header
  sink.writeln('Key,Value');

  // Write formatted keys and original values to the CSV file
  for (int i = 0; i < keys.length; i++) {
    String formattedKeyValue =
        'appL${keys[i][0].toUpperCase()}${keys[i].substring(1)}';
    String csvLine = '"$formattedKeyValue","${values[i]}"';
    sink.writeln(csvLine);
  }

  // Close the sink
  sink.close();

  // Create strings.dart file
  File dartFile = File('strings.dart');
  IOSink dartSink = dartFile.openWrite();

  // Write Dart file header
  dartSink.writeln('// This file is generated automatically.');
  dartSink.writeln('class Strings {');

  // Write keys to strings.dart with formatted key values
  for (int i = 0; i < keys.length; i++) {
    String originalKey = keys[i];
    String formattedKeyValue =
        'appL${originalKey[0].toUpperCase()}${originalKey.substring(1)}';
    dartSink
        .writeln('  static const String $originalKey = "$formattedKeyValue";');
  }

  // Write closing bracket
  dartSink.writeln('}');

  // Close the Dart file sink
  dartSink.close();

  print("\nGenerated strings.dart file and strings.csv file.");
}
