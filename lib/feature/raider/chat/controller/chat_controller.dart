/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:brother_taxi_riders/core/services_class/shared_preferences_data_helper.dart';
import 'package:brother_taxi_riders/feature/raider/chat/service/chat_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  final WebSocketService webSocketService = WebSocketService();
  final RxBool _isWebSocketConnected = false.obs;
  final RxList<Map<String, dynamic>> chats = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingChats = false.obs;
  final RxString selectedImagePath = ''.obs;
  final RxBool isOptionsVisible = false.obs;
  final RxBool isPeerTyping = false.obs;
  final RxString currentChatId = ''.obs;

  Timer? _typingTimer;
  Timer? _peerTypingTimer;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // TODO: Replace with your actual token and WebSocket URL
    String token = "your_auth_token_here";
    String webSocketUrl = "ws://your-websocket-url.com";

    webSocketService.connect(webSocketUrl, token);
    _isWebSocketConnected.value = webSocketService.isConnected;

    // Listen to WebSocket messages
    webSocketService.messages.listen(
          (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        if (kDebugMode) {
          print("WebSocket error: $error");
        }
        _isWebSocketConnected.value = false;
      },
      onDone: () {
        if (kDebugMode) {
          print("WebSocket connection closed");
        }
        _isWebSocketConnected.value = false;
      },
    );
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      if (kDebugMode) {
        print("Received WebSocket message: $message");
      }

      // Parse the message and handle different events
      // Example: typing indicators, new messages, etc.
      final data = jsonDecode(message);
      final event = data['event'];

      switch (event) {
        case 'typing':
          _handleTypingEvent(data);
          break;
        case 'new_message':
          _handleNewMessage(data);
          break;
        case 'message_delivered':
          _handleMessageDelivered(data);
          break;
        default:
          if (kDebugMode) {
            print("Unknown WebSocket event: $event");
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error handling WebSocket message: $e");
      }
    }
  }

  void _handleTypingEvent(Map<String, dynamic> data) {
    final isTyping = data['isTyping'] ?? false;
    isPeerTyping.value = isTyping;

    // Auto-hide typing indicator after 3 seconds
    if (isTyping) {
      _peerTypingTimer?.cancel();
      _peerTypingTimer = Timer(const Duration(seconds: 3), () {
        isPeerTyping.value = false;
      });
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    // Add new message to chats
    final newMessage = {
      'id': data['id'],
      'message': data['message'],
      'senderId': data['senderId'],
      'images': data['images'] ?? [],
      'createdAt': data['createdAt'],
    };

    chats.insert(0, newMessage);
  }

  void _handleMessageDelivered(Map<String, dynamic> data) {
    // Update message status
    final messageId = data['messageId'];
    final index = chats.indexWhere((chat) => chat['id'] == messageId);
    if (index != -1) {
      chats[index]['status'] = 'delivered';
      chats.refresh();
    }
  }

  void userTyping(String chatId) {
    if (!webSocketService.isConnected) {
      if (kDebugMode) {
        print("WebSocket not connected, cannot send typing indicator");
      }
      return;
    }

    webSocketService.sendMessage('typing', {
      'chatId': chatId,
      'isTyping': true,
    });

    // Clear previous timer
    _typingTimer?.cancel();

    // Set timer to send typing stopped
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _sendTypingStopped(chatId);
    });
  }

  void _sendTypingStopped(String chatId) {
    if (!webSocketService.isConnected) return;

    webSocketService.sendMessage('typing', {
      'chatId': chatId,
      'isTyping': false,
    });
  }

  Future<void> fetchChats(String carTransportId) async {
    try {
      isLoadingChats.value = true;
      // TODO: Implement your API call to fetch chats
      // Example:
      // final response = await ChatApi.getChats(carTransportId);
      // chats.assignAll(response.data);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Temporary mock data
      chats.assignAll([
        {
          'id': '1',
          'message': 'Hello!',
          'senderId': 'user1',
          'images': [],
          'createdAt': DateTime.now().toIso8601String(),
        }
      ]);

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching chats: $e");
      }
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoadingChats.value = false;
    }
  }

  Future<void> sendMessage(String carTransportId, String message) async {
    if (message.trim().isEmpty) return;

    try {
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': message,
        'senderId': await _getCurrentUserId(),
        'images': [],
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'sending',
      };

      // Add to local list immediately
      chats.insert(0, newMessage);

      // TODO: Implement API call to send message
      // await ChatApi.sendMessage(carTransportId, message);

      // Update status after successful send
      final index = chats.indexWhere((chat) => chat['id'] == newMessage['id']);
      if (index != -1) {
        chats[index]['status'] = 'sent';
        chats.refresh();
      }

      // Send via WebSocket if connected
      if (webSocketService.isConnected) {
        webSocketService.sendMessage('send_message', {
          'chatId': carTransportId,
          'message': message,
          'images': [],
        });
      }

    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  Future<void> uploadImage(String carTransportId, String message) async {
    if (selectedImagePath.value.isEmpty) return;

    try {
      final file = File(selectedImagePath.value);
      if (!await file.exists()) {
        Get.snackbar('Error', 'Selected image not found');
        return;
      }

      // Create temporary message with uploading state
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': message,
        'senderId': await _getCurrentUserId(),
        'images': [selectedImagePath.value], // Local path temporarily
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'uploading',
      };

      chats.insert(0, newMessage);

      // TODO: Implement image upload API
      // final imageUrl = await ChatApi.uploadImage(file);

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // Update message with actual image URL
      final index = chats.indexWhere((chat) => chat['id'] == newMessage['id']);
      if (index != -1) {
        chats[index]['images'] = ['https://example.com/uploaded-image.jpg']; // Replace with actual URL
        chats[index]['status'] = 'sent';
        chats.refresh();
      }

      // Send via WebSocket if connected
      if (webSocketService.isConnected) {
        webSocketService.sendMessage('send_message', {
          'chatId': carTransportId,
          'message': message,
          'images': ['https://example.com/uploaded-image.jpg'],
        });
      }

      // Clear selected image
      selectedImagePath.value = "";

    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      Get.snackbar('Error', 'Failed to upload image');

      // Remove failed message
      chats.removeWhere((chat) => chat['status'] == 'uploading');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        isOptionsVisible.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking image: $e");
      }
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<String> _getCurrentUserId() async {
    // TODO: Implement getting current user ID from auth service
    return await AuthController.getUserId() ?? 'unknown_user';
  }

  @override
  void onClose() {
    webSocketService.close();
    _typingTimer?.cancel();
    _peerTypingTimer?.cancel();
    super.onClose();
  }
}*/
