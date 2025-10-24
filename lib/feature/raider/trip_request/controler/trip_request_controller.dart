import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripRequestController extends GetxController {
  var isBottomSheetOpen = false.obs;
  var isLoading = false.obs;
  var markerPosition = LatLng(23.749341, 90.437213).obs; // Current marker (You)
  var destinationPosition = LatLng(
    23.749704,
    90.430164,
  ).obs; // Second marker (Destination)
  var markerPosition2 = LatLng(23.752100, 90.436741).obs;
  var markerPosition3 = LatLng(23.749763, 90.438307).obs;
  var markerPosition4 = LatLng(23.748654, 90.436666).obs;
  var markerPosition5 = LatLng(23.749911, 90.435303).obs;

  var customMarkerIcon = BitmapDescriptor.defaultMarker.obs;
  var customMarkerIconDriver = BitmapDescriptor.defaultMarker.obs;
  var customMarkerCar = BitmapDescriptor.defaultMarker.obs;
  var markers = <Marker>{}.obs;
  var polyline = Polyline(
    polylineId: PolylineId("line_1"),
    points: <LatLng>[],
    color: Colors.blue,
    width: 5,
  ).obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadCustomMarker("You");
    await _loadCustomMarker2("You");
    await _loadCustomMarker3("You");

    addMarker(markerPosition.value, 'You');
    addMarkerDriver(destinationPosition.value, 'Destination');

    addMarkerCarAvailable(markerPosition2.value, 'Marker 2');
    addMarkerCarAvailable(markerPosition3.value, 'Marker 3');
    addMarkerCarAvailable(markerPosition4.value, 'Marker 4');
    addMarkerCarAvailable(markerPosition5.value, 'Marker 5');
  }

  // Toggle bottom sheet visibility
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
    updatePolyline();
  }

  void updatePolyline() {
    List<LatLng> points = [markerPosition.value, destinationPosition.value];

    polyline.value = Polyline(
      polylineId: PolylineId("line_1"),
      points: points,
      color: Colors.blue,
      width: 5,
    );
  }

  // Load custom marker with label
  Future<void> _loadCustomMarker(String label) async {
    isLoading.value = true;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load(
      'assets/images/my_location.png',
    );
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 200,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        fontSize: 20,
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

    final ByteData? finalByteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerIcon.value = BitmapDescriptor.fromBytes(finalBytes);
  }

  Future<void> _loadCustomMarker2(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load(
      'assets/images/driver_location.png',
    );
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 100,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        fontSize: 20,
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

    final ByteData? finalByteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerIconDriver.value = BitmapDescriptor.fromBytes(finalBytes);
  }

  Future<void> _loadCustomMarker3(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData data = await rootBundle.load('assets/images/car.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 100,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    Paint paint = Paint();
    canvas.drawImage(image, Offset(0, 0), paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(
        fontSize: 20,
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

    final ByteData? finalByteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List finalBytes = finalByteData!.buffer.asUint8List();

    customMarkerCar.value = BitmapDescriptor.fromBytes(finalBytes);
    isLoading.value = false;
  }
}
