/*
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/shared_preferences_data_helper.dart';

class MapWebSocketService {
  final String wsUrl = Urls.socketUrl;
  WebSocketChannel? _channel;
  int retryCount = 0;
  static const maxRetries = 5;
  String? _riderToken;
  String? _transportId;

  // List of callbacks for driver location updates to support multiple listeners
  final List<Function(LatLng, String)> _locationUpdateCallbacks = [];

  WebSocketService() {
    // Initialize WebSocket connection on instantiation
    _initializeWebSocket();
  }

  // Initialize WebSocket connection
  Future<void> _initializeWebSocket() async {
    if (retryCount >= maxRetries) {
      Get.snackbar('Error', 'Max WebSocket retries reached.');
      return;
    }
    try {
      // NOTE: Assuming AuthController.accessToken is an async getter or static method
      _riderToken = await AuthController.accessToken;
      if (_riderToken == null || _riderToken!.isEmpty) {
        debugPrint("⚠️ WebSocket: Rider token is null or empty.");
        // We shouldn't show a snackbar here as this runs in the constructor
        return;
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint("🌐 WebSocket: Connecting to $wsUrl");

      _authenticate(_riderToken!);

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint("⚠️ WebSocket error: $error");
        },
        onDone: () {
          debugPrint("🛑 WebSocket connection closed.");
          retryCount++;
          Future.delayed(const Duration(seconds: 5), _initializeWebSocket);
        },
      );
    } catch (e) {
      debugPrint("⚠️ WebSocket initialization failed: $e");
      retryCount++;
      Future.delayed(const Duration(seconds: 5), _initializeWebSocket);
    }
  }

  // Authenticate WebSocket connection
  void _authenticate(String token) {
    final authMessage = jsonEncode({"event": "authenticate", "token": token});
    _channel?.sink.add(authMessage);
    if (kDebugMode) {
      print("Sent authentication message: $authMessage");
    }
  }

  // Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final event = data['event'];

      if (event == 'driverLocationUpdate') {
        final transportId = data['transportId'];
        // Ensure lat/lng are parsed correctly (they might be strings in the JSON payload)
        final lat = double.tryParse(data['lat'].toString());
        final lng = double.tryParse(data['lng'].toString());
        final location = data['location'] ?? 'Unknown';

        debugPrint(
            "📍 WebSocket: Driver location update - ID: $transportId, Lat: $lat, Lng: $lng, Location: $location");

        if (transportId == _transportId && lat != null && lng != null) {
          for (var callback in _locationUpdateCallbacks) {
            // Callback for the controller to use
            callback(LatLng(lat, lng), 'Driver ($location)');
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ WebSocket message parsing failed: $e");
    }
  }

  // ✅ Method used by controllers
  void addLocationUpdateCallback(void Function(LatLng, String) callback) {
    _locationUpdateCallbacks.add(callback);
  }

  // ✅ Method used by controllers
  */
/* void addLocationUpdateCallback(void Function(LatLng position, String label) addMarkerCarAvailable) {}*//*


  void removeLocationUpdateCallback(Function(LatLng, String) callback) {
    _locationUpdateCallbacks.remove(callback);
  }

  // ✅ Method used by controllers
  void setTransportId(String? transportId) {
    _transportId = transportId;
  }

  // Send a WebSocket message
  void sendMessage(String event, Map<String, dynamic> data) {
    final message = jsonEncode({"event": event, ...data});
    _channel?.sink.add(message);
    if (kDebugMode) {
      print("Sent WebSocket message: $message");
    }
  }

  // Close WebSocket connection
  void close() {
    if (kDebugMode) {
      print("Closing WebSocket connection.");
    }
    _channel?.sink.close();
  }
}*/
