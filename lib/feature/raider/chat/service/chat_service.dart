/*
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String url, String token) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _authenticate(token);

      if (kDebugMode) {
        print("WebSocket connected successfully to: $url");
      }
    } catch (e) {
      _isConnected = false;
      if (kDebugMode) {
        print("WebSocket connection failed: $e");
      }
    }
  }

  void _authenticate(String token) {
    if (_channel == null) return;

    final authMessage = jsonEncode({"event": "authenticate", "token": token});
    _channel!.sink.add(authMessage);
    if (kDebugMode) {
      print("Sent authentication message: $authMessage");
    }
  }

  Stream get messages => _channel?.stream ?? const Stream.empty();

  void sendMessage(String event, Map<String, dynamic> data) {
    if (_channel == null || !_isConnected) {
      if (kDebugMode) {
        print("WebSocket channel is not connected. Cannot send message: $event");
      }
      return;
    }

    try {
      final message = jsonEncode({"event": event, ...data});
      _channel!.sink.add(message);
      if (kDebugMode) {
        print("Sent WebSocket message: $message");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending WebSocket message: $e");
      }
    }
  }

  void close() {
    if (kDebugMode) {
      print("Closing WebSocket connection.");
    }
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }
}*/
