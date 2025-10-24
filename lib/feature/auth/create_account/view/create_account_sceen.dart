/*
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:naderhosn/core/global_widegts/custom_text_field.dart';
import 'package:naderhosn/core/style/global_text_style.dart';
import 'package:naderhosn/feature/auth/create_account/controller/create_account_controller.dart';
import 'package:naderhosn/feature/auth/login/view/login_view.dart';

class CreateAccountSceen extends StatelessWidget {
  CreateAccountSceen({super.key});
  final CreateAccountController controller = Get.put(CreateAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(4), // Add circular radius
                child: Image.asset(
                  "assets/icons/authicon.png", // Replace with actual logo asset
                  height: 56,
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Welcome Text
              Text(
                "Welcome!",
                style: globalTextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Access your documents anytime, anywhere with AI-powered organization.",
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff636F85),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              // Email/Phone Field using CustomTextField
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Full Name",
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Tyson mac",
                controller: controller.userNameController,
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PIN",
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Password Field using CustomTextField
              Obx(
                () => CustomTextField(
                  hintText: "Enter your password",
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      controller.isPasswordHidden.value =
                          !controller.isPasswordHidden.value;
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confirm PIN",
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Password Field using CustomTextField
              Obx(
                () => CustomTextField(
                  hintText: "Enter your password",
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      controller.isPasswordHidden.value =
                          !controller.isPasswordHidden.value;
                    },
                  ),
                ),
              ),
              SizedBox(height: 36),
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.isChecked.value,
                      onChanged: (value) {
                        controller.isChecked.value = value ?? false;
                      },
                      activeColor: Color(0xFF6056DD),
                    ),
                  ),
                  SizedBox(width: 5),

                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'I agree to FileflowAI ',
                            style: globalTextStyle(
                              fontSize: 12,
                              color: Color(0xFFA7A7A7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms of Service ',
                            style: globalTextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6F61),
                              fontWeight: FontWeight.w400,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(
                                  () => (),
                                ); // Navigate to Terms of Service screen
                              },
                          ),
                          TextSpan(
                            text: '& ',
                            style: globalTextStyle(
                              fontSize: 12,
                              color: Color(0xFFA7A7A7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: globalTextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6F61),
                              fontWeight: FontWeight.w400,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(
                                  () => (),
                                ); // Navigate to Terms of Service screen
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CustomButton2(
              //   title: 'Sign Up',
              //   onPress: () {
              //     //controller.createAccount();
              //   },
              // ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign-up screen
                      Get.off(LoginView());
                    },
                    child: Text(
                      "Sign In",
                      style: globalTextStyle(
                        color: Color(0xff6056DD),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
