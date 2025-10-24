import 'package:get/get.dart';

class BottomNavUserController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
  void homepage() {
    currentIndex.value = 0;
  }
}
