import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/image_controller.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage({super.key});

  final ProfileImageController controller = Get.put(ProfileImageController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            return Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: controller.pickedImagePath.value != null
                      ? FileImage(File(controller.pickedImagePath.value!))
                      : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
          Positioned(
            bottom: -10,
            right: -10,
            child: GestureDetector(
              onTap: () async {
                print("--------------------Camera button tapped");
                await controller.pickImage();
              },
              child: Container(
                width: 43,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  // color: boldVividRed,
                ),
                child: Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      "assets/images/camera.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
