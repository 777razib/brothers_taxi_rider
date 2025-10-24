import 'package:get/get.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/panding_model.dart';

class MyRidePendingApiController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var carTransportModel = <CarTransportModel>[].obs; // Changed to RxList for list response

  Future<void> myRidePendingApiController() async {
    try {
      isLoading.value = true;
      NetworkResponse response =
      await NetworkCall.getRequest(url: Urls.carTransportsMyRidesPending);
      if (response.isSuccess) {
        final data = response.responseData!['data'] as List<dynamic>;
        carTransportModel.value =
            data.map((json) => CarTransportModel.fromJson(json)).toList(); // Assign parsed list
        await AuthController.accessToken;
        AuthController.saveUserId(carTransportModel[0].id!);
        errorMessage.value = '';
      } else {
        errorMessage.value = response.errorMessage ?? 'Unknown error';
        print("API Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Exception in myRidePendingApiController: $e"); // Updated error message
    } finally {
      isLoading.value = false;
    }
  }
}