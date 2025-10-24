import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/const/app_colors.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../model/choose_taxi_model.dart';
import '../model/location_searching_model.dart';
import 'choose_taxi_api_controller.dart';

const String GOOGLE_DIRECTIONS_API_KEY = "${Urls.googleApiKey}";

class ChooseTaxiController extends GetxController {
  final ChooseTaxiApiController apiController = Get.put(ChooseTaxiApiController());

  var isBottomSheetOpen = false.obs;
  var isLoadingMap = true.obs;
  var isLoadingDirections = false.obs;

  var pickupPosition = Rxn<LatLng>();
  var dropOffPosition = Rxn<LatLng>();
  var selectedDriver = Rxn<NearbyDriver>(); // Track selected driver

  var customMarkerIconPickup = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDropOff = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconCar = BitmapDescriptor.defaultMarker.obs;

  var markers = <Marker>{}.obs;
  var polyline = Polyline(
    polylineId: const PolylineId("route_polyline"),
    points: <LatLng>[],
    color: AppColors.polylineColors.isNotEmpty
        ? AppColors.polylineColors[0]
        : Colors.blue,
    width: 5,
  ).obs;

  var currentRidePlan = Rxn<RidePlan2>();

  @override
  void onInit() {
    super.onInit();
    loadAndDisplayRideData();
  }

  Future<void> loadAndDisplayRideData({
    double? initialPickupLat,
    double? initialPickupLng,
    double? initialDropOffLat,
    double? initialDropOffLng,
  }) async {
    isLoadingMap.value = true;
    isLoadingDirections.value = true;
    markers.clear();
    polyline.value = polyline.value.copyWith(pointsParam: []);
    selectedDriver.value = null; // Reset selected driver

    await Future.wait([
      _loadCustomMarker("Pickup", MarkerType.pickup),
      _loadCustomMarker("Drop-off", MarkerType.dropOff),
      _loadCustomMarker("Car", MarkerType.car),
    ]);

    await apiController.chooseTaxiApiMethod();

    if (apiController.errorMessage.value.isNotEmpty) {
      Get.snackbar("Error",
          "Failed to load ride data: ${apiController.errorMessage.value}");
      _resetMapStateToError();
      return;
    }

    if (apiController.rideDataList.isNotEmpty) {
      currentRidePlan.value = apiController.rideDataList.first;
      final ridePlanData = currentRidePlan.value!;

      double pLat = initialPickupLat ?? ridePlanData.pickupLat ?? 0.0;
      double pLng = initialPickupLng ?? ridePlanData.pickupLng ?? 0.0;
      double dLat = initialDropOffLat ?? ridePlanData.dropOffLat ?? 0.0;
      double dLng = initialDropOffLng ?? ridePlanData.dropOffLng ?? 0.0;

      if (pLat != 0.0 && pLng != 0.0) {
        pickupPosition.value = LatLng(pLat, pLng);
        addMapMarker(
            pickupPosition.value!,
            ridePlanData.pickup ?? (initialPickupLat != null ? "Pickup" : "Unknown Pickup"),
            MarkerType.pickup);
      } else {
        pickupPosition.value = null;
        print("Warning: Pickup coordinates are missing or invalid.");
      }

      if (dLat != 0.0 && dLng != 0.0) {
        dropOffPosition.value = LatLng(dLat, dLng);
        addMapMarker(
            dropOffPosition.value!,
            ridePlanData.dropOff ?? (initialDropOffLat != null ? "Drop-off" : "Unknown Drop-off"),
            MarkerType.dropOff);
      } else {
        dropOffPosition.value = null;
        print("Warning: Drop-off coordinates are missing or invalid.");
      }

      if (pickupPosition.value != null && dropOffPosition.value != null) {
        await _getRoutePolyline(
            pickupPosition.value!, dropOffPosition.value!);
      } else {
        updatePolyline([]);
        isLoadingDirections.value = false;
      }

      if (ridePlanData.carTransport != null && ridePlanData.carTransport!.isNotEmpty) {
        for (final car in ridePlanData.carTransport!) {
          if (car.driverLat != null && car.driverLng != null) {
            final LatLng driverPos = LatLng(car.driverLat!, car.driverLng!);
            addMapMarker(
              driverPos,
              car.serviceType ?? 'Car ID: ${car.id ?? "N/A"}',
              MarkerType.car,
              idSuffix: car.id ?? 'car_${DateTime.now().millisecondsSinceEpoch}',
            );
          } else {
            print("Warning: Driver coordinates missing for car transport ${car.id}");
          }
        }
      }

      if (ridePlanData.nearbyDrivers != null && ridePlanData.nearbyDrivers!.isNotEmpty) {
        for (final driver in ridePlanData.nearbyDrivers!) {
          final LatLng driverPos = LatLng(driver.lat, driver.lng);
          addMapMarker(
            driverPos,
            driver.fullName ?? 'Driver ${driver.id}',
            MarkerType.car,
            idSuffix: driver.id,
          );
        }
      } else {
        print("Warning: No nearby drivers available for ride plan ${ridePlanData.id}");
      }
    } else {
      Get.snackbar("Info", "No ride plans found.");
      _resetMapStateToError();
    }
    isLoadingMap.value = false;
  }

  void _resetMapStateToError() {
    isLoadingMap.value = false;
    isLoadingDirections.value = false;
    pickupPosition.value = null;
    dropOffPosition.value = null;
    currentRidePlan.value = null;
    selectedDriver.value = null; // Reset selected driver
    updatePolyline([]);
    markers.clear();
  }

  Future<void> _getRoutePolyline(LatLng origin, LatLng destination) async {
    isLoadingDirections.value = true;
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$GOOGLE_DIRECTIONS_API_KEY";

      print("Directions API URL: $url");

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
          if (result.isNotEmpty) {
            for (var point in result) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
        } else {
          print("Directions API Error: ${data['status']} - ${data['error_message'] ?? 'No routes found'}");
          Get.snackbar("Directions Error", data['error_message'] ?? "Could not fetch route details.");
        }
      } else {
        print("Directions API HTTP Error: ${response.statusCode}");
        Get.snackbar("Directions Error", "Failed to connect to directions service.");
      }
    } catch (e) {
      print("Error fetching directions: $e");
      Get.snackbar("Directions Error", "An error occurred while fetching route: $e");
    }

    updatePolyline(polylineCoordinates);
    isLoadingDirections.value = false;
  }

  void updatePolyline(List<LatLng> points) {
    print("Updating polyline with ${points.length} points.");
    polyline.value = Polyline(
        polylineId: const PolylineId("route_polyline"),
        points: points,
        color: AppColors.polylineColors.isNotEmpty
            ? AppColors.polylineColors[0]
            : Colors.deepPurple,
        width: 5,
        consumeTapEvents: true,
        onTap: () {
          print("Polyline tapped!");
        });
  }

  void toggleBottomSheet() {
    isBottomSheetOpen.value = !isBottomSheetOpen.value;
  }

  void addMapMarker(LatLng position, String label, MarkerType type,
      {String? idSuffix}) {
    BitmapDescriptor icon;
    String markerIdBase;

    switch (type) {
      case MarkerType.pickup:
        icon = customMarkerIconPickup.value;
        markerIdBase = "pickup";
        break;
      case MarkerType.dropOff:
        icon = customMarkerIconDropOff.value;
        markerIdBase = "dropOff";
        break;
      case MarkerType.car:
        icon = customMarkerIconCar.value;
        markerIdBase = "car";
        break;
    }

    final String markerId =
    idSuffix != null ? "${markerIdBase}_$idSuffix" : markerIdBase;

    if (!markers.any((m) => m.markerId == MarkerId(markerId))) {
      final marker = Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: icon,
      );
      markers.add(marker);
    }
  }

  void selectDriver(NearbyDriver driver) {
    selectedDriver.value = driver;
    print("Selected Driver: ${driver.fullName ?? 'Driver ${driver.id}'}");
  }

  Future<void> _loadCustomMarker(String label, MarkerType type) async {
    String imagePath;
    int targetSize;

    switch (type) {
      case MarkerType.pickup:
        imagePath = 'assets/images/my_location.png';
        targetSize = 100;
        break;
      case MarkerType.dropOff:
        imagePath = 'assets/icons/locations.png';
        targetSize = 100;
        break;
      case MarkerType.car:
        imagePath = 'assets/images/car.png';
        targetSize = 80;
        break;
    }

    final BitmapDescriptor loadedIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(targetSize.toDouble(), targetSize.toDouble())),
      imagePath,
    );

    switch (type) {
      case MarkerType.pickup:
        customMarkerIconPickup.value = loadedIcon;
        break;
      case MarkerType.dropOff:
        customMarkerIconDropOff.value = loadedIcon;
        break;
      case MarkerType.car:
        customMarkerIconCar.value = loadedIcon;
        break;
    }
  }
}

enum MarkerType {
  pickup,
  dropOff,
  car,
}