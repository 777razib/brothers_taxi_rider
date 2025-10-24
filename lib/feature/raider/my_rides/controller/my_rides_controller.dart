import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../model/my_ride_model.dart';
import '../model/ride_history_model.dart';

class RideControllers extends GetxController {
  // Observable variables
  var rides = <RideData>[].obs;
  var rideHistory = <Ride>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var currentTabIndex = 0.obs;

  /// Fetch rides from API
  Future<void> fetchRides() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = AuthController.accessToken;

      if (token == null) {
        errorMessage.value = "No access token found. Please log in again.";
        return;
      }

      var url = Uri.parse(
          '${Urls.baseUrl}/carTransports/my-rides');

      var headers = {'Authorization': token};

      var response = await http.get(url, headers: headers);

      print(response.request?.url);
      print(response.body);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        MyRideModel myRideModel = MyRideModel.fromJson(jsonData);
        rides.value = myRideModel.data;
      } else {
        errorMessage.value =
        'Failed to fetch rides: ${response.statusCode} ${response.reasonPhrase}';
      }
    } catch (e) {
      errorMessage.value = 'No rides found on screen';
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchRideHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {

      final token = AuthController.accessToken;

      if (token == null) {
        errorMessage.value = "No access token found. Please log in again.";
        return;
      }

      final url = Uri.parse('${Urls.baseUrl}/carTransports/my-rides-history');
      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          RideHistoryModel rideHistoryModel = RideHistoryModel.fromJson(jsonData);
          rideHistory.value = rideHistoryModel.data;
        } else {
          errorMessage.value = 'No rides found on screen';
        }
      } else {
        errorMessage.value = 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

}
