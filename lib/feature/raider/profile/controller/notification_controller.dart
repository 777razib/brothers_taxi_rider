import 'package:get/get.dart';

class NotificationController extends GetxController {
  RxBool isSwitchOn = false.obs;

  void toggleSwitch() {
    isSwitchOn.value = !isSwitchOn.value;
  }
}

