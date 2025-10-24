import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/network_caller/endpoints.dart';
import '../../core/services_class/shared_preferences_data_helper.dart';

class MapWebSocketService extends GetxService {
  final String wsUrl = Urls.socketUrl;
  WebSocketChannel? _channel;
  int retryCount = 0;
  static const maxRetries = 5;
  static const connectionTimeout = Duration(seconds: 10);
  static const reconnectDelay = Duration(seconds: 5);

  String? _riderToken;
  String? _transportId;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _connectionTimer;
  Completer<void>? _authenticationCompleter;
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;
  bool _isAuthenticating = false;

  final RxBool _isConnectedRx = false.obs;
  final RxString _connectionStatusRx = 'disconnected'.obs;
  final RxString _lastError = ''.obs;
  final List<Function(LatLng, String)> _locationUpdateCallbacks = [];

  bool get isConnected => _isConnectedRx.value;
  String get connectionStatus => _connectionStatusRx.value;
  RxBool get isConnectedRx => _isConnectedRx;
  RxString get connectionStatusRx => _connectionStatusRx;
  RxString get lastError => _lastError;

  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 MapWebSocketService initialized");
    _initializeWithDelay();
  }

  void _initializeWithDelay() {
    Timer(Duration(seconds: 2), () {
      initializeWebSocket();
    });
  }

  @override
  void onClose() {
    debugPrint("🛑 MapWebSocketService closing");
    _cleanup();
    super.onClose();
  }

  void _cleanup() {
    debugPrint("🧹 Cleaning up WebSocket resources");

    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _connectionTimer?.cancel();
    _authenticationCompleter?.completeError('Connection closed');
    _authenticationCompleter = null;
    _isAuthenticating = false;

    try {
      _channel?.sink.close();
    } catch (e) {
      debugPrint("❌ Error closing WebSocket: $e");
    } finally {
      _channel = null;
    }

    _isConnectedRx.value = false;
    _connectionStatusRx.value = 'disconnected';
  }

  Future<bool> initializeWebSocket() async {
    if (retryCount >= maxRetries) {
      debugPrint("❌ Max WebSocket retries reached");
      _connectionStatusRx.value = 'failed';
      _lastError.value = 'Max retry attempts reached';
      return false;
    }

    try {
      _cleanup();

      _riderToken = await AuthController.accessToken;
      debugPrint("🔑 Rider token: ${_riderToken != null ? 'Available' : 'NULL'}");

      if (_riderToken == null || _riderToken!.isEmpty) {
        debugPrint("⚠️ WebSocket: Rider token is null or empty.");
        _lastError.value = 'Rider token not available';
        _scheduleReconnect();
        return false;
      }

      debugPrint("🌐 WebSocket: Connecting to $wsUrl");
      _connectionStatusRx.value = 'connecting';
      _lastError.value = '';

      _connectionTimer = Timer(connectionTimeout, () {
        if (!_isConnectedRx.value) {
          debugPrint("⏰ WebSocket connection timeout");
          _lastError.value = 'Connection timeout';
          _handleDisconnection();
        }
      });

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['chat'],
      );

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint("⚠️ WebSocket stream error: $error");
          _lastError.value = 'Stream error: $error';
          _handleDisconnection();
        },
        onDone: () {
          debugPrint("🛑 WebSocket connection closed");
          _lastError.value = 'Connection closed by server';
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      _connectionTimer?.cancel();
      _isConnectedRx.value = true;
      _connectionStatusRx.value = 'connected';
      retryCount = 0;

      debugPrint("✅ WebSocket connected successfully");

      return true;
    } catch (e) {
      debugPrint("⚠️ WebSocket initialization failed: $e");
      _lastError.value = 'Initialization failed: $e';
      _handleDisconnection();
      return false;
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      debugPrint("📨 WebSocket received: $message");

      if (message is String && message.isEmpty) {
        debugPrint("⚠️ Empty message received");
        return;
      }

      final data = json.decode(message);
      final event = data['event']?.toString();

      if (event == null) {
        debugPrint("⚠️ WebSocket message missing event type: $data");
        return;
      }

      switch (event) {
        case 'pong':
          debugPrint("🏓 Received pong from server");
          break;

        case 'authenticated':
          debugPrint("🎉 WebSocket authentication successful!");
          final authTransportId = data['data']?['transportId']?.toString();
          debugPrint("🔑 Authenticated with transportId: $authTransportId");

          _isAuthenticating = false;
          _authenticationCompleter?.complete();
          _authenticationCompleter = null;

          // Subscribe if transportId is available
          if (_transportId != null && _transportId!.isNotEmpty && !_isSubscribed) {
            debugPrint("🚗 Setting transportId after authentication: $_transportId");
            _subscribeToDriverLocation(_transportId!);
          }
          break;

        case 'authentication_failed':
          debugPrint("❌ WebSocket authentication failed: ${data['reason']}");
          _lastError.value = 'Authentication failed: ${data['reason']}';
          _isAuthenticating = false;
          _authenticationCompleter?.completeError('Authentication failed');
          _authenticationCompleter = null;
          _refreshTokenAndReconnect();
          break;

        case 'driverLocationUpdate':
          debugPrint("📍📍📍 RECEIVED driverLocationUpdate EVENT 📍📍📍");
          _handleDriverLocationUpdate(data);
          break;

        case 'subscribed':
          debugPrint("✅ Successfully subscribed to driver location: ${data['transportId']}");
          _isSubscribed = true;
          break;

        case 'subscription_failed':
          debugPrint("❌ Subscription failed: ${data['reason']}");
          _lastError.value = 'Subscription failed: ${data['reason']}';
          _isSubscribed = false;
          _handleSubscriptionFailure();
          break;

        case 'info':
          debugPrint("ℹ️ Server info: ${data['message']}");
          // Only authenticate if not already authenticating/authenticated
          if (data['message']?.toString().contains('authenticate') == true &&
              !_isAuthenticating &&
              _authenticationCompleter != null) {
            debugPrint("🔄 Server requesting authentication");
            _authenticate(_riderToken!);
          }
          break;

        case 'error':
          debugPrint("❌ WebSocket error: ${data['message']}");
          _lastError.value = 'Server error: ${data['message']}';

          // Handle specific error cases
          if (data['message']?.toString().contains('Unknown event type') == true) {
            debugPrint("⚠️ Server rejected event - possible protocol mismatch");
          }
          break;

        default:
          debugPrint("❓ WebSocket unknown event: $event, data: $data");
      }
    } catch (e) {
      debugPrint("⚠️ WebSocket message parsing failed: $e");
      debugPrint("⚠️ Raw message: $message");
    }
  }

  void _authenticate(String token) {
    if (!_isConnectedRx.value || _channel == null) {
      debugPrint("❌ Cannot authenticate - WebSocket not connected");
      return;
    }

    if (_isAuthenticating) {
      debugPrint("⚠️ Already authenticating, skipping duplicate authentication");
      return;
    }

    try {
      _isAuthenticating = true;
      final authMessage = jsonEncode({
        "event": "authenticate",
        "token": token,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
      _sendMessage(authMessage);
      debugPrint("🔐 WebSocket authentication sent");
    } catch (e) {
      debugPrint("❌ Error sending authentication: $e");
      _isAuthenticating = false;
    }
  }

  Future<bool> _authenticateAndWait(String token) async {
    if (_isAuthenticating) {
      debugPrint("⚠️ Authentication already in progress");
      return await _authenticationCompleter!.future.then((_) => true).catchError((_) => false);
    }

    _authenticationCompleter = Completer<void>();
    _authenticate(token);

    return await _authenticationCompleter!.future
        .timeout(Duration(seconds: 10), onTimeout: () {
      debugPrint("⏰ Authentication timeout");
      _isAuthenticating = false;
      _lastError.value = 'Authentication timeout';
      return false;
    })
        .then((_) {
      debugPrint("✅ Authentication completed successfully");
      return true;
    })
        .catchError((e) {
      debugPrint("❌ Authentication error: $e");
      _isAuthenticating = false;
      _lastError.value = 'Authentication error: $e';
      return false;
    });
  }

  void _startPingInterval() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnectedRx.value && _channel != null) {
        try {
          final pingMessage = jsonEncode({"event": "ping"});
          _sendMessage(pingMessage);
          debugPrint("🏓 Sent ping");
        } catch (e) {
          debugPrint("❌ Error sending ping: $e");
          _handleDisconnection();
        }
      }
    });
  }

  void _handleDisconnection() {
    _connectionTimer?.cancel();
    _pingTimer?.cancel();
    _isAuthenticating = false;
    _authenticationCompleter?.completeError('Disconnected');
    _authenticationCompleter = null;
    _isSubscribed = false;

    _isConnectedRx.value = false;
    _connectionStatusRx.value = 'disconnected';

    if (retryCount >= maxRetries) {
      _connectionStatusRx.value = 'failed';
      debugPrint("❌ WebSocket connection failed after $maxRetries retries");
      _lastError.value = 'Max retry attempts reached';
      return;
    }

    retryCount++;
    final delay = Duration(seconds: math.min(retryCount * 2, 10));
    debugPrint("⏳ Scheduling reconnect in ${delay.inSeconds}s (attempt $retryCount)");

    _reconnectTimer = Timer(delay, () {
      debugPrint("🔄 Attempting reconnect...");
      initializeWebSocket();
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, initializeWebSocket);
  }

  void _sendMessage(String message) {
    if (!_isConnectedRx.value || _channel == null) {
      debugPrint("❌ Cannot send message - WebSocket not connected");
      return;
    }

    try {
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint("❌ Error sending WebSocket message: $e");
      _lastError.value = 'Send error: $e';
      _handleDisconnection();
    }
  }

  // ADD THIS METHOD TO FIX THE ERROR
  void sendTestMessage() {
    if (!_isConnectedRx.value || _channel == null) {
      debugPrint("❌ WebSocket not connected for test message");
      return;
    }

    try {
      final testMessage = jsonEncode({
        "event": "test",
        "message": "Hello from client",
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });

      _sendMessage(testMessage);
      debugPrint("📤 Sent test message: $testMessage");
    } catch (e) {
      debugPrint("❌ Error sending test message: $e");
    }
  }

  void _handleSubscriptionFailure() {
    if (_transportId != null && _transportId!.isNotEmpty && _isConnectedRx.value && !_isSubscribed) {
      Timer(Duration(seconds: 2), () {
        _subscribeToDriverLocation(_transportId!);
      });
    }
  }

  Future<void> _refreshTokenAndReconnect() async {
    debugPrint("🔄 Refreshing token and reconnecting...");
    try {
      _riderToken = null;
      _riderToken = await AuthController.accessToken;

      if (_riderToken != null && _riderToken!.isNotEmpty) {
        debugPrint("✅ Token refreshed, reconnecting...");
        initializeWebSocket();
      } else {
        debugPrint("❌ Failed to refresh token");
        _lastError.value = 'Token refresh failed';
        _scheduleReconnect();
      }
    } catch (e) {
      debugPrint("❌ Error refreshing token: $e");
      _lastError.value = 'Token refresh error: $e';
      _scheduleReconnect();
    }
  }

  void _handleDriverLocationUpdate(Map<String, dynamic> data) {
    try {
      final transportId = data['transportId']?.toString();
      final lat = double.tryParse(data['lat']?.toString() ?? '');
      final lng = double.tryParse(data['lng']?.toString() ?? '');
      final location = data['location']?.toString() ?? 'Unknown';

      debugPrint("📍📍📍 DRIVER LOCATION UPDATE 📍📍📍");
      debugPrint("🚗 TransportID from server: $transportId");
      debugPrint("🎯 Current TransportID: $_transportId");
      debugPrint("📌 Coordinates: ($lat, $lng)");
      debugPrint("🏠 Location: $location");

      if (transportId != _transportId) {
        debugPrint("❌ TransportId mismatch! Expected: $_transportId, Got: $transportId");
        return;
      }

      if (lat == null || lng == null) {
        debugPrint("❌ Invalid coordinates: ($lat, $lng)");
        return;
      }

      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        debugPrint("❌ Coordinates out of valid range: ($lat, $lng)");
        return;
      }

      final driverPosition = LatLng(lat, lng);
      debugPrint("✅ Processing driver location for transportId: $transportId - $driverPosition");

      _executeLocationCallbacks(driverPosition, 'Driver ($location)');
    } catch (e) {
      debugPrint("❌ Error handling driver location update: $e");
    }
  }

  void _executeLocationCallbacks(LatLng position, String label) {
    if (_locationUpdateCallbacks.isEmpty) {
      debugPrint("⚠️ No callbacks registered for location updates");
      return;
    }

    for (var i = _locationUpdateCallbacks.length - 1; i >= 0; i--) {
      try {
        _locationUpdateCallbacks[i](position, label);
      } catch (e) {
        debugPrint("❌ Error in location callback at index $i: $e");
        _locationUpdateCallbacks.removeAt(i);
      }
    }
  }

  void _subscribeToDriverLocation(String transportId) {
    if (!_isConnectedRx.value || _channel == null) {
      debugPrint("❌ Cannot subscribe - WebSocket not connected");
      return;
    }

    if (_isSubscribed) {
      debugPrint("⚠️ Already subscribed to transportId: $transportId");
      return;
    }

    try {
      final subscribeMessage = jsonEncode({
        "event": "subscribeDriverLocation",
        "transportId": transportId,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
      _sendMessage(subscribeMessage);
      _isSubscribed = true;
      debugPrint("📡 Subscribed to driver location for transportId: $transportId");
    } catch (e) {
      debugPrint("❌ Error subscribing to driver location: $e");
      _isSubscribed = false;
    }
  }

  void addLocationUpdateCallback(void Function(LatLng, String) callback) {
    if (!_locationUpdateCallbacks.contains(callback)) {
      _locationUpdateCallbacks.add(callback);
      debugPrint("✅ Added location update callback, total: ${_locationUpdateCallbacks.length}");
    }
  }

  void removeLocationUpdateCallback(Function(LatLng, String) callback) {
    _locationUpdateCallbacks.remove(callback);
    debugPrint("🗑️ Removed location update callback, remaining: ${_locationUpdateCallbacks.length}");
  }

  void setTransportId(String? transportId) {
    if (transportId != null && transportId.isNotEmpty) {
      if (_transportId != transportId) {
        _transportId = transportId;
        _isSubscribed = false; // Reset subscription state for new transportId
        debugPrint("🚗 TransportId set: $_transportId");

        if (_isConnectedRx.value && _channel != null) {
          // Wait a bit for authentication if needed, then subscribe
          Timer(Duration(milliseconds: 1000), () {
            _subscribeToDriverLocation(_transportId!);
          });
        }
      }
    } else {
      debugPrint("⚠️ Invalid transportId: $transportId");
      _transportId = null;
      _isSubscribed = false;
    }
  }

  void close() {
    debugPrint("🛑 Manually closing WebSocket connection");
    _cleanup();
  }

  void reconnect() {
    debugPrint("🔄 Manual reconnect triggered");
    retryCount = 0;
    initializeWebSocket();
  }

  void debugWebSocketStatus() {
    debugPrint("=== 🔍 WebSocket Debug Info ===");
    debugPrint("🔗 Connection Status: ${_connectionStatusRx.value}");
    debugPrint("📡 Is Connected: ${_isConnectedRx.value}");
    debugPrint("🚗 Current TransportId: $_transportId");
    debugPrint("🔄 Retry Count: $retryCount");
    debugPrint("🔑 Rider Token: ${_riderToken != null ? 'Available' : 'NULL'}");
    debugPrint("📞 Callbacks Registered: ${_locationUpdateCallbacks.length}");
    debugPrint("❌ Last Error: ${_lastError.value}");
    debugPrint("🌐 WebSocket URL: $wsUrl");
    debugPrint("📡 Subscribed: $_isSubscribed");
    debugPrint("🔐 Authenticating: $_isAuthenticating");
    debugPrint("===============================");
  }
}