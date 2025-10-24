import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/user_data_model.dart';

class UpdateProfileController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  var userData = Rxn<UserDataModel>(); // ✅ Store user profile here

  var selectedImage = Rxn<File>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var errorMessage = ''.obs;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateUserProfile() async {
    try {
      EasyLoading.show(status: "Loading...");

      final url = Uri.parse("${Urls.baseUrl}/users/update-profile");
      final token =  AuthController.accessToken;


      print("=============$token");
      Map<String, String> headers = {
        'Authorization': "$token",
      };

      var request = http.MultipartRequest('PATCH', url);
      request.fields.addAll({
        'data': jsonEncode({
          "fullName": fullNameController.text,
          "email": emailController.text,
        })
      });

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage.value!.path),
        );
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response: $responseBody");

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(responseBody);

        if (jsonRes["success"] == true && jsonRes["data"] != null) {
          final updatedProfile = UserDataModel.fromJson(jsonRes["data"]);

          // ✅ Update observable
          userData.value = updatedProfile;

          // ✅ Update controllers
          fullNameController.text = updatedProfile.fullName;
          emailController.text = updatedProfile.email ?? '';
        }

        EasyLoading.showSuccess("Profile updated successfully");
      } else {
        EasyLoading.showError("Failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
  }

  Future<UserDataModel?> fetchMyProfile() async {
    EasyLoading.show(status: 'Fetching profile...');
    try {
      final token = AuthController.accessToken;
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/users/get-me"),
        headers: {"Authorization": token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes["success"] == true) {
          final model = UserDataModel.fromJson(jsonRes["data"]);

          userData.value = model;

          // ✅ populate controllers
          fullNameController.text = model.fullName;
          emailController.text = model.email ?? '';

          return model;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Fetch profile error: $e");
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

