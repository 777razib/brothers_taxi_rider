
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network_caller/endpoints.dart';
import 'package:flutter_google_maps_webservices/places.dart' as places;


class LocationPickerController extends GetxController {
  final String apiKey = '${Urls.googleApiKey}';

  // --- PICKUP Location Variables ---
  var pickPredictions = <Map<String, dynamic>>[].obs;
  var selectPickAddress = ''.obs;
  var pickLat = 0.0.obs;
  var pickLong = 0.0.obs;
  var isPickLoading = false.obs;
  final TextEditingController searchPickController = TextEditingController();

  // --- DROP-OFF (Destination) Location Variables ---
  var dropOffPredictions = <Map<String, dynamic>>[].obs;
  var selectDropOffAddress = ''.obs;
  var dropOffLat = 0.0.obs;
  var dropOffLong = 0.0.obs;
  var isDropOffLoading = false.obs;
  final TextEditingController searchDropOffController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    searchPickController.dispose();
    searchDropOffController.dispose();
    super.onClose();
  }

  // ====================================================================
  //                          PICKUP METHODS
  // ====================================================================

  void searchPickPlaces(String input) async {
    if (input.isEmpty) {
      pickPredictions.clear();
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=geocode';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        pickPredictions.value = List<Map<String, dynamic>>.from(data['predictions']);
      } else {
        pickPredictions.clear();
      }
    } else {
      pickPredictions.clear();
    }
  }

  Future<void> selectPickPlace(String placeId, String description) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        selectPickAddress.value = result['formatted_address'];

        // Correct key: 'location'
        pickLat.value = result['geometry']['location']['lat'];
        pickLong.value = result['geometry']['location']['lng'];

        searchPickController.text = selectPickAddress.value;
        pickPredictions.clear();
      }
    }
  }

  void clearPickLocation() {
    selectPickAddress.value = '';
    pickLat.value = 0.0;
    pickLong.value = 0.0;
    pickPredictions.clear();
    searchPickController.clear();
  }

  Future<void> useCurrentPickLocation() async {
    try {
      isPickLoading.value = true;

      final position = await _getCurrentLocation();
      if (position == null) {
        Get.snackbar('Error', 'Could not get current location');
        return;
      }

      final lat = position.latitude;
      final lng = position.longitude;

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];

          selectPickAddress.value = address;
          pickLat.value = lat;
          pickLong.value = lng;
          searchPickController.text = address;
          pickPredictions.clear();
        } else {
          Get.snackbar('Error', 'Failed to get address from coordinates');
        }
      } else {
        Get.snackbar('Error', 'Failed to get address from API');
      }
    } finally {
      isPickLoading.value = false;
    }
  }

  // ====================================================================
  //                        DROP-OFF METHODS
  // ====================================================================

  void searchDropOffPlaces(String input) async {
    if (input.isEmpty) {
      dropOffPredictions.clear();
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=geocode';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        dropOffPredictions.value = List<Map<String, dynamic>>.from(data['predictions']);
      } else {
        dropOffPredictions.clear();
      }
    } else {
      dropOffPredictions.clear();
    }
  }

  Future<void> selectDropOffPlace(String placeId, String description) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        selectDropOffAddress.value = result['formatted_address'];

        // Correct key: 'location'
        dropOffLat.value = result['geometry']['location']['lat'];
        dropOffLong.value = result['geometry']['location']['lng'];

        searchDropOffController.text = selectDropOffAddress.value;
        dropOffPredictions.clear();
      }
    }
  }

  void clearDropOffLocation() {
    selectDropOffAddress.value = '';
    dropOffLat.value = 0.0;
    dropOffLong.value = 0.0;
    dropOffPredictions.clear();
    searchDropOffController.clear();
  }

  Future<void> useCurrentDropOffLocation() async {
    try {
      isDropOffLoading.value = true;

      final position = await _getCurrentLocation();
      if (position == null) {
        Get.snackbar('Error', 'Could not get current location');
        return;
      }

      final lat = position.latitude;
      final lng = position.longitude;

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];

          selectDropOffAddress.value = address;
          dropOffLat.value = lat;
          dropOffLong.value = lng;
          searchDropOffController.text = address;
          dropOffPredictions.clear();
        } else {
          Get.snackbar('Error', 'Failed to get address from coordinates');
        }
      } else {
        Get.snackbar('Error', 'Failed to get address from API');
      }
    } finally {
      isDropOffLoading.value = false;
    }
  }

  // ====================================================================
  //                         SHARED LOCATION METHOD
  // ====================================================================

  // Centralized method to handle permission logic
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Service', 'Please enable location services.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission Error', 'Location permissions are permanently denied.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }
}




class PlaceSearchController extends GetxController {
  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var selectedPlace = Rxn<Map<String, dynamic>>();
  TextEditingController controller = TextEditingController();

  final places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(
    apiKey: "AIzaSyATkpZxtsIVek6xHnGRsse_i4yVEofqQbI",
  );

  // Fetch places autocomplete results
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final String searchUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyATkpZxtsIVek6xHnGRsse_i4yVEofqQbI&location=23.685&radius=10000';
    try {
      final response = await http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null) {
          searchResults.value = List<Map<String, dynamic>>.from(
            data['predictions'],
          );
        } else {
          searchResults.clear();
        }
      } else {
        print('Error fetching search results: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching search results: $e');
    }
  }

  // Fetch details of a selected place
  Future<void> fetchPlaceDetails(String placeId) async {
    isLoading.value = true;

    final String detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyATkpZxtsIVek6xHnGRsse_i4yVEofqQbI';
    try {
      final response = await http.get(Uri.parse(detailsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null) {
          final placeDetails = data['result'];
          final placeData = {
            'description': placeDetails['name'],
            'lat': placeDetails['geometry']['location']['lat'],
            'lng': placeDetails['geometry']['location']['lng'],
          };
          updatePlaceDetails(placeId, placeData);
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update the selected place
  void updatePlaceDetails(String placeId, [Map<String, dynamic>? placeData]) {
    selectedPlace.value =
        placeData ??
            {
              'description': 'No description available',
              'lat': 'No latitude',
              'lng': 'No longitude',
            };
  }
}



