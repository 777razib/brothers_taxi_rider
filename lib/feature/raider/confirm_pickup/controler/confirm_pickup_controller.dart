


import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network_caller/endpoints.dart';
import '../../../web socket/map_web_socket.dart';
import '../../choose_taxi/controler/choose_taxi_api_controller.dart';
import '../../choose_taxi/model/choose_taxi_model.dart';
import '../../choose_taxi/model/location_searching_model.dart';

const String GOOGLE_DIRECTIONS_API_KEY = "${Urls.googleApiKey}";
const double AVERAGE_TAXI_SPEED_KMH = 30.0; // Average speed for ETA calculation

class ConfirmPickupController extends GetxController {
  final ChooseTaxiApiController chooseTaxiApiController = Get.find<ChooseTaxiApiController>();

  // Initialize WebSocket service
  final MapWebSocketService mapWebSocketService = MapWebSocketService();

  var isBottomSheetOpen = false.obs;
  var isLoading = false.obs;
  var driverDistance = ''.obs; // e.g., "1.57 km"
  var etaMinutes = ''.obs; // e.g., "3 min"
  var pickupPosition = Rxn<LatLng>();
  var dropOffPosition = Rxn<LatLng>();
  var selectedDriverPosition = Rxn<LatLng>();
  var currentRidePlan = Rxn<RidePlan2>();
  var selectedDriverObj = Rxn<NearbyDriver>();
  var carTransportId = Rxn<String>(); // New property to store carTransport ID

  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDriver = BitmapDescriptor.defaultMarker.obs;
  var customMarkerCar = BitmapDescriptor.defaultMarker.obs;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs; // Support multiple polylines

  var currentBottomSheet = 1.obs;
  var selectedIndex = 0.obs;

  void selectContainerEffect(int index) {
    selectedIndex.value = index;
  }

  void changeSheet(int value) {
    currentBottomSheet.value = value;
  }

  // Haversine formula for distance calculation (in km)
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in km
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Estimate ETA based on distance
  String calculateETA(double distanceKm) {
    double etaMin = (distanceKm / AVERAGE_TAXI_SPEED_KMH) * 60;
    return etaMin < 1 ? "Arriving now" : "${etaMin.round()} min";
  }

  // Placeholder for ride confirmation API (based on logs)
  Future<void> confirmPickupApiMethod() async {
    try {
      isLoading.value = true;
      // Simulate API call to /api/v1/carTransports/create
      // Replace with your actual Dio/HTTP call
      final response = await http.post(
        Uri.parse('https://brother-taxi.onrender.com/api/v1/carTransports/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Add required payload based on your API
          'pickupLat': pickupPosition.value?.latitude,
          'pickupLng': pickupPosition.value?.longitude,
          'dropOffLat': dropOffPosition.value?.latitude,
          'dropOffLng': dropOffPosition.value?.longitude,
          'driverId': selectedDriverObj.value?.id,
          // Add other fields as needed
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          carTransportId.value = data['data']['carTransport']['id'];
          debugPrint("ConfirmPickupController: Ride confirmed. Transport ID: ${carTransportId.value}");

          // Set transportId for WebSocket after confirmation
          mapWebSocketService.setTransportId(carTransportId.value);

          // Navigate to PickupAcceptScreen with transportId
          Get.offAllNamed('/PickupAcceptScreen', arguments: {'transportId': carTransportId.value});
        } else {
          Get.snackbar("Error", "Failed to confirm ride: ${data['message']}");
        }
      } else {
        Get.snackbar("Error", "Failed to confirm ride. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ConfirmPickupController: Error confirming ride: $e");
      Get.snackbar("Error", "Failed to confirm ride: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    // Load custom markers
    await Future.wait([
      _loadCustomMarker("You"),
      _loadCustomMarker2("Destination"),
      _loadCustomMarker3("Driver"),
    ]);

    // Handle arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String? ridePlanId = args['ridePlanId'] as String?;
    final String? selectedDriverId = args['selectedCarId'] as String? ?? args['selectedDriverId'] as String?;

    // Fetch API data
    await chooseTaxiApiController.chooseTaxiApiMethod();

    if (chooseTaxiApiController.rideDataList.isNotEmpty) {
      // Select ride plan
      currentRidePlan.value = ridePlanId != null
          ? chooseTaxiApiController.rideDataList.firstWhere(
            (plan) => plan.id == ridePlanId,
        orElse: () => chooseTaxiApiController.rideDataList.first,
      )
          : chooseTaxiApiController.rideDataList.first;

      final ridePlan = currentRidePlan.value!;
      pickupPosition.value = LatLng(ridePlan.pickupLat ?? 23.749341, ridePlan.pickupLng ?? 90.437213);
      dropOffPosition.value = LatLng(ridePlan.dropOffLat ?? 23.749704, ridePlan.dropOffLng ?? 90.430164);

      // Add pickup and drop-off markers
      addMarker(pickupPosition.value!, 'Pickup');
      addMarkerDriver(dropOffPosition.value!, 'Drop-off');

      // Add polyline from pickup to drop-off
      if (pickupPosition.value != null && dropOffPosition.value != null) {
        await _getRoutePolyline(pickupPosition.value!, dropOffPosition.value!, polylineId: "route_polyline", color: Colors.blue);
      }

      // Handle nearby drivers
      if (ridePlan.nearbyDrivers != null && ridePlan.nearbyDrivers!.isNotEmpty) {
        for (final driver in ridePlan.nearbyDrivers!) {
          final driverPos = LatLng(driver.lat, driver.lng);
          addMarkerCarAvailable(driverPos, driver.fullName ?? 'Driver ${driver.id}');

          // Select driver if ID matches
          if (selectedDriverId != null && driver.id == selectedDriverId) {
            selectedDriverObj.value = driver;
            selectedDriverPosition.value = driverPos;
            if (pickupPosition.value != null) {
              await _getRoutePolyline(driverPos, pickupPosition.value!, polylineId: "driver_polyline", color: Colors.green);
              _updateDriverDistanceAndETA(driverPos);
            }
          }
        }

        // Default to first driver if none selected
        if (selectedDriverObj.value == null && ridePlan.nearbyDrivers!.isNotEmpty) {
          selectedDriverObj.value = ridePlan.nearbyDrivers!.first;
          selectedDriverPosition.value = LatLng(ridePlan.nearbyDrivers!.first.lat, ridePlan.nearbyDrivers!.first.lng);
          if (pickupPosition.value != null) {
            await _getRoutePolyline(selectedDriverPosition.value!, pickupPosition.value!, polylineId: "driver_polyline", color: Colors.green);
            _updateDriverDistanceAndETA(selectedDriverPosition.value!);
          }
        }
      } else {
        print("No nearby drivers found");
      }
    } else {
      // Fallback to static data
      print("No API data, using fallback positions");
      pickupPosition.value = const LatLng(23.749341, 90.437213);
      dropOffPosition.value = const LatLng(23.749704, 90.430164);
      addMarker(pickupPosition.value!, 'Pickup');
      addMarkerDriver(dropOffPosition.value!, 'Drop-off');
      await _getRoutePolyline(pickupPosition.value!, dropOffPosition.value!, polylineId: "route_polyline", color: Colors.blue);
    }

    // Register WebSocket callback for driver location updates
    mapWebSocketService.addLocationUpdateCallback((LatLng position, String label) {
      // Update selected driver position on map
      selectedDriverPosition.value = position;

      // Update or add driver marker
      final driverMarkerId = const MarkerId('driver_live');
      markers.removeWhere((m) => m.markerId == driverMarkerId);
      markers.add(Marker(
        markerId: driverMarkerId,
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: customMarkerCar.value,
      ));

      // Recalculate distance and ETA
      _updateDriverDistanceAndETA(position);

      // Optionally redraw polyline from driver to pickup
      if (pickupPosition.value != null) {
        _getRoutePolyline(position, pickupPosition.value!, polylineId: "driver_polyline", color: Colors.green);
      }

      update(); // Notify UI if using GetBuilder
    });

    isLoading.value = false;
  }

  @override
  void onClose() {
    // Clean up WebSocket callback and connection
    mapWebSocketService.removeLocationUpdateCallback((position, label) {});
    mapWebSocketService.close();
    super.onClose();
  }

  void _updateDriverDistanceAndETA(LatLng driverPos) {
    if (pickupPosition.value != null) {
      final distanceKm = calculateDistance(driverPos, pickupPosition.value!);
      driverDistance.value = "${distanceKm.toStringAsFixed(2)} km";
      etaMinutes.value = calculateETA(distanceKm);
      print("Driver Distance: ${driverDistance.value}, ETA: ${etaMinutes.value}");
    }
  }

  Future<void> _getRoutePolyline(LatLng origin, LatLng destination, {required String polylineId, required Color color}) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    try {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$GOOGLE_DIRECTIONS_API_KEY";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
          if (result.isNotEmpty) {
            polylineCoordinates = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
          }
        }
      }
    } catch (e) {
      print("Error fetching polyline: $e");
    }

    // Remove old polyline and add new one
    polylines.removeWhere((p) => p.polylineId.value == polylineId);
    polylines.add(Polyline(
      polylineId: PolylineId(polylineId),
      points: polylineCoordinates,
      color: color,
      width: 5,
    ));
  }

  void toggleBottomSheet() {
    isBottomSheetOpen.value = !isBottomSheetOpen.value;
  }

  void addMarkerCarAvailable(LatLng position, String label) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerCar.value,
    );
    markers.add(marker);
  }

  void addMarker(LatLng position, String label) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerIcon.value,
    );
    markers.add(marker);
  }

  void addMarkerDriver(LatLng position, String label) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: customMarkerIconDriver.value,
    );
    markers.add(marker);
  }

  Future<void> _loadCustomMarker(String label) async {
    isLoading.value = true;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load('assets/images/my_location.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 200);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, const Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: "You",
      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, backgroundColor: Colors.yellow),
    );
    textPainter.layout();
    final double textX = (image.width - textPainter.width) / 2;
    final double textY = image.height.toDouble() + 4;
    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      image.width,
      image.height + textPainter.height.toInt() + 8,
    );

    final ByteData? finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerIcon.value = BitmapDescriptor.fromBytes(finalBytes);
    isLoading.value = false;
  }

  Future<void> _loadCustomMarker2(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load('assets/icons/locations.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, const Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: "Destination",
      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, backgroundColor: Colors.yellow),
    );
    textPainter.layout();
    final double textX = (image.width - textPainter.width) / 2;
    final double textY = image.height.toDouble() + 4;
    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      image.width,
      image.height + textPainter.height.toInt() + 8,
    );

    final ByteData? finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerIconDriver.value = BitmapDescriptor.fromBytes(finalBytes);
  }

  Future<void> _loadCustomMarker3(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load('assets/images/car.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, const Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: "Driver",
      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, backgroundColor: Colors.yellow),
    );
    textPainter.layout();
    final double textX = (image.width - textPainter.width) / 2;
    final double textY = image.height.toDouble() + 4;
    textPainter.paint(canvas, Offset(textX, textY));

    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
      image.width,
      image.height + textPainter.height.toInt() + 8,
    );

    final ByteData? finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerCar.value = BitmapDescriptor.fromBytes(finalBytes);
    isLoading.value = false;
  }
}
