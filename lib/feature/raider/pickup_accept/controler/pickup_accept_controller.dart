import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../web socket/map_web_socket.dart' as raiderWebSocket;
import '../../confirm_pickup/controler/driver_infor_api_controller.dart';
import '../../confirm_pickup/controler/my_ride_pending_api_controller.dart'
    hide DriverInfoApiController;

const double AVERAGE_TAXI_SPEED_KMH = 30.0;
const double ARRIVAL_THRESHOLD_KM = 0.01;

class PickupAcceptController extends GetxController {
  final DriverInfoApiController driverInfoApiController = Get.put(
    DriverInfoApiController(),
  );
  final raiderWebSocket.MapWebSocketService webSocketService =
      Get.find<raiderWebSocket.MapWebSocketService>(tag: 'raiderMapWebSocket');

  final String googleApiKey = Urls.googleApiKey;

  var isBottomSheetOpen = true.obs;
  var isLoading = false.obs;
  var markerPosition = Rxn<LatLng>();
  var driverPosition = Rxn<LatLng>();
  var dropOffPosition = Rxn<LatLng>();
  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDriver = BitmapDescriptor.defaultMarker.obs;
  var markers = <Marker>{}.obs;
  var polylines = <Polyline>{}.obs;
  var driverDistance = ''.obs;
  var etaMinutes = ''.obs;
  var hasArrived = false.obs;

  String? _transportId;
  Timer? _timer;
  bool _initialDriverInfoFetched = false;

  bool get isSubscribed => webSocketService.isSubscribed;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    await _loadCustomMarkers();
    _setupWebSocket();
    await _fetchInitialData();

    ever(driverPosition, (_) => _updateMapWithDriverLocation());
    ever(markerPosition, (_) => updateMapElements());
    ever(dropOffPosition, (_) => updateMapElements());

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => updateMapElements(),
    );
    isLoading.value = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    webSocketService.removeLocationUpdateCallback(handleDriverLocationUpdate);
    webSocketService.close();
    super.onClose();
  }

  Future<void> _fetchInitialData() async {
    try {
      final fetchedId = await AuthController.getUserId();
      if (fetchedId == null || fetchedId.isEmpty) return;
      _transportId = fetchedId;
      webSocketService.setTransportId(_transportId!);
      if (!_initialDriverInfoFetched) {
        await driverInfoApiController.driverInfoApiMethod(_transportId!);
        _initialDriverInfoFetched = true;
      }
    } catch (e) {
      debugPrint("Initial data error: $e");
    }
  }

  void _setupWebSocket() {
    webSocketService.removeLocationUpdateCallback(handleDriverLocationUpdate);
    webSocketService.addLocationUpdateCallback(handleDriverLocationUpdate);
    ever(webSocketService.isConnectedRx, (bool connected) {
      if (connected && _transportId != null) {
        Timer(
          const Duration(seconds: 2),
          () => webSocketService.setTransportId(_transportId!),
        );
      }
    });
  }

  Future<void> loadAndDisplayRideData({
    required double initialPickupLat,
    required double initialPickupLng,
    double? initialDropoffLat,
    double? initialDropoffLng,
  }) async {
    isLoading.value = true;
    try {
      final pickup = _isValidLatLng(initialPickupLat, initialPickupLng)
          ? LatLng(initialPickupLat, initialPickupLng)
          : const LatLng(23.749341, 90.437213);
      markerPosition.value = pickup;

      if (initialDropoffLat != null && initialDropoffLng != null) {
        dropOffPosition.value =
            _isValidLatLng(initialDropoffLat, initialDropoffLng)
            ? LatLng(initialDropoffLat, initialDropoffLng)
            : null;
      }

      addMarker(pickup, 'Pickup');
      if (dropOffPosition.value != null)
        addMarker(dropOffPosition.value!, 'Drop-off');
      await _configureMapMarkers();
      await updateMapElements();
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  Future<void> _loadCustomMarkers() async {
    await Future.wait([
      _loadCustomMarker(
        'assets/images/my_location.png',
        'Pickup',
        100,
        customMarkerIcon,
      ),
      _loadCustomMarker(
        'assets/images/car.png',
        'Driver',
        60,
        customMarkerIconDriver,
      ),
    ]);
  }

  Future<void> _loadCustomMarker(
      String asset,
      String label,
      int width,
      Rx<BitmapDescriptor> target,
      ) async {
    try {
      final ByteData data = await rootBundle.load(asset);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: width
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw the image
      canvas.drawImage(image, Offset.zero, Paint());

      // Draw text label below the image
      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.yellow,
          ),
        ),
      );
      textPainter.layout();

      final double textX = (image.width - textPainter.width) / 2;
      final double textY = image.height.toDouble() + 2;
      textPainter.paint(canvas, Offset(textX, textY));

      // Calculate dimensions
      final int imageWidth = image.width;
      final int imageHeight = image.height;
      final int textHeight = textPainter.height.ceil();
      final int totalHeight = imageHeight + textHeight + 4;

      // Create final image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(imageWidth, totalHeight);

      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        target.value = BitmapDescriptor.fromBytes(
          byteData.buffer.asUint8List(),
        );
      }

      // Clean up resources
      picture.dispose();
      finalImage.dispose();
    } catch (e) {
      debugPrint("Error loading custom marker $asset: $e");
      target.value = BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _configureMapMarkers() async {
    final ride = driverInfoApiController.rideData.value;
    markers.clear();
    if (ride != null && markerPosition.value != null) {
      addMarker(markerPosition.value!, 'Pickup');
      if (ride.dropOffLat != null && ride.dropOffLng != null) {
        final drop = LatLng(ride.dropOffLat!, ride.dropOffLng!);
        dropOffPosition.value = drop;
        addMarker(drop, 'Drop-off');
      }
      if (ride.distance != null && driverDistance.value.isEmpty) {
        driverDistance.value = "${ride.distance!.toStringAsFixed(2)} km";
        etaMinutes.value = calculateETA(ride.distance!);
      }
    }
  }

  Future<void> _fetchDriverToPickupRoute() async {
    if (driverPosition.value == null || markerPosition.value == null) return;
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${driverPosition.value!.latitude},${driverPosition.value!.longitude}'
        '&destination=${markerPosition.value!.latitude},${markerPosition.value!.longitude}'
        '&mode=driving&key=$googleApiKey';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylinePoints = _decodePolyline(points);
          if (polylinePoints.isNotEmpty) {
            _updatePolyline('driver_to_pickup', polylinePoints, Colors.blue, 6);
            final distance =
                data['routes'][0]['legs'][0]['distance']['value'] / 1000;
            final duration =
                (data['routes'][0]['legs'][0]['duration']['value'] / 60)
                    .round();
            driverDistance.value = "${distance.toStringAsFixed(2)} km";
            etaMinutes.value = duration < 1 ? "Arriving now" : "$duration min";
            _checkDriverArrival(distance);
          }
        }
      }
    } catch (e) {
      _addFallbackPolyline(
        'driver_to_pickup',
        driverPosition.value!,
        markerPosition.value!,
        Colors.orange,
      );
    }
  }

  Future<void> _fetchPickupToDropoffRoute() async {
    if (markerPosition.value == null || dropOffPosition.value == null) return;
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${markerPosition.value!.latitude},${markerPosition.value!.longitude}'
        '&destination=${dropOffPosition.value!.latitude},${dropOffPosition.value!.longitude}'
        '&mode=driving&key=$googleApiKey';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylinePoints = _decodePolyline(points);
          if (polylinePoints.isNotEmpty) {
            _updatePolyline(
              'pickup_to_dropoff',
              polylinePoints,
              Colors.green,
              5,
            );
          }
        }
      }
    } catch (e) {
      _addFallbackPolyline(
        'pickup_to_dropoff',
        markerPosition.value!,
        dropOffPosition.value!,
        Colors.green.withOpacity(0.6),
      );
    }
  }

  void _updatePolyline(String id, List<LatLng> points, Color color, int width) {
    polylines.removeWhere((p) => p.polylineId.value == id);
    polylines.add(
      Polyline(
        polylineId: PolylineId(id),
        points: points,
        color: color,
        width: width,
      ),
    );
  }

  void _addFallbackPolyline(String id, LatLng start, LatLng end, Color color) {
    polylines.removeWhere((p) => p.polylineId.value == id);
    polylines.add(
      Polyline(
        polylineId: PolylineId(id),
        points: [start, end],
        color: color,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
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

  double calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371;
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final dLon = (p2.longitude - p1.longitude) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180) *
            math.cos(p2.latitude * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  String calculateETA(double distanceKm) {
    final eta = (distanceKm / AVERAGE_TAXI_SPEED_KMH) * 60;
    return eta < 1 ? "Arriving now" : "${eta.round()} min";
  }

  void _updateDriverDistanceAndETA(LatLng driverPos) {
    if (markerPosition.value != null) {
      final dist = calculateDistance(driverPos, markerPosition.value!);
      driverDistance.value = "${dist.toStringAsFixed(2)} km";
      etaMinutes.value = calculateETA(dist);
      _checkDriverArrival(dist);
    }
  }

  void _checkDriverArrival(double distanceKm) {
    if (distanceKm < ARRIVAL_THRESHOLD_KM && !hasArrived.value) {
      hasArrived.value = true;
      Get.offNamed(
        '/endRideScreen',
        arguments: {
          'pickupLat': markerPosition.value?.latitude,
          'pickupLng': markerPosition.value?.longitude,
          'dropOffLat': dropOffPosition.value?.latitude,
          'dropOffLng': dropOffPosition.value?.longitude,
          'transportId': _transportId,
        },
      );
    }
  }

  Future<void> updateMapElements() async {
    await _configureMapMarkers();
    await _fetchDriverToPickupRoute();
    if (dropOffPosition.value != null) await _fetchPickupToDropoffRoute();
    update();
  }

  void handleDriverLocationUpdate(LatLng position, String label) {
    if (!_isValidLatLng(position.latitude, position.longitude)) return;
    driverPosition.value = position;
    addMarkerCarAvailable(position, label);
    _updateDriverDistanceAndETA(position);
    _fetchDriverToPickupRoute();
    update();
  }

  void _updateMapWithDriverLocation() {
    if (driverPosition.value != null) {
      addMarkerCarAvailable(driverPosition.value!, 'Driver');
      _updateDriverDistanceAndETA(driverPosition.value!);
      _fetchDriverToPickupRoute();
      update();
    }
  }

  void addMarker(LatLng position, String label) {
    markers.removeWhere((m) => m.markerId.value == label);
    final icon = label == 'Pickup'
        ? customMarkerIcon.value
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    markers.add(
      Marker(
        markerId: MarkerId(label),
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: icon,
      ),
    );
  }

  void addMarkerCarAvailable(LatLng position, String label) {
    markers.removeWhere((m) => m.markerId.value == 'Driver');
    final prevPos = driverPosition.value;
    final bearing = prevPos != null
        ? _calculateBearing(prevPos, position)
        : 0.0;
    markers.add(
      Marker(
        markerId: const MarkerId('Driver'),
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: customMarkerIconDriver.value,
        rotation: bearing,
        zIndex: 10,
      ),
    );
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final startLat = start.latitude * math.pi / 180;
    final startLng = start.longitude * math.pi / 180;
    final endLat = end.latitude * math.pi / 180;
    final endLng = end.longitude * math.pi / 180;
    final dLng = endLng - startLng;
    final y = math.sin(dLng) * math.cos(endLat);
    final x =
        math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  void clearDriverInfo() {
    driverInfoApiController.rideData.value = null;
    markers.clear();
    polylines.clear();
    webSocketService.removeLocationUpdateCallback(handleDriverLocationUpdate);
    webSocketService.close();
  }
}
