import 'package:get/get.dart';

class RatingController extends GetxController {
  var rating = 0.obs; // Rating is initially 0 (no stars selected)
  var details = ''.obs; // Details (TextField) content

  // Method to update the rating
  void setRating(int value) {
    rating.value = value;
  }

  // Method to update the details text
  void setDetails(String value) {
    details.value = value;
  }
}
