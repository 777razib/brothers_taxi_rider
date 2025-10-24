import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/style/global_text_style.dart';
import '../../login/view/login_view.dart';
import '../controller/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            children: [
              OnboardingPage(image: "assets/images/onboard1.png"),
              OnboardingPage(image: "assets/images/onboard2.png"),
              OnboardingPage(image: "assets/images/onboard3.png"),
            ],
          ),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Image.asset(
                        "assets/images/back_button.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => LoginView()),
                    child: Text(
                      "Skip here",
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(1),
                      _buildIndicator(2),
                      _buildIndicator(3),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: controller.onNextPage,
                    child: Image.asset(
                      "assets/images/next_button.png",
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          index.toString(),
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: controller.currentPage.value + 1 == index
                ? Colors.amber
                : Colors.white60,
          ),
        ),
      );
    });
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;

  const OnboardingPage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [Image.asset(image, fit: BoxFit.cover)],
    );
  }
}
