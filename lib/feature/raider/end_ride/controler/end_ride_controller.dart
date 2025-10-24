import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../web socket/map_web_socket.dart';
import '../../confirm_pickup/controler/driver_infor_api_controller.dart';
import '../../web socket/web_socket.dart';

class EndRideController extends GetxController {
  final DriverInfoApiController driverInfoApiController = Get.put(DriverInfoApiController());
  final String googleApiKey = Urls.googleApiKey;
  // FIX: Use Get.find() to retrieve the singleton instance, not create a new one.
  final MapWebSocketService webSocketService = Get.find<MapWebSocketService>();

  // Observable state
  var isBottomSheetOpen = false.obs;
  var isLoading = false.obs;
  var markerPosition = LatLng(23.749341, 90.437213).obs; // Fallback pickup
  var destinationPosition = LatLng(23.749704, 90.430164).obs; // Fallback drop-off
  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDriver = BitmapDescriptor.defaultMarker.obs;
  var customMarkerCar = BitmapDescriptor.defaultMarker.obs;
  var markers = <Marker>{}.obs;
  var polyline = Polyline(
    polylineId: PolylineId("route"),
    points: <LatLng>[],
    color: Colors.blue,
    width: 5,
  ).obs;

  // Time-related variables
  var pickupDate = ''.obs;
  var pickupTime = ''.obs;
  var rideTime = 0.obs;
  var waitingTime = 0.obs;

  String? _transportId;

  @override
  void onInit() async {
    super.onInit();
    await _loadCustomMarkers();
    _fetchAndLoadData();
    // Subscribe to WebSocket driver location updates
    webSocketService.addLocationUpdateCallback(addMarkerCarAvailable); // 👈 Removed extra comma
  }

  @override
  void onClose() {
    webSocketService.removeLocationUpdateCallback(addMarkerCarAvailable); // 👈 Added parameter
    webSocketService.close(); // Note: Closing the service might affect other active controllers
    super.onClose();
  }

  // Unified method to load custom markers
  Future<void> _loadCustomMarkers() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadCustomMarker(
          asset: 'assets/images/my_location.png',
          label: 'Pickup',
          width: 100,
          target: customMarkerIcon, // 👈 Fixed typo from pcustomMarkerIcon
        ),
        _loadCustomMarker(
          asset: 'assets/images/driver_location.png',
          label: 'Driver',
          width: 80,
          target: customMarkerIconDriver,
        ),
        _loadCustomMarker(
          asset: 'assets/images/car.png',
          label: 'Dropoff',
          width: 60,
          target: customMarkerCar,
        ),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load custom markers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCustomMarker({
    required String asset,
    required String label,
    required int width,
    required Rx<BitmapDescriptor> target,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final paint = Paint();
    canvas.drawImage(image, Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellow,
        ),
      )
      ..layout();

    final textX = (image.width - textPainter.width) / 2;
    final textY = image.height.toDouble() + 4;
    textPainter.paint(canvas, Offset(textX, textY));

    final finalImage = await pictureRecorder.endRecording().toImage(
      image.width,
      image.height + textPainter.height.toInt() + 8,
    );
    final finalByteData =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);
    target.value = BitmapDescriptor.fromBytes(finalByteData!.buffer.asUint8List());
  }

  void _fetchAndLoadData() async {
    try {
      final fetchedId = await AuthController.getUserId();
      if (fetchedId == null || fetchedId.isEmpty) {
        Get.snackbar('Error', 'Failed to fetch user ID.');
        return;
      }
      _transportId = fetchedId;
      debugPrint('Auth User ID fetched: $_transportId');

      // Set transport ID in WebSocketService
      webSocketService.setTransportId(_transportId);

      await driverInfoApiController.driverInfoApiMethod(_transportId!);
      _configureMapMarkers();
      await _fetchRoute();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    }
  }

  void _configureMapMarkers() {
    final ride = driverInfoApiController.rideData.value;
    markers.clear();

    if (ride != null) {
      markerPosition.value = LatLng(
        ride.pickupLat ?? 23.749341,
        ride.pickupLng ?? 90.437213,
      );
      destinationPosition.value = LatLng(
        ride.dropOffLat ?? 23.749704,
        ride.dropOffLng ?? 90.430164,
      );

      if (ride.driverLat != null && ride.driverLng != null) {
        addMarkerCarAvailable(LatLng(ride.driverLat!, ride.driverLng!), 'Driver');
      }

      pickupDate.value = ride.pickupDate ?? '';
      pickupTime.value = ride.pickupTime ?? '';
      rideTime.value = ride.rideTime ?? 0;
      waitingTime.value = ride.waitingTime ?? 0;

      addMarker(markerPosition.value, 'Pickup');
      addMarkerDriver(destinationPosition.value, 'Dropoff');
    }
  }

  // Fetch route using Google Directions API
  Future<void> _fetchRoute() async {
    final origin = '${markerPosition.value.latitude},${markerPosition.value.longitude}';
    final destination =
        '${destinationPosition.value.latitude},${destinationPosition.value.longitude}';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin&destination=$destination&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
          polyline.value = Polyline(
            polylineId: PolylineId('route'),
            points: points,
            color: Colors.amber,
            width: 5,
          );
        } else {
          Get.snackbar('Error', 'Failed to fetch route: ${data['status']}');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch route: HTTP ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch route: $e');
    }
  }

  // Decode polyline points from Google Directions API
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void addMarker(LatLng position, String label) {
    markers.add(Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerIcon.value,
    ));
  }

  void addMarkerDriver(LatLng position, String label) {
    markers.add(Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerCar.value,
    ));
  }

  void addMarkerCarAvailable(LatLng position, String label) {
    markers.removeWhere(
            (marker) =>
        marker.markerId.value == 'Driver' ||
            marker.markerId.value.startsWith('Driver ('));
    markers.add(Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerIconDriver.value,
    ));
  }

  void toggleBottomSheet() {
    isBottomSheetOpen.value = !isBottomSheetOpen.value;
  }

  void clearDriverInfo() {
    driverInfoApiController.rideData.value = null;
    driverInfoApiController.isLoading.value = false;
    _transportId = null;
    markers.clear();
    polyline.value = Polyline(
      polylineId: PolylineId('route'),
      points: [],
      color: Colors.blue,
      width: 5,
    );
    webSocketService.close();
    debugPrint('🗑️ Driver info cleared and WebSocket closed.');
    AuthController.idClear();
  }
}