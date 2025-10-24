
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileImageController extends GetxController {
  RxnString pickedImagePath = RxnString();

  Future<void> pickImage() async {
    PermissionStatus status;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedImagePath.value = image.path;
    } else {
      Get.snackbar("No Image Selected", "Please select an image from gallery");
    }

    if (GetPlatform.isAndroid) {
      if (await Permission.photos.isGranted || await Permission.photos.isLimited) {
        status = PermissionStatus.granted;
      } else {
        status = await Permission.photos.request();
      }

      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImagePath.value = image.path;
      }
    } else {
      Get.snackbar('Permission denied', 'Cannot access gallery without permission.');
    }
  }
}
