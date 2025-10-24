import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../model/raider model/ride_model.dart';


class SocketMapCourier extends GetxController {
  Rx<LatLng> riderLocation = LatLng(0, 0).obs;

  final apiKey = '${Urls.googleApiKey}';

  late WebSocketChannel _channel;
  RxBool isWebSocketConnected = false.obs;
  StreamSubscription<Position>? positionStreamSubscription;
  var isLoading = false.obs;
  final double proximityThreshold = 20;
  Timer? _timer;
  var parcelId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
    _timer = Timer(Duration(seconds: 60), () async {
      await updateProfileLocation(
        riderLocation.value.latitude,
        riderLocation.value.longitude,
      );
    });
  }

  @override
  void onClose() {
    super.onClose();
    positionStreamSubscription?.cancel();
    if (_channel != null) {
      _channel.sink.close();
    }
    _timer?.cancel();
  }

  void _connectWebSocket() async {
    isLoading.value = true;
    String? token = await AuthController.accessToken;
    if (token == null || token.isEmpty) {
      print('No token found for WebSocket authentication');
      return;
    }

    _channel = WebSocketChannel.connect(Uri.parse(Urls.socketUrl));

    _channel.stream.listen(
          (message) {
        final data = jsonDecode(message);
        final event = data['event'];
        final location = data['data']?['location'];

        if (event == 'info') {
          print('Server info: ${data['message']}');
          _sendAuth(token);
        } else if (event == 'authenticated') {
          bool success = data['data']?['success'] ?? false;
          if (success) {
            print(
              'WebSocket authenticated for courier: ${data['data']['userId']}',
            );
            isWebSocketConnected.value = true;
            getCurrentLocation();
          } else {
            print('WebSocket authentication failed');
          }
        } else if (event == 'newParcelRequest') {
          final parcelRequest = Ride.fromJson(data['data']);
        //  print('New parcel request: ${parcelRequest.orderId}');
          // Get.snackbar(
          //   "New Request Arrived",
          //   parcelRequest.parcelId,
          //   snackPosition: SnackPosition.BOTTOM,
          //   duration: Duration(seconds: 5),
          // );
          //Get.to(() => DeliveryRequestScreen(parcelId: parcelRequest.parcelId));

          // Get.snackbar("New Request Arrived", parcelRequest.parcelId);
        } else if (event == 'courierLocationUpdatedForPickup') {
          // LatLng newPosition = LatLng(
          //   (location['lat'] as num).toDouble(),
          //   (location['lng'] as num).toDouble(),
          // );
          // getCurrentLocationSocket();
        }
      },
      onDone: () {
        print('WebSocket connection closed');
        isWebSocketConnected.value = false;
      },
      onError: (error) {
        print('WebSocket error: $error');
        isWebSocketConnected.value = false;
      },
    );
  }

  void _sendAuth(String token) {
    final authMessage = jsonEncode({'event': 'authenticate', 'token': token});
    print('Sending auth message: $authMessage');
    _channel.sink.add(authMessage);
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Location Permission",
        "Location permission is needed to track the location.",
      );
      return;
    }

    positionStreamSubscription = Geolocator.getPositionStream().listen((
        Position position,
        ) {
      print('Requesting location permission...');
      final newPosition = LatLng(position.latitude, position.longitude);
      riderLocation.value = newPosition;
      isLoading.value = false;
      if (isWebSocketConnected.value) {
        sendLocationUpdate(newPosition.latitude, newPosition.longitude);
      } else {
        _connectWebSocket();
      }
    });
  }

  Future<void> sendLocationUpdate(double lat, double lng) async {
    try {
      if (parcelId.value.isEmpty) {
        print('Parcel ID is empty, cannot send location update');
        return;
      }
      final baseAddress = await _getAddressFromLatLng(LatLng(lat, lng));
      final locationUpdateMessage = jsonEncode({
        "event": "updateCourierLocationToPickup",
        "parcelId": parcelId.value,
        "lat": lat,
        "lng": lng,
        "location": baseAddress,
      });

      _channel.sink.add(locationUpdateMessage);
      print('Sent location update: $locationUpdateMessage');
      // Get.snackbar(
      //   'Location Update',
      //   'Courier location updated to: $baseAddress',
      //   snackPosition: SnackPosition.TOP,
      //   duration: Duration(seconds: 3),
      // );
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  Future<void> updateProfileLocation(double lat, double lng) async {
    try {
      final baseAddress = await _getAddressFromLatLng(LatLng(lat, lng));
      final locationUpdateMessage = jsonEncode({
        "event": "updateLocation",
        "lat": lat,
        "lng": lng,
        "location": baseAddress,
      });

      _channel.sink.add(locationUpdateMessage);
      print('update location : $locationUpdateMessage');
      // Get.snackbar(
      //   'Profile Location Update',
      //   'location updated to: $baseAddress',
      //   snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 3),
      // );
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'Unknown Address';
      }
    } else {
      throw Exception('Failed to load address');
    }
  }
}




