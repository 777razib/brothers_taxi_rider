import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/style/global_text_style.dart';

class SetPasswordController extends GetxController {
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  String email = ''; // Email to be passed as argument

  @override
  void onInit() {
    super.onInit();
    // Fetch email from arguments
    email = Get.arguments?['email'] ?? '';
    print(email);
  }

  var passwordController = TextEditingController();
  var confirmpasswordController = TextEditingController();

  Future<void> setpassword() async {
    final url = Uri.parse('${Urls.resetPassword}');

    try {
      EasyLoading.show(status: 'Logging in...');

      // Prepare the request body
      final requestBody = {
        "email": email, // Assuming email is a variable
        "password": passwordController.text,
      };

      // Print the request body to see the data going to the server
      if (kDebugMode) {
        print("Request Body: $requestBody");
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Print the response body to see the data returned from the server
      if (kDebugMode) {
        print("Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Print the response data
        if (kDebugMode) {
          print("Response Data: $responseData");
        }

        // Show success dialog
        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Column(
              children: [
                Image.asset(
                  "assets/icons/tick.png", // Replace with actual logo asset
                  height: 70,
                ),
                SizedBox(height: 10),
                Text(
                  'Success',
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your password was successfully changed!',
                  textAlign: TextAlign.center,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            actions: [
              CustomButton(
                title: 'Continue',
                onPress: () {
                  //Get.offAll(LoginView());
                  // You can navigate to another screen here
                },
              ),
            ],
          ),
        );
      } else {
        EasyLoading.showError("An error occurred: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: $e");
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
