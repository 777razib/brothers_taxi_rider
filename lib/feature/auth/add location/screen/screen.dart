import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../bottom_nav_user/controller/bottom_nav_user_controller.dart';
import '../../../bottom_nav_user/screen/bottom_nav_user.dart';
import '../widget/background_image_for_location.dart';

class AddLocationScreen extends StatelessWidget {
   AddLocationScreen({super.key});
  final BottomNavUserController bottomNavUserController=Get.put(BottomNavUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageForLocation(
        child: SafeArea(
          child: Stack(
            children: [
              /// Close Button
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Get.offAll(() => BottomNavbarUser());
                  },
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF9F8FA)),
                    ),
                    child: const Icon(Icons.close, color: Colors.black),
                  ),
                ),
              ),

              /// Content Section
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 290),
                      Expanded(
                        // ✅ Now inside Column
                        child: Text(
                          "We need to know your location in order to suggest nearby stations",
                          style: globalTextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 166,
                        width: 327,
                        child: Column(
                          children: [
                            CustomButton(
                              title: "Use Current Location",
                              onPress: () {
                                Get.offAll(() => BottomNavbarUser());
                              },
                              borderColor: Color(0xFFEDEDF3),
                            ),
                            /*SizedBox(height: 16),
                            CustomButton(
                              title: "Enter a new address",
                              onPress: () {},
                              borderColor: Color(0xFFEDEDF3),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
