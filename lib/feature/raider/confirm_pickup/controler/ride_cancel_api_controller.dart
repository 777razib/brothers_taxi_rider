import 'package:get/get.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/cansele_model.dart';

class RideCancelApiController extends GetxController {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Changed to non-nullable RxBool and initialized properly
  final RxBool isLoading = false.obs;
  CancelRideModel? cancelRideModel;

  final selectedIndex = 0.obs;
  // Observable to hold the selected cancellation reason text
  final selectedReasonTitle = ''.obs;

  // Map to hold all possible reasons
  final Map<int, String> cancellationReasons = {
    1: "Selected wrong pick-up",
    2: "Selected wrong drop-off ",
    3: "Requested by accident",
    4: "Wait time was too long",
    5: "Requested wrong vehicle",
    6: "Other",
  };

  void selectContainerEffect(int index) {
    selectedIndex.value = index;
    selectedReasonTitle.value = cancellationReasons[index] ?? '';
  }

  Future<bool> rideCancelApiMethod(String id, String reason) async {
    bool isSuccess = false;
    isLoading.value = true;
    Map<String, dynamic> mapBody = {
      "cancelReason": reason
    };
    NetworkResponse response = await NetworkCall.patchRequest(
        url: Urls.riderRideCancel(id), body: mapBody);

    if (response.isSuccess) {
      await CancelRideModel.fromJson(response.responseData!['data']);
      await AuthController.accessToken;
      _errorMessage = null;
      isSuccess = true;
    } else {
      _errorMessage = response.errorMessage;
    }
    isLoading.value = false;
    return isSuccess;
  }
}

void changeSheet(int sheetNumber) {
  // Basic navigation/state change logic
  print("Changing to sheet $sheetNumber");
  if (sheetNumber == 2) {
    Get.back(); // Close the bottom sheet (or navigate back)
  }
}