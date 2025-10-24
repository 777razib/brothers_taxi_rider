import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../../../core/services_class/shared_preferences_helper.dart';
import '../model/ride_history_model.dart';

class RideHistoryController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var rideHistoryList = <RideHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRideHistory();
  }

  /// Fetch Ride History
  Future<void> fetchRideHistory() async {
    isLoading.value = true;
    errorMessage.value = "";
    EasyLoading.show(status: "Fetching ride history...");

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "Access token not found. Please login.";
        EasyLoading.showError(errorMessage.value);
        return;
      }

      Map<String, String> headers = {
        "Authorization": token,
        "Content-Type": "application/json",
      };

      NetworkResponse response = await NetworkCall.getRequest(
        url: NetworkPath.myRidesHistory,
      );

      if (response.isSuccess) {
        final data = response.responseData?["data"];
        if (data != null && data is List) {
          rideHistoryList.value =
              data.map((e) => RideHistoryModel.fromJson(e)).toList();
        } else {
          rideHistoryList.clear();
        }
        EasyLoading.showSuccess("Ride history fetched successfully");
      } else {
        errorMessage.value =
            response.errorMessage ?? "Failed to load ride history";
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
