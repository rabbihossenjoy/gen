#!/bin/bash

# Read the content of strings.dart
inputText=$(cat lib/languages/strings.dart)

# Run the Dart program with the input text
dart run test.dart "$inputText"
