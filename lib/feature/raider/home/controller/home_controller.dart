
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  // Marker position initialized to a default, which is immediately overridden by GPS.
  var markerPosition = const LatLng(37.7749, -122.4194).obs;
  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;

  GoogleMapController? mapController;
  late StreamSubscription<Position> _positionSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadCustomMarkerWithLabel("You");
    // This function ensures the markerPosition is updated to the live GPS location immediately.
    _initLocationTracking();
  }

  @override
  void onClose() {
    _positionSubscription.cancel();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Animate camera to the current location when the map is ready
    if (markerPosition.value != const LatLng(37.7749, -122.4194)) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(markerPosition.value, 16.0),
      );
    }
  }

  /// Start tracking user location and set initial position
  Future<void> _initLocationTracking() async {
    // 1. Check/Request Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {

      // 2. Get the current position once (to instantly center the map)
      Position initialPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng initialLatLng = LatLng(initialPos.latitude, initialPos.longitude);

      // 💡 KEY: Immediately set the marker to the current GPS location
      markerPosition.value = initialLatLng;
      postLocationToApi(markerPosition.value);

      // Move camera to initial position
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(initialLatLng, 16.0),
      );

      // 3. Start the continuous stream (updates when 5m movement is detected)
      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      _positionSubscription = positionStream.listen((Position pos) {
        LatLng newPos = LatLng(pos.latitude, pos.longitude);

        if (newPos != markerPosition.value) {
          // 💡 KEY: Update location for UI rebuild and API post
          markerPosition.value = newPos;
          postLocationToApi(newPos);

          // Camera follows the user's movement
          mapController?.animateCamera(
            CameraUpdate.newLatLng(newPos),
          );
        }
      });
    } else {
      debugPrint("Location permission denied. Using default marker position.");
    }
  }

  // ... postLocationToApi and _loadCustomMarkerWithLabel implementations remain the same ...
  Future<void> postLocationToApi(LatLng pos) async {
    const String apiUrl = "https://yourapi.com/location/update";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: '{"latitude": ${pos.latitude}, "longitude": ${pos.longitude}}',
      );

      if (response.statusCode == 200) {
        // debugPrint("✅ Location posted successfully: ${pos.latitude}");
      } else {
        debugPrint("⚠️ Failed to post location: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error posting location: $e");
    }
  }

  Future<void> _loadCustomMarkerWithLabel(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load('assets/images/my_location.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 120);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, const Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.yellow,
      ),
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
  }
}
