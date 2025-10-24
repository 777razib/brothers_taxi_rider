import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CostCalculateController extends GetxController {
  final String apiKey = 'AIzaSyATkpZxtsIVek6xHnGRsse_i4yVEofqQbI';

  var pickPredictions = <Map<String, dynamic>>[].obs;
  var selectPickAddress = ''.obs;
  var pickLat = 0.0.obs;
  var pickLong = 0.0.obs;
  var isPickLoading = false.obs;
  final TextEditingController searchPickController = TextEditingController();

  // desination add location address screen//
  var destPredictions = <Map<String, dynamic>>[].obs;

  var selectDestAddress = ''.obs;
  var destLat = 0.0.obs;
  var destLong = 0.0.obs;
  var isDestLoading = false.obs;
  final TextEditingController searchDestController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchPickController.addListener(() {
      // শুধু তখনই update হবে যদি user টাইপ করে
      if (searchPickController.text != selectPickAddress.value) {
        selectPickAddress.value = searchPickController.text;
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

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
        pickPredictions.value = List<Map<String, dynamic>>.from(
          data['predictions'],
        );
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
      Position? position = await getCurrentPickLocation();
      if (position == null) {
        Get.snackbar('Error', 'Could not get current location');
        return;
      }
      double lat = position.latitude;
      double lng = position.longitude;

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
          searchPickController.text = address; // TextField-এ set
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

  Future<Position?> getCurrentPickLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  void searchDestPlaces(String input) async {
    if (input.isEmpty) {
      destPredictions.clear();
      selectDestAddress.value = '';
      destLat.value = 0.0;
      destLong.value = 0.0;
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=geocode';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        destPredictions.value = List<Map<String, dynamic>>.from(
          data['predictions'],
        );
      } else {
        destPredictions.clear();
      }
    } else {
      destPredictions.clear();
    }
  }

  Future<void> selectDestPlace(String placeId, String description) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        selectDestAddress.value = result['formatted_address'];
        destLat.value = result['geometry']['location']['lat'];
        destLong.value = result['geometry']['location']['lng'];

        // Set the text of the search box to the selected address
        searchDestController.text = selectDestAddress.value;

        destPredictions.clear();
      }
    }
  }

  void clearDestLocation() {
    selectDestAddress.value = '';
    destLat.value = 0.0;
    destLong.value = 0.0;
    destPredictions.clear();
    searchDestController.clear();
  }

  Future<void> useCurrentDestLocation() async {
    try {
      isDestLoading.value = true;

      final position = await getCurrentDestLocation();
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

          selectDestAddress.value = address;
          destLat.value = lat;
          destLong.value = lng;
          searchDestController.text = address;
          destPredictions.clear();
        } else {
          Get.snackbar('Error', 'Failed to get address from coordinates');
        }
      } else {
        Get.snackbar('Error', 'Failed to get address from API');
      }
    } finally {
      isDestLoading.value = false;
    }
  }

  Future<Position?> getCurrentDestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
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
