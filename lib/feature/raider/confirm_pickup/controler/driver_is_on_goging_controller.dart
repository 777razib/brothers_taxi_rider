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
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../web socket/map_web_socket.dart';
import 'driver_infor_api_controller.dart';
import 'my_ride_pending_api_controller.dart';

const String GOOGLE_DIRECTIONS_API_KEY = "${Urls.googleApiKey}";
const double AVERAGE_TAXI_SPEED_KMH = 30.0; // Average speed for ETA calculation

class DriverIsOnGoingController extends GetxController {
  final MyRidePendingApiController myRidePendingApiController = Get.put(MyRidePendingApiController());
  final DriverInfoApiController driverInfoApiController = Get.put(DriverInfoApiController());
  final MapWebSocketService mapWebSocketService = MapWebSocketService();

  String transportId = '';
  var isBottomSheetOpen = false.obs;
  var isLoading = false.obs;
  var isLoadingMap = false.obs; // Added for PickupPointMapScreen
  var driverDistance = ''.obs; // e.g., "1.57 km"
  var etaMinutes = ''.obs; // e.g., "3 min"
  var pickupPosition = Rxn<LatLng>();
  var dropOffPosition = Rxn<LatLng>();
  var selectedDriverPosition = Rxn<LatLng>();
  var carTransportId = Rxn<String>();
  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDriver = BitmapDescriptor.defaultMarker.obs;
  var customMarkerCar = BitmapDescriptor.defaultMarker.obs;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;
  var currentBottomSheet = 1.obs;
  var selectedIndex = 0.obs;

  void selectContainerEffect(int index) {
    selectedIndex.value = index;
  }

  void changeSheet(int value) {
    currentBottomSheet.value = value;
  }

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

  String calculateETA(double distanceKm) {
    double etaMin = (distanceKm / AVERAGE_TAXI_SPEED_KMH) * 60;
    return etaMin < 1 ? "Arriving now" : "${etaMin.round()} min";
  }

  Future<void> confirmPickupApiMethod() async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('https://brother-taxi.onrender.com/api/v1/carTransports/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pickupLat': pickupPosition.value?.latitude,
          'pickupLng': pickupPosition.value?.longitude,
          'dropOffLat': dropOffPosition.value?.latitude,
          'dropOffLng': dropOffPosition.value?.longitude,
          'driverId': driverInfoApiController.rideData.value?.vehicle?.driver?.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          carTransportId.value = data['data']['carTransport']['id'];
          debugPrint("DriverIsOnGoingController: Ride confirmed. Transport ID: ${carTransportId.value}");
          mapWebSocketService.setTransportId(carTransportId.value);
          Get.offAllNamed('/PickupAcceptScreen', arguments: {'transportId': carTransportId.value});
        } else {
          Get.snackbar("Error", "Failed to confirm ride: ${data['message']}");
        }
      } else {
        Get.snackbar("Error", "Failed to confirm ride. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("DriverIsOnGoingController: Error confirming ride: $e");
      Get.snackbar("Error", "Failed to confirm ride: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAndDisplayRideData({
    required double initialPickupLat,
    required double initialPickupLng,
    required double initialDropOffLat,
    required double initialDropOffLng,
  }) async {
    isLoading.value = true;
    isLoadingMap.value = true;

    try {
      // Set initial coordinates from arguments
      pickupPosition.value = LatLng(initialPickupLat, initialPickupLng);
      dropOffPosition.value = LatLng(initialDropOffLat, initialDropOffLng);

      // Fetch ride data
      await _fetchAndLoadData();

      // Update coordinates from API if available
      if (driverInfoApiController.rideData.value != null) {
        final rideData = driverInfoApiController.rideData.value!;
        pickupPosition.value = LatLng(
          rideData.pickupLat ?? initialPickupLat,
          rideData.pickupLng ?? initialPickupLng,
        );
        dropOffPosition.value = LatLng(
          rideData.dropOffLat ?? initialDropOffLat,
          rideData.dropOffLng ?? initialDropOffLng,
        );
        selectedDriverPosition.value = rideData.driverLat != null && rideData.driverLng != null
            ? LatLng(rideData.driverLat!, rideData.driverLng!)
            : null;

        // Clear existing markers and polylines
        markers.clear();
        polylines.clear();

        // Add markers
        addMarker(pickupPosition.value!, 'Pickup');
        addMarkerDriver(dropOffPosition.value!, 'Drop-off');
        if (selectedDriverPosition.value != null) {
          addMarkerCarAvailable(selectedDriverPosition.value!, 'Driver');
        }

        // Draw polylines
        if (pickupPosition.value != null && dropOffPosition.value != null) {
          await _getRoutePolyline(
            pickupPosition.value!,
            dropOffPosition.value!,
            polylineId: "route_polyline",
            color: Colors.blue,
          );
        }
        if (selectedDriverPosition.value != null && pickupPosition.value != null) {
          await _getRoutePolyline(
            selectedDriverPosition.value!,
            pickupPosition.value!,
            polylineId: "driver_polyline",
            color: Colors.green,
          );
          _updateDriverDistanceAndETA(selectedDriverPosition.value!);
        }
      } else {
        // Fallback to initial coordinates
        debugPrint("No API data, using provided coordinates");
        markers.clear();
        polylines.clear();
        addMarker(pickupPosition.value!, 'Pickup');
        addMarkerDriver(dropOffPosition.value!, 'Drop-off');
        await _getRoutePolyline(
          pickupPosition.value!,
          dropOffPosition.value!,
          polylineId: "route_polyline",
          color: Colors.blue,
        );
      }
    } catch (e) {
      debugPrint("Error loading ride data: $e");
      Get.snackbar("Error", "Failed to load ride data: $e");
    } finally {
      isLoading.value = false;
      isLoadingMap.value = false;
    }
  }

  Future<void> _fetchAndLoadData() async {
    try {
      driverInfoApiController.rideData.value = null;
      driverInfoApiController.errorMessage.value = '';
      driverInfoApiController.isLoading.value = false;
      transportId = '';

      debugPrint("📡 Fetching pending rides...");
      await myRidePendingApiController.myRidePendingApiController();

      debugPrint("🔍 Fetching user ID from AuthController...");
      String? fetchedId = await AuthController.getUserId();
      debugPrint("✅ User ID fetch completed: fetchedId=$fetchedId");

      if (fetchedId == null || fetchedId.isEmpty) {
        Get.snackbar("Error", "User ID not found.");
        return;
      }

      transportId = fetchedId;
      debugPrint("📌 transportId updated: $transportId");
      debugPrint("📡 Fetching driver info...");
      await driverInfoApiController.driverInfoApiMethod(transportId);

      // Update WebSocket with transportId
      if (transportId.isNotEmpty) {
        mapWebSocketService.setTransportId(transportId);
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Exception in _fetchAndLoadData: $e");
      debugPrint("📜 StackTrace: $stackTrace");
      Get.snackbar("Error", "Failed to load data: $e");
    }
  }

  void clearDriverInfo() {
    driverInfoApiController.rideData.value = null;
    driverInfoApiController.isLoading.value = false;
    transportId = '';
    markers.clear();
    polylines.clear();
    debugPrint("🗑️ Driver info cleared and state reset.");
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    isLoadingMap.value = true;

    // Load custom markers
    await Future.wait([
      _loadCustomMarker("You"),
      _loadCustomMarker2("Destination"),
      _loadCustomMarker3("Driver"),
    ]);

    // Set up WebSocket
    _setupWebSocket();

    isLoading.value = false;
    isLoadingMap.value = false;
  }

  void _setupWebSocket() {
    mapWebSocketService.addLocationUpdateCallback((LatLng position, String label) {
      debugPrint("📍 WebSocket: Driver location updated to $position");
      selectedDriverPosition.value = position;

      // Update driver marker
      final driverMarkerId = const MarkerId('driver_live');
      markers.removeWhere((m) => m.markerId == driverMarkerId);
      markers.add(Marker(
        markerId: driverMarkerId,
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: customMarkerCar.value,
      ));

      // Recalculate distance and ETA
      if (pickupPosition.value != null) {
        _updateDriverDistanceAndETA(position);
        // Redraw driver-to-pickup polyline
        _getRoutePolyline(
          position,
          pickupPosition.value!,
          polylineId: "driver_polyline",
          color: Colors.green,
        );
      }

      update(); // Notify UI
    });
  }

  void _updateDriverDistanceAndETA(LatLng driverPos) {
    if (pickupPosition.value != null) {
      final distanceKm = calculateDistance(driverPos, pickupPosition.value!);
      driverDistance.value = "${distanceKm.toStringAsFixed(2)} km";
      etaMinutes.value = calculateETA(distanceKm);
      debugPrint("Driver Distance: ${driverDistance.value}, ETA: ${etaMinutes.value}");
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
      debugPrint("Error fetching polyline: $e");
    }

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