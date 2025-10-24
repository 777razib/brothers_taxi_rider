import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../location_picker/controller/location_picker_controller.dart';
import '../model/fare_model.dart';
import '../model/calculated_fare_model.dart';

class FareController extends GetxController {
  var isLoading = false.obs;
  var fare = Rxn<FareModel>();
  var calculatedFare = Rxn<CalculatedFareModel>();
  final LocationPickerController locationPickerController = Get.put(LocationPickerController());

  Future<void> fetchFareData(String token) async {
    if (token.isEmpty) {
      Get.snackbar("Error", "Authentication token is missing");
      print("❌ Token is empty");
      return;
    }

    try {
      isLoading.value = true;
      print("🔄 Fetching fare data with token: $token");

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/estimateFares/getMyEstimatelist"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
      );

      print("📡 API Status: ${response.statusCode}");
      print("📥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey("data")) {
          final fareList = data["data"] as List<dynamic>;
          if (fareList.isNotEmpty) {
            fare.value = FareModel.fromJson(fareList.first);
            print("✅ Fare data loaded: ${fare.value?.baseFare}");
          } else {
            print("❌ No fare data found in response");
            Get.snackbar("Error", "No fare data available");
          }
        } else {
          print("❌ Invalid data format received: $data");
          Get.snackbar("Error", "Invalid fare data format");
        }
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized: Invalid or expired token");
        Get.snackbar("Error", "Session expired. Please log in again.");
        Get.offAllNamed('/login'); // Navigate to LoginView
      } else {
        print("❌ Failed to load fare data: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load fare data: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in fetchFareData: $e");
      Get.snackbar("Error", "Unable to load fare data. Please try again.");
    } finally {
      isLoading.value = false;
      print("✅ Fetch completed");
    }
  }

  Future<Map<String, dynamic>?> calculateFare({
    required String pickup,
    required String dropOff,
    required double pickupLat,
    required double pickupLng,
    required double dropOffLat,
    required double dropOffLng,
  }) async {
    final token = AuthController.accessToken;
    if (token == null || token.isEmpty) {
      print("❌ Token is null or empty");
      Get.snackbar("Error", "Please log in to calculate fare");
      Get.offAllNamed('/login'); // Navigate to LoginView
      return null;
    }

    try {
      isLoading.value = true;
      print("🔄 Calculating fare with backend...");

      final url = Uri.parse('${Urls.baseUrl}/estimateFares/calculate-fare');
      final headers = <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "pickup": pickup,
        "dropOff": dropOff,
        "pickupLat": pickupLat,
        "pickupLng": pickupLng,
        "dropOffLat": dropOffLat,
        "dropOffLng": dropOffLng,
      });

      print("📤 Sending data: $body");

      final response = await http.post(url, headers: headers, body: body);

      print("📡 API Status: ${response.statusCode}");
      print("📥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Fare calculated successfully");
        print("📊 Response data: $data");

        if (data is Map<String, dynamic> && data.containsKey("data")) {
          final fareData = data["data"] as Map<String, dynamic>;
          calculatedFare.value = CalculatedFareModel.fromJson(fareData);
          print("✅ Calculated fare parsed: ${calculatedFare.value?.totalFare}");
          return data;
        } else {
          print("❌ Invalid response structure: $data");
          Get.snackbar("Error", "Invalid fare calculation response");
          return null;
        }
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized: Invalid or expired token");
        Get.snackbar("Error", "Session expired. Please log in again.");
        Get.offAllNamed('/login');
        return null;
      } else {
        print('❌ Error: ${response.statusCode}');
        Get.snackbar("Error", "Failed to calculate fare: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in calculateFare: $e");
      Get.snackbar("Error", "Unable to calculate fare. Please try again.");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  double calculateDistance(
      double pickupLat,
      double pickupLng,
      double dropLat,
      double dropLng,
      ) {
    double distanceInMeters = Geolocator.distanceBetween(
      pickupLat,
      pickupLng,
      dropLat,
      dropLng,
    );
    double distanceKm = distanceInMeters / 1000;
    print("📏 Distance: $distanceKm km");
    return distanceKm;
  }

  double calculateTotalFare(
      double distanceKm, {
        int durationMinutes = 0,
        int waitingMinutes = 0,
      }) {
    if (fare.value == null) {
      print("⚠️ Fare data is null, returning 0");
      Get.snackbar("Error", "Fare data not available");
      return 0.0;
    }

    final f = fare.value!;
    double distanceFare = f.costPerKm * distanceKm;
    double timeFare = f.costPerMin * durationMinutes;
    double waitingFare = f.waitingPerMin * waitingMinutes;

    double total = f.baseFare + distanceFare + timeFare + waitingFare;

    if (total < f.minimumFare) {
      total = f.minimumFare;
    }

    print("""
    🔎 Fare Calculation:
    Base Fare: ${f.baseFare}
    Distance Fare: $distanceFare
    Time Fare: $timeFare
    Waiting Fare: $waitingFare
    👉 Total Fare: $total
    """);

    return total;
  }
}