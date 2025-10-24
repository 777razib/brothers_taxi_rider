import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../model/raider model/ride_model.dart';

class CourierLocationUpdateController extends GetxController {
  late WebSocketChannel _channel;
  var isWebSocketConnected = false.obs;
  final String googleAPIKey = Urls.googleApiKey;
  Timer? _locationUpdateTimer; // Timer to send location updates periodically

  @override
  void onInit() {
    // 💡 FIX: Start connection immediately upon controller initialization
    _connectWebSocket();
    super.onInit();
  }

  @override
  void onClose() {
    print('Closing WebSocket connection');
    _locationUpdateTimer?.cancel(); // Stop the timer when closing
    // Check if _channel is initialized before accessing its sink
    if (_channel != null) {
      _channel.sink.close();
      print('WebSocket connection closed');
    }
    super.onClose();
  }

  void _connectWebSocket() async {
    String? token = await AuthController.accessToken;
    if (token == null || token.isEmpty) {
      print('No token found for WebSocket authentication');
      return;
    }

    _channel = WebSocketChannel.connect(Uri.parse(Urls.socketUrl));

    _channel.stream.listen(
          (message) {
        // 💡 ADDED: Basic check for non-string messages
        if (message is! String) return;

        final data = jsonDecode(message);
        final event = data['event'];
        // location is not used here, so it's commented out for cleanliness
        // final location = data['data']?['location'];

        if (event == 'info') {
          print('Server info: ${data['message']}');
          _sendAuth(token);
        } else if (event == 'authenticated') {
          bool success = data['data']?['success'] ?? false;
          if (success) {
            print('WebSocket authenticated for user: ${data['data']['userId']}');
            isWebSocketConnected.value = true;
            Get.snackbar(
              "WebSocket Connected",
              "You are now connected to the WebSocket server.",
              snackPosition: SnackPosition.BOTTOM,
            );

            // Start sending location updates after successful authentication
            _startLocationUpdates();
          } else {
            print('WebSocket authentication failed');
          }
        } else if (event == 'newParcelRequest') {
          final parcelRequest = Ride.fromJson(data['data']);
          print('New parcel request received.');
          // Get.snackbar("New Request Arrived", parcelRequest.parcelId);
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
    // 💡 FIX: Using 'authenticate' event if that's what the server expects, otherwise 'auth'
    final authMessage = jsonEncode({'event': 'authenticate', 'token': token});
    print('Sending auth message: $authMessage');
    _channel.sink.add(authMessage);
  }

  void _startLocationUpdates() {
    // Start sending location updates every 5 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      getCurrentLocationSocket();
    });
  }

  Future<void> sendLocationUpdate(double lat, double lng) async {
    if (!isWebSocketConnected.value) return;
    try {
      final locationUpdateMessage = jsonEncode({
        "event": "updateLocation",
        "lat": lat,
        "lng": lng,
      });

      _channel.sink.add(locationUpdateMessage);
      print('Sent location update: $locationUpdateMessage');
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  // 💡 FIX: Method uses geolocator (geo) for permission and position.
  void getCurrentLocationSocket() async {
    // 1. Check/Request Permission using geo.Geolocator methods
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    // 2. Proceed only if permission is granted
    if (permission == geo.LocationPermission.always ||
        permission == geo.LocationPermission.whileInUse) {

      try {
        geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );

        // Send the updated location to the server
        await sendLocationUpdate(position.latitude, position.longitude);
      } catch (e) {
        print('Error getting current position: $e');
      }
    } else {
      print('Location permission is not granted.');
    }
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleAPIKey',
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