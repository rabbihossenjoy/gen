#!/bin/bash

# Function to create maintenance files
create_maintenance_files() {
    # Define folder and file paths
    MAINTENANCE_FOLDER="lib/backend/utils/maintenance"
    DIALOG_FILE="$MAINTENANCE_FOLDER/maintenance_dialog.dart"
    MODEL_FILE="$MAINTENANCE_FOLDER/maintenance_model.dart"

    # Create the maintenance folder if it doesn't exist
    mkdir -p "$MAINTENANCE_FOLDER"

    # Add content to maintenance_dialog.dart
    cat >"$DIALOG_FILE" <<'EOF'
    // ignore_for_file: deprecated_member_use
import 'package:restart_app/restart_app.dart';

import '../../../utils/basic_screen_imports.dart';
import 'maintenance_model.dart';

class SystemMaintenanceController extends GetxController {
  RxBool maintenanceStatus = false.obs;
}

class MaintenanceDialog {
  show({required MaintenanceModel maintenanceModel}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          Restart.restartApp();
          return false;
        },
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Get.isDarkMode
                ? CustomColor.primaryDarkScaffoldBackgroundColor
                : CustomColor.primaryLightScaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.marginSizeHorizontal * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.marginSizeVertical * 0.5,
                  ),
                  child: Image.network(
                    "\${maintenanceModel.data.baseUrl}/${maintenanceModel.data.imagePath}/${maintenanceModel.data.image}",
                  ),
                ),
                TitleHeading3Widget(
                  text: maintenanceModel.data.title,
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.marginSizeVertical * 0.5,
                  ),
                  child: TitleHeading4Widget(
                    text: maintenanceModel.data.details,
                    textAlign: TextAlign.center,
                  ),
                ),
                PrimaryButton(
                  title: Strings.restart,
                  onPressed: () {
                    Restart.restartApp();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
EOF

    # Add content to maintenance_model.dart
    cat >"$MODEL_FILE" <<'EOF'
import 'dart:convert';

MaintenanceModel maintenanceModelFromJson(String str) =>
    MaintenanceModel.fromJson(json.decode(str));

String maintenanceModelToJson(MaintenanceModel data) =>
    json.encode(data.toJson());

class MaintenanceModel {
  Message message;
  Data data;

  MaintenanceModel({
    required this.message,
    required this.data,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
        "data": data.toJson(),
      };
}

class Data {
  String baseUrl;
  String imagePath;
  String image;
  bool status;
  String title;
  String details;

  Data({
    required this.baseUrl,
    required this.imagePath,
    required this.image,
    required this.status,
    required this.title,
    required this.details,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        baseUrl: json["base_url"],
        imagePath: json["image_path"],
        image: json["image"],
        status: json["status"],
        title: json["title"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "base_url": baseUrl,
        "image_path": imagePath,
        "image": image,
        "status": status,
        "title": title,
        "details": details,
      };
}

class Message {
  List<String> error;

  Message({
    required this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        error: List<String>.from(json["error"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error": List<dynamic>.from(error.map((x) => x)),
      };
}
EOF

    echo "Maintenance files created successfully in $MAINTENANCE_FOLDER"
}

# Function to add the package
add_package() {
    echo "Adding package restart_app..."
    flutter pub add restart_app
    echo "Package restart_app added successfully."
}

# Function to replace api_method.dart
replace_api_method() {
    API_FILE="lib/backend/utils/api_method.dart"
    # Create the api_method.dart file with the provided content
    cat >"$API_FILE" <<'EOF'
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../local_storage/local_storage.dart';
import '../model/common/error_message_model.dart';
import 'custom_snackbar.dart';
import 'logger.dart';
import 'maintenance/maintenance_dialog.dart';
import 'maintenance/maintenance_model.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.getToken()!;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 15,
    bool showResult = false,
    bool isNotStream = true,
  }) async {
    log.i(
        '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|');
    log.i(url);
    log.i(
        '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|');

      bool isMaintenance = response.statusCode == 503;
      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.signOut();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
      }

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code${jsonDecode(response.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
        if (isMaintenance) {
        } else {
          if (isNotStream) {
            CustomSnackBar.error(res.message.error.join(''));
          }
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (isNotStream) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (isNotStream) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> body,
      {int code = 201, int duration = 30, bool showResult = false}) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);

      log.i(
          '|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|');

      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.signOut();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
      }

      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(response.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));

        if (!isMaintenance) CustomSnackBar.error(res.message.error.join(''));

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        )
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

        if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      if (showResult) {
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
      }

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      for (int i = 0; i < fieldList.length; i++) {
        request.files
            .add(await http.MultipartFile.fromPath(fieldList[i], pathList[i]));
      }

      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
      }
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

        if (!isMaintenance) CustomSnackBar.error(res.message.error.toString());

        // CustomSnackBar.error(
        //     jsonDecode(response.body)['message']['error'].toString());
        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    if (isMaintenance) {
      Get.find<SystemMaintenanceController>().maintenanceStatus.value = true;
      MaintenanceModel maintenanceModel =
          MaintenanceModel.fromJson(jsonDecode(jsonData));
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      Get.find<SystemMaintenanceController>().maintenanceStatus.value = false;
    }
  }
}

EOF

    echo "api_method.dart replaced successfully in lib/backend/utils/"
}

# Main menu
echo "Select an option:"
echo "1. Create maintenance files"
echo "2. Add restart_app package"
echo "3. Replace api_method.dart"
echo "4. Exit"

read -p "Enter your choice [1-4]: " choice

case $choice in
1)
    create_maintenance_files
    ;;
2)
    add_package
    ;;
3)
    replace_api_method
    ;;
4)
    echo "Exiting..."
    exit 0
    ;;
*)
    echo "Invalid choice. Please enter 1, 2, 3, or 4."
    ;;
esac
