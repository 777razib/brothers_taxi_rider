import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/global_widegts/custom_text_field.dart';
import '../../../../core/style/global_text_style.dart';
import '../controller/set_password_controller.dart';

// import 'package:flutter/material.dart';

class SetPasswordScreen extends StatelessWidget {
  SetPasswordScreen({super.key});
  final SetPasswordController controller = Get.put(SetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 100, bottom: 50),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CustomBackButton(),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set new password",
                      style: globalTextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        "Create your new password so you can share your memories again",
                        style: globalTextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 55),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "New password",
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5),
            Obx(
              () => CustomTextField(
                hintText: "Enter your password",
                controller: controller.passwordController,
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
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Confirm password",
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Obx(
              () => CustomTextField(
                hintText: "Enter your password",
                controller: controller.confirmpasswordController,
                obscureText: controller.isConfirmPasswordHidden.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    controller.isConfirmPasswordHidden.value =
                        !controller.isConfirmPasswordHidden.value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            const Spacer(),
            CustomButton(
              title: 'Change password',
              onPress: () {
                controller.setpassword();
              },
            ),
          ],
        ),
      ),
    );
  }
}
