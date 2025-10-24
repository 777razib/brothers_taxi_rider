/*
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:naderhosn/core/global_widegts/custom_button.dart';
import 'package:naderhosn/core/network_caller/endpoints.dart';
import 'package:naderhosn/core/shared_preference/shared_preferences_helper.dart';
import 'package:naderhosn/core/style/global_text_style.dart';
import 'package:naderhosn/feature/auth/phone_email_verification_code_create_account/view/phone_email_verification_code_create_account.dart';

class CreateAccountController extends GetxController {
  var isPasswordHidden = false.obs;
  var passwordController = TextEditingController();
  var isChecked = false.obs;
  var userNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var setPasswordController = TextEditingController();
  String email = '';
  @override
  void onInit() {
    super.onInit();
    // Fetch email from arguments
    email = Get.arguments?['email'] ?? '';
  }

  Future<void> createAccount() async {
    final url = Uri.parse('${Urls.baseUrl}/users/otp');

    try {
      EasyLoading.show(status: 'Loading...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": userNameController.text,
          "phone": phoneController.text,
          "email": emailController.text,
        }),
      );

      if (kDebugMode) {
        print("//////////The response for sign up is: ${response.body}");
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Registered successfully");
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          print(response.body);
          Get.offAll(
            () => OtpVerificationCreateAccountView(),
            arguments: {'email': emailController.text},
          );
        }
      }
      if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        responseData["message"];
        EasyLoading.showError("Account already exist");
        print(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("///////////////An error occurred: $e");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> createAccountPassword() async {
    final url = Uri.parse('${Urls.baseUrl}/users/create-pass');

    try {
      EasyLoading.show(status: 'Loading...');

      // Create request body
      final requestBody = {
        "email": email,
        "password": setPasswordController.text,
      };

      // Print the request body before sending the request
      if (kDebugMode) {
        print("//////////Request Body: $requestBody");
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Print the response body to see what is returned from the server
      if (kDebugMode) {
        print("//////////Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Password created successfully");
        final responseData = jsonDecode(response.body);

        // Print response data
        if (kDebugMode) {
          print("Response Data: $responseData");
        }

        // Extract the token from the response
        String? token = responseData['data']['token'];

        // Save the token to shared preferences
        if (token != null) {
          await SharedPreferencesHelper.saveToken(token);
          print("Token saved successfully!");
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
                  "Your account is successfully created!",
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
                  // Get.offAll(BottomNavbar());
                },
              ),
            ],
          ),
        );
      } else {
        // Handle response other than 200 status code
        EasyLoading.showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: $e");
      if (kDebugMode) {
        print("///////////////An error occurred: $e");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
*/
