
import 'package:get/get.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/choose_taxi_model.dart';

class ChooseTaxiApiController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final rideDataList = <RidePlan2>[].obs;

  /// Fetch ride plans assigned to the logged-in user
  Future<void> chooseTaxiApiMethod() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NetworkCall.getRequest(
        url: Urls.carTransportsMyRidePlans,
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData!['data'];

        if (data is List) {
          final parsedList =
          data.map((e) => RidePlan2.fromJson(e)).toList(growable: false);
          rideDataList.assignAll(parsedList);

          await AuthController.getUserData();
          print("✅ ${rideDataList.length} ride plans loaded successfully");

          // Save the first CarTransport ID if available
          if (rideDataList.isNotEmpty &&
              rideDataList[0].carTransport != null &&
              rideDataList[0].carTransport!.isNotEmpty) {

            final firstTransportId = rideDataList[0].carTransport![0].id;

            if (firstTransportId != null && firstTransportId.isNotEmpty) {
              await AuthController.saveCarTransportId(firstTransportId);

              // Retrieve to verify
              final ctID = await AuthController.getCarTransportId();
              print("----🛻 Saved transportId: $firstTransportId");
            }
          }

          for (var plan in rideDataList) {
            print(
                "🛻 RidePlan ID: ${plan.id}, Nearby Drivers: ${plan.nearbyDrivers?.length ?? 0}");
          }
        } else {
          rideDataList.clear();
          print("⚠️ No ride plans found in response data");
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Unknown error occurred';
        print("❌ API Error: ${errorMessage.value}");
      }
    } catch (e, st) {
      errorMessage.value = 'Exception: $e';
      print("🔥 Exception in chooseTaxiApiMethod: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }
}
