

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../../core/network_caller/endpoints.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  final StreamController<Map<String, dynamic>> _messageController =
  StreamController<Map<String, dynamic>>.broadcast();

  final RxBool isConnected = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString connectionStatus = 'disconnected'.obs;

  String? _currentUrl;
  String? _currentToken;
  Timer? _reconnectTimer;
  Timer? _authTimer;
  int _reconnectAttempts = 0;
  int _authAttempts = 0;
  final List<Map<String, dynamic>> _messageQueue = [];
  bool _manualClose = false;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  Future<bool> _checkNetworkConnectivity() async {
    print("WebSocketService: Checking network connectivity...");
    print("WebSocketService: Base URL -> ${Urls.baseUrl}, Socket URL -> ${Urls.socketUrl}");
    try {
      final addresses = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("WebSocketService: DNS lookup timed out");
          return [];
        },
      );
      if (addresses.isEmpty || addresses[0].rawAddress.isEmpty) {
        print("WebSocketService: No internet detected via DNS lookup");
        return false;
      }
      print("WebSocketService: Internet connectivity confirmed");
      return true;
    } catch (e) {
      print("WebSocketService: Connectivity check failed -> $e");
      return false;
    }
  }

  void connect(String url, String token) async {
    if (_manualClose) return;

    print("WebSocketService: Starting connection to $url");
    _currentUrl = url;
    _currentToken = token;
    connectionStatus.value = 'connecting';
    _authAttempts = 0;
    _reconnectAttempts = 0;

    if (isConnected.value && _channel != null) {
      print("WebSocketService: Already connected, re-authenticating...");
      _authenticate(token);
      return;
    }

    try {
      _cleanup();
      print("WebSocketService: Creating WebSocket connection...");
      _channel = WebSocketChannel.connect(Uri.parse(url));

      isConnected.value = true;
      connectionStatus.value = 'connected';
      print("WebSocketService: WebSocket connection established");

      _streamSubscription?.cancel();
      _streamSubscription = _channel!.stream.listen(
            (event) {
          _handleMessage(event);
        },
        onError: (error) {
          print("WebSocketService: Stream error -> $error");
          _handleDisconnection();
        },
        onDone: () {
          print("WebSocketService: Stream closed");
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      // Wait a bit then authenticate
      Timer(const Duration(milliseconds: 500), () {
        _authenticate(token);
      });

    } catch (e) {
      print("WebSocketService: Connection failed -> $e");
      _handleDisconnection();
    }
  }

  void _authenticate(String token) {
    if (!isConnected.value || _channel == null) {
      _messageQueue.add({"event": "authenticate", "token": token});
      print("WebSocketService: Queued authentication (not connected)");
      return;
    }

    if (_authAttempts >= 2) {
      print("WebSocketService: Max authentication attempts reached");
      _authTimer?.cancel();
      Get.snackbar(
        "Authentication Failed",
        "Unable to authenticate. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            _authAttempts = 0;
            if (_currentUrl != null && _currentToken != null) {
              connect(_currentUrl!, _currentToken!);
            }
          },
          child: const Text("Retry"),
        ),
      );
      return;
    }

    _authAttempts++;
    print("WebSocketService: Authentication attempt $_authAttempts with token: ${token.substring(0, 20)}...");
    
    try {
      final authMessage = {
        "event": "authenticate",
        "token": token,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      };
      
      final jsonMessage = jsonEncode(authMessage);
      _channel!.sink.add(jsonMessage);
      print("WebSocketService: Sent authentication -> $jsonMessage");
      
    } catch (e) {
      print("WebSocketService: Authentication send error -> $e");
    }

    _authTimer?.cancel();
    _authTimer = Timer(const Duration(seconds: 8), () {
      if (!isAuthenticated.value && isConnected.value) {
        print("WebSocketService: Authentication timed out, retrying...");
        _authenticate(token);
      }
    });
  }

  bool _isValidToken(String token) {
    if (token.isEmpty) return false;
    try {
      // Check if it's a JWT token (has 3 parts separated by dots)
      final parts = token.split('.');
      return parts.length == 3;
    } catch (e) {
      return false;
    }
  }

  void _handleMessage(dynamic event) {
    try {
      final decoded = event is String ? jsonDecode(event) : event;
      if (decoded is Map<String, dynamic>) {
        final eventType = decoded['event']?.toString() ?? '';
        print("WebSocketService: Received event -> $eventType");
        
        if (eventType == 'authenticated') {
          isAuthenticated.value = true;
          _authAttempts = 0;
          _authTimer?.cancel();
          _processMessageQueue();
          print("WebSocketService: Successfully authenticated");
        } else if (eventType == 'error') {
          final errorMessage = decoded['message']?.toString() ?? 'Unknown error';
          print("WebSocketService: Error -> $errorMessage");
          
          if (errorMessage.contains('token') || errorMessage.contains('auth')) {
            isAuthenticated.value = false;
            _authTimer?.cancel();
            Get.snackbar(
              "Authentication Error",
              "Session expired. Please log in again.",
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              onTap: (_) => Get.offAllNamed('/login'),
            );
            _handleDisconnection();
          } else if (errorMessage.contains('not found')) {
            Get.snackbar(
              "Ride Error",
              "This ride is no longer available.",
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 5),
              onTap: (_) => Get.back(),
            );
          } else if (errorMessage == 'Unknown event type') {
            print("WebSocketService: Unknown event type - this is normal");
            // Don't show error for unknown events
          } else {
            print("WebSocketService: Server error -> $errorMessage");
            // Don't show snackbar for every error
          }
        } else if (eventType == 'info') {
          print("WebSocketService: Info -> ${decoded['message']}");
        }
        
        _messageController.add(decoded);
      } else {
        print("WebSocketService: Invalid message format -> $event");
      }
    } catch (e) {
      print("WebSocketService: Parse error -> $e for event: $event");
    }
  }

  void _handleDisconnection() {
    if (_manualClose) return;

    isConnected.value = false;
    isAuthenticated.value = false;
    connectionStatus.value = 'disconnected';
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= 3) {
      connectionStatus.value = 'failed';
      print("WebSocketService: Max reconnect attempts reached");
      Get.snackbar(
        "Connection Failed",
        "Unable to connect to server. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
        mainButton: TextButton(
          onPressed: () {
            _reconnectAttempts = 0;
            if (_currentUrl != null && _currentToken != null) {
              connect(_currentUrl!, _currentToken!);
            }
          },
          child: const Text("Retry"),
        ),
        onTap: (_) {
          _reconnectAttempts = 0;
          if (_currentUrl != null && _currentToken != null) {
            connect(_currentUrl!, _currentToken!);
          }
        },
      );
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(2, 10));
    print("WebSocketService: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_currentUrl != null && _currentToken != null && !_manualClose) {
        print("WebSocketService: Attempting reconnect...");
        connect(_currentUrl!, _currentToken!);
      }
    });
  }

  void send(Map<String, dynamic> message) {
    if (!isConnected.value || !isAuthenticated.value || _channel == null) {
      _messageQueue.add(message);
      print("WebSocketService: Queued message -> ${message['event']}");
      if (!isConnected.value) _scheduleReconnect();
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      print("WebSocketService: Sent -> ${message['event']}, payload: $jsonMessage");
    } catch (e) {
      print("WebSocketService: Send error -> $e");
      _messageQueue.add(message);
      _handleDisconnection();
    }
  }

  void _processMessageQueue() {
    if (_messageQueue.isEmpty || !isConnected.value || !isAuthenticated.value) return;

    print("WebSocketService: Processing ${_messageQueue.length} queued messages");
    final queue = List<Map<String, dynamic>>.from(_messageQueue);
    _messageQueue.clear();

    for (var msg in queue) {
      if (msg['event'] == 'authenticate') {
        // Skip authentication messages in queue as we're already authenticated
        continue;
      }
      send(msg);
    }
  }

  void disconnect() {
    _manualClose = true;
    _cleanup();
  }

  void _cleanup() {
    _reconnectTimer?.cancel();
    _authTimer?.cancel();
    _streamSubscription?.cancel();
    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      print("WebSocketService: Error closing channel -> $e");
    }
    _channel = null;
    _streamSubscription = null;
    isConnected.value = false;
    isAuthenticated.value = false;
    connectionStatus.value = 'disconnected';
  }

  @override
  void onClose() {
    _cleanup();
    _messageController.close();
    super.onClose();
  }
}
