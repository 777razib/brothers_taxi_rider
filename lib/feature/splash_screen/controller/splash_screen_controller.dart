

import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../core/services_class/shared_preferences_data_helper.dart';
import '../../auth/login/view/login_view.dart';
import '../../auth/onboarding/view/onboarding.dart';
import '../../bottom_nav_user/screen/bottom_nav_user.dart';

class SplashScreenController extends GetxController {
  Future<void> checkIsLogin() async {
    // 1. Get the login status (bool) and the token (String?) upfront
    bool isLogin = await AuthController.isUserLogin();
    var token = AuthController.accessToken; // Should be String?

    // Wait for the splash screen duration
    Timer(const Duration(seconds: 3), () async {

      print("Token is :---------------- $token");

      // 2. Check if user is logged in AND the token string is not null
      if (isLogin && token != null) {
        Get.offAll(() => BottomNavbarUser());
      } else if (isLogin && token == null) {
        Get.offAll(() => LoginView());
        EasyLoading.showToast("Your session has expired. Please log in again.");
        return;
      }else {
        // If 'isLogin' is false, or if token is null for some reason, navigate to Onboarding.
        Get.offAll(() => OnboardingScreen());
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    // This will start the check when the controller is initialized
    checkIsLogin();
  }
}


