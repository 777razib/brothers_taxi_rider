import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../../core/global_widegts/custom_button.dart';

class ProfileController extends GetxController {
  var profileImage = Rx<File?>(null);

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }
}

class SetupProfile extends StatelessWidget {
  SetupProfile({super.key});

  // Initialize the ProfileController
  final ProfileController updateController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   iconTheme: const IconThemeData(color: Colors.black87),
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 92, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Profile info",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 21),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Please provide your name and an optional profile photo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 42),

            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    return CircleAvatar(
                      radius: 64,
                      backgroundImage:
                          updateController.profileImage.value != null
                          ? FileImage(updateController.profileImage.value!)
                          : null, // Remove the asset image part
                      child: updateController.profileImage.value == null
                          ? Icon(
                              Icons.account_circle,
                              size: 64,
                              color: Colors
                                  .grey, // Set the color of the default icon
                            )
                          : null,
                    );
                  }),

                  Positioned(
                    bottom: 10,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          updateController.pickImage();
                          // If you need to navigate after image pick, uncomment and adjust:
                          // Get.to(() => NextScreen());
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type your name here",
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(children: const [SizedBox(width: 16)]),
            const Spacer(),
            CustomButton(
              title: "Next",
              onPress: () {
                // Handle the next button press logic
                // Get.to(AddEmailScreenOne());
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
