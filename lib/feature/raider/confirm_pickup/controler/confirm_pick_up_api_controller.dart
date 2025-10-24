import 'package:get/get.dart';

import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';

class ConfirmPickUpApiController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<bool> confirmPickUpApiCallMethod(
      String ridePlanId,
      String selectedVehicleId,
      ) async {
    isLoading.value = true;
    errorMessage.value = ''; // Clear previous error
    bool isSuccess = false;

    try {
      final mapBody = {

          "ridePlanId": ridePlanId,
          "vehicleId": selectedVehicleId
        // Changed from vehicleId to match UI arg
      };

      print("ConfirmPickUpAPIController: Calling API (POST to ${Urls.carTransportsCreate}). Body: $mapBody");

      final response = await NetworkCall.postRequest(
        url: Urls.carTransportsCreate,
        body: mapBody,
      );

      print("ConfirmPickUpAPIController: API Response - Status: ${response.statusCode}, Body: ${response.responseData}");

      if (response.isSuccess) {
        print("ConfirmPickUpAPIController: Ride confirmed successfully via API. Status: ${response.statusCode}");
        isSuccess = true;
        await AuthController.getUserData();
      } else {
        String apiErrorMessage = "Failed to confirm ride. Please try again.";
        if (response.responseData != null && response.responseData is Map) {
          apiErrorMessage = response.responseData!['message'] as String? ?? apiErrorMessage;
        }
        errorMessage.value = apiErrorMessage;
        print("ConfirmPickUpAPIController: API Error. Status: ${response.statusCode}, Message: ${errorMessage.value}, Full Response: ${response.responseData}");
      }
    } catch (e) {
      errorMessage.value = "An exception occurred during ride confirmation: ${e.toString()}";
      print("ConfirmPickUpAPIController: Exception - ${errorMessage.value}");
    } finally {
      isLoading.value = false;
    }

    return isSuccess;
  }
}