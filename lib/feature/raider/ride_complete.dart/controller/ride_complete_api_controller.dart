import 'package:get/get.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../confirm_pickup/model/rider_driver_info_model.dart';

class RideCompleteApiController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var rideData = Rx<RiderDriverInfoModel?>(null);

  Future<void> redeConpleteApiMethod(String id) async {
    print("Calling driverInfoApiMethod with transportId: $id");
    try {
      if (id.isEmpty) {
        errorMessage.value = 'Transport ID is empty';
        print("Error: Transport ID is empty");
        return;
      }
      isLoading.value = true;
      errorMessage.value = ''; // Clear previous errors
      final url = Urls.carTransportsCompleted(id);
      print("API Request URL: $url");

      NetworkResponse response = await NetworkCall.getRequest(url: url);
      print("API Response - Status: ${response.isSuccess}");

      if (response.isSuccess && response.responseData?['data'] != null) {
        final data = response.responseData?['data'];
        Map<String, dynamic>? rideJson;

        if (data is Map<String, dynamic>) {
          rideJson = data;
        } else if (data is List<dynamic> && data.isNotEmpty) {
          // Handle case where 'data' is a list of rides, use the first one
          rideJson = data[0] as Map<String, dynamic>;
        }

        if (rideJson != null) {
          rideData.value = RiderDriverInfoModel.fromJson(rideJson);
          // ✅ Driver access confirmed as rideData.value?.vehicle?.driver
          final driver = rideData.value?.vehicle?.driver;

          if (driver == null) {
            errorMessage.value = 'Driver info is missing in the ride data.';
            print("Error: Driver info (vehicle.driver) is missing.");
          } else {
            print("Ride Data Loaded: ID=${rideData.value?.id}, Driver=${driver.fullName}");
          }
        } else {
          errorMessage.value = 'Invalid or empty response data format.';
          print("Invalid response data format.");
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'No data field in response or API error';
        print("API Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = 'Exception: ${e.toString()}';
      print("Exception in driverInfoApiMethod: $e");
    } finally {
      isLoading.value = false;
      print("API call completed, isLoading: ${isLoading.value}");
    }
  }
}