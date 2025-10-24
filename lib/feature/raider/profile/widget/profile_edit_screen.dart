import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../controller/profile_edit_controller.dart';

class ProfileEditScreen extends StatefulWidget {
  ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  var updateProfileController = Get.find<UpdateProfileController>();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final profile = await updateProfileController.fetchMyProfile();
    if (profile?.profileImage != null) {
      updateProfileController.fullNameController.text = profile!.fullName ?? '';
      updateProfileController.emailController.text = profile!.email ?? '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Obx(() {
              final profileImage = updateProfileController.userData.value?.profileImage ?? '';
              final selectedImage = updateProfileController.selectedImage.value;

              return Center(
                child: GestureDetector(
                  onTap: updateProfileController.pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage)
                        : (profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                  ),
                ),
              );
            }),


            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: updateProfileController.fullNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Name",
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),

            // Email Field
            TextFormField(
              controller: updateProfileController.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Email",
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const Spacer(),

            CustomButton(
              title: "Save",
              backgroundColor: const Color(0xFfFFDC71),
              borderColor: Colors.transparent,
              onPress: () async {
                updateProfileController.updateUserProfile();
              },
            ),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

}
