import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../core/network_caller/endpoints.dart';
import '../service/chat_service.dart';
import 'upload_service.dart';

class ChatController extends GetxController {
  final WebSocketService _socketService = Get.put(WebSocketService());
  final UploadService _uploadService = Get.put(UploadService());
  final ImagePicker _picker = ImagePicker();

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isConnected = false.obs;
  var currentChatId = ''.obs;
  var selectedImagePath = ''.obs;
  String? token;
  Timer? _imagePickDebounceTimer;
  bool _isPickingImage = false;
  StreamSubscription? _messagesSubscription;
  bool _isFetching = false;
  int _fetchRetryCount = 0;
  static const int maxFetchRetries = 3;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  void _setupListeners() {
    ever(_socketService.connectionStatus, (status) {
      isConnected.value = status == 'connected';
      print("ChatController: Connection status changed to: $status");

      if (status == 'failed') {
        Get.snackbar(
          "Connection Failed",
          "Unable to connect to chat server. Please check your internet connection.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 8),
          mainButton: TextButton(
            onPressed: () {
            if (token != null && currentChatId.value.isNotEmpty) {
              connectSocket(Urls.socketUrl, token!, currentChatId.value);
            }
          },
            child: const Text("Retry"),
          ),
        );
      } else if (status == 'connected') {
        print("ChatController: Successfully connected to chat server");
        if (_socketService.isAuthenticated.value) {
          fetchMessages();
        }
      } else if (status == 'connecting') {
        print("ChatController: Connecting to chat server...");
      }
    });

    ever(_socketService.isAuthenticated, (auth) {
      if (auth) {
        print("ChatController: Authentication successful, fetching messages...");
        fetchMessages();
      } else if (isConnected.value) {
        Get.snackbar(
          "Authentication Issue",
          "Waiting for server authentication...",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    });

    _messagesSubscription = _socketService.messages.listen((data) {
      _handleMessage(data);
    });
  }

  void connectSocket(String url, String token, String carTransportId) async {
    print("ChatController: Connecting with carTransportId -> $carTransportId");
    this.token = token;
    currentChatId.value = carTransportId;
    _socketService.connect(url, token);
  }

  void _handleMessage(Map<String, dynamic> data) {
    final event = data['event']?.toString() ?? '';
    print("ChatController: Handling event -> $event");

    switch (event) {
      case 'authenticated':
        print("ChatController: Authentication successful");
        isLoading.value = false;
        fetchMessages();
        break;
      case 'Messages':
        final msgList = data['data']?['messages'] ?? data['data'] ?? [];
        print("ChatController: Received ${msgList.length} messages");
        messages.assignAll(List<Map<String, dynamic>>.from(msgList));
        isLoading.value = false;
        _isFetching = false;
        _fetchRetryCount = 0; // Reset retry count on success
        break;
      case 'Message':
        final msg = data['data'] ?? data;
        if (msg['carTransportId'] == currentChatId.value) {
          // Remove temp message if exists
          messages.removeWhere((m) => m['isTemp'] == true && m['id'] == msg['tempId']);
          // Add new message if not already exists
          if (!messages.any((m) => m['id'] == msg['id'])) {
            messages.add(msg);
          }
        }
        break;
      case 'message_sent':
      case 'messageSent':
        final msg = data['data'] ?? data;
        if (msg != null && msg['carTransportId'] == currentChatId.value) {
          // Remove temp message
          messages.removeWhere((m) => m['isTemp'] == true && m['id'] == msg['tempId']);
          // Add confirmed message
          if (!messages.any((m) => m['id'] == msg['id'])) {
            messages.add(msg);
          }
        }
        break;
      case 'info':
        print("ChatController: Info -> ${data['message']}");
        break;
      case 'error':
        final errorMessage = data['message']?.toString() ?? 'Unknown error';
        print("ChatController: Error -> $errorMessage");
        isLoading.value = false;
        _isFetching = false;

        if (errorMessage.contains('carTransportId')) {
          _fetchRetryCount++;
          if (_fetchRetryCount <= maxFetchRetries) {
            print("ChatController: carTransportId error, retrying... ($_fetchRetryCount/$maxFetchRetries)");
            Timer(const Duration(seconds: 2), () {
              fetchMessages();
            });
          } else {
            print("ChatController: Max retry attempts reached for carTransportId error");
            Get.snackbar("Connection Error", "Unable to load messages. Please try again later.");
            _fetchRetryCount = 0;
          }
        } else if (errorMessage.contains('not found')) {
          Get.back();
          Get.snackbar("Ride Error", "This ride is no longer available.");
        } else if (errorMessage.contains('token') || errorMessage.contains('auth')) {
          Get.snackbar("Authentication Error", "Session expired. Please log in again.", 
            onTap: (_) => Get.offAllNamed('/login'));
        } else if (errorMessage == 'Unknown event type') {
          print("ChatController: Unknown event type - this is normal");
        } else {
          print("ChatController: Other error -> $errorMessage");
        }
        break;
      default:
        print("ChatController: Unknown event -> $event");
    }
  }

  void fetchMessages() {
    if (currentChatId.value.isEmpty || _isFetching) {
      print("ChatController: Cannot fetch messages, carTransportId is empty or already fetching.");
      return;
    }
    if (!isConnected.value || !_socketService.isAuthenticated.value) {
      print("ChatController: Cannot fetch messages, socket not ready.");
      isLoading.value = true;
      return;
    }

    _isFetching = true;
    isLoading.value = true;
    _socketService.send({
      "event": "fetchMessages",
      "carTransportId": currentChatId.value,
    });
    print("ChatController: Sent fetchMessages for ${currentChatId.value}");
  }

  void sendText(String text) async {
    if (text.trim().isEmpty) return;

    if (!_socketService.isConnected.value || !_socketService.isAuthenticated.value) {
      Get.snackbar("Connection Issue", "Message will be sent upon reconnection.");
      return;
    }

    final senderId = await AuthController.getUserId();
    if (senderId == null) {
      Get.snackbar("Error", "Could not get user ID. Please log in again.");
      return;
    }

    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final tempMsg = {
      "id": tempId,
      "message": text.trim(),
      "carTransportId": currentChatId.value,
      "senderId": senderId,
      "createdAt": DateTime.now().toIso8601String(),
      "isTemp": true,
      "status": "sending",
    };
    messages.add(tempMsg);

    _socketService.send({
      "event": "Message",
      "carTransportId": currentChatId.value,
      "message": text.trim(),
      "senderId": senderId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "tempId": tempId,
    });
  }

  Future<void> sendImage(File file) async {
    final tempId = "temp_img_${DateTime.now().millisecondsSinceEpoch}";
    try {
      // Get token
      if (token == null || token!.isEmpty) {
        token = await AuthController.accessToken;
        if (token == null || token!.isEmpty) {
          Get.snackbar("Error", "Authentication required.", onTap: (_) => Get.offAllNamed('/login'));
          return;
        }
      }

      // Get sender ID
      final senderId = await AuthController.getUserId();
      if (senderId == null) {
        Get.snackbar("Error", "Could not get user ID.");
        return;
      }

      // Check connection
      if (!_socketService.isConnected.value || !_socketService.isAuthenticated.value) {
        Get.snackbar("Connection Error", "Not connected to chat server.");
      return;
    }

      // Add temp message
      final tempMsg = {
        "id": tempId,
        "message": "📎 Sending image...",
        "carTransportId": currentChatId.value,
        "senderId": senderId,
        "images": [file.path],
        "createdAt": DateTime.now().toIso8601String(),
        "isTemp": true,
        "status": "uploading",
      };
      messages.add(tempMsg);

      print("ChatController: Starting image upload...");
    final imageUrl = await _uploadService.uploadFile(file, token!);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        print("ChatController: Image uploaded successfully: $imageUrl");
        messages.removeWhere((m) => m['id'] == tempId);

        // Send message with image
      _socketService.send({
        "event": "Message",
        "carTransportId": currentChatId.value,
          "message": "📎 Image sent",
        "images": [imageUrl],
          "senderId": senderId,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "tempId": tempId,
      });
        
        Get.snackbar("Success", "Image sent successfully!", duration: const Duration(seconds: 2));
    } else {
        print("ChatController: Image upload failed");
        messages.removeWhere((m) => m['id'] == tempId);
        Get.snackbar("Upload Failed", "Could not upload image. Please try again.");
      }
    } catch (e) {
      print("ChatController: Image upload error -> $e");
      messages.removeWhere((m) => m['id'] == tempId);
      Get.snackbar("Upload Error", "Failed to upload image: $e");
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    if (_isPickingImage) return;

    _imagePickDebounceTimer?.cancel();
    _imagePickDebounceTimer = Timer(
      const Duration(milliseconds: 500),
          () async {
        _isPickingImage = true;
        try {
          final picked = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1024, maxHeight: 1024);
          if (picked != null) {
            final file = File(picked.path);
            if (await file.length() > 10 * 1024 * 1024) {
              Get.snackbar("File Too Large", "Please select an image under 10MB.");
              return;
            }
            await sendImage(file);
          } else {
            print("ChatController: No image selected");
          }
        } catch (e) {
          Get.snackbar("Error", "Failed to pick image: $e");
        } finally {
          _isPickingImage = false;
        }
      },
    );
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _socketService.disconnect();
    _imagePickDebounceTimer?.cancel();
    super.onClose();
  }
}