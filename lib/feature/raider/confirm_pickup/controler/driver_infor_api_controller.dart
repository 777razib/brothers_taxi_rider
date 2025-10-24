import 'package:get/get.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../model/rider_driver_info_model.dart';

class DriverInfoApiController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var rideData = Rx<RiderDriverInfoModel?>(null);

  Future<void> driverInfoApiMethod(String id) async {
    print("🚀 [DriverInfoApiController] Starting driverInfoApiMethod with ID: $id");

    if (id.isEmpty) {
      errorMessage.value = 'Transport ID is empty. Please provide a valid ID.';
      print("⚠️ [Error] Transport ID is empty");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final url = Urls.carTransportsSingle(id);
      print("🌍 [Request] GET => $url");

      NetworkResponse response = await NetworkCall.getRequest(url: url);
      print("📥 [Response] Status: ${response.statusCode}, Success: ${response.isSuccess}");

      if (!response.isSuccess || response.statusCode != 200) {
        errorMessage.value = response.errorMessage ??
            'Request failed with status code: ${response.statusCode}';
        rideData.value = null;
        print("❌ [Error] ${errorMessage.value}");
        return;
      }

      final responseData = response.responseData;
      if (responseData == null || responseData['data'] == null) {
        errorMessage.value = 'No data field found in API response.';
        rideData.value = null;
        print("⚠️ [Warning] Missing data in response.");
        return;
      }

      final data = responseData['data'];
      Map<String, dynamic>? rideJson;

      if (data is Map<String, dynamic>) {
        rideJson = data;
      } else if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
        rideJson = data[0];
      }

      if (rideJson == null) {
        errorMessage.value = 'Invalid ride data format received.';
        rideData.value = null;
        print("⚠️ [Warning] Invalid ride data format.");
        return;
      }

      rideData.value = RiderDriverInfoModel.fromJson(rideJson);

      final driver = rideData.value?.vehicle?.driver;
      if (driver == null) {
        errorMessage.value = 'Driver information missing from the response.';
        print("⚠️ [Warning] Driver info missing.");
      } else {
        print("✅ [Success] Ride Loaded: ID=${rideData.value?.id}, Driver=${driver.fullName}");
      }
    } catch (e, stack) {
      errorMessage.value = 'Unexpected error: ${e.toString()}. Please try again.';
      rideData.value = null;
      print("💥 [Exception] $e");
      print("📜 [StackTrace] $stack");
    } finally {
      isLoading.value = false;
      print("🏁 [DriverInfoApiController] API call completed. Loading: ${isLoading.value}");
    }
  }
}