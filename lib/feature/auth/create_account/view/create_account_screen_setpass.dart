/*
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:naderhosn/core/global_widegts/custom_button.dart';
import 'package:naderhosn/core/global_widegts/custom_text_field.dart';
import 'package:naderhosn/core/style/global_text_style.dart';
import 'package:naderhosn/feature/auth/create_account/controller/create_account_controller.dart';

class CreateAccountScreenSetpass extends StatelessWidget {
  CreateAccountScreenSetpass({super.key});

  final CreateAccountController controller = Get.put(CreateAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 100,
          bottom: 50,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              "assets/icons/authicon.png", // Replace with actual logo asset
              height: 110,
            ),
            const SizedBox(height: 20),

            // Welcome Text
            Text(
              "Set Password",
              style: globalTextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // // Email/Phone Field using CustomTextField
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "User name",
            //     style: globalTextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 5),
            // CustomTextField(
            //   hintText: "Tyson mac",
            //   controller: controller.userNameController,
            // ),
            // const SizedBox(height: 16),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "Phone",
            //     style: globalTextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 5),
            // // Password Field using CustomTextField
            // CustomTextField(
            //   hintText: "Enter number",
            //   controller: controller.emailController,
            // ),
            // const SizedBox(height: 16),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "Email",
            //     style: globalTextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 5),
            // // Password Field using CustomTextField
            // CustomTextField(
            //   hintText: "Enter email",
            //   controller: controller.emailController,
            // ),
            // const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),
            //Password Field using CustomTextField
            Obx(
              () => CustomTextField(
                hintText: "Enter your password",
                controller: controller.setPasswordController,
                obscureText: controller.isPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    controller.isPasswordHidden.value =
                        !controller.isPasswordHidden.value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Spacer(),
            const SizedBox(height: 10),
            CustomButton(
              title: 'Continue',
              onPress: () {
                controller.createAccountPassword();
              },
            ),

            const SizedBox(height: 20),

            // Sign Up Link
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const Text("I don’t have an account?"),
            //     TextButton(
            //       onPressed: () {
            //         // Navigate to sign-up screen
            //         Get.to(());
            //       },
            //       child: Text(
            //         "Sign up",
            //         style: globalTextStyle(color: Color(0xffd90000)),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
*/
