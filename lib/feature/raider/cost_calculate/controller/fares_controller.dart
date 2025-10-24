import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../../../core/services_class/shared_preferences_helper.dart';
import '../model/fare_model.dart';

class FaresController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var currentFare = Rxn<FareModel>();

  /// Get current fare
  Future<void> getCurrentFare() async {
    isLoading.value = true;
    errorMessage.value = "";
    EasyLoading.show(status: "Fetching current fare...");

    try {
      // Get token from SharedPreferences
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = "Access token not found. Please login.";
        EasyLoading.showError(errorMessage.value);
        return;
      }

      NetworkResponse response = await NetworkCall.getRequest(
        url: NetworkPath.getCurrentFare,
        // now it works
      );


      if (response.isSuccess) {
        currentFare.value = FareModel.fromJson(response.responseData!["data"]);
        EasyLoading.showSuccess("Fare retrieved successfully");
      } else {
        errorMessage.value = response.errorMessage ?? "Failed to load fare";
        EasyLoading.showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
      EasyLoading.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
