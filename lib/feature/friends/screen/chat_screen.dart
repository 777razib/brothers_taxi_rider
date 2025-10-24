import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services_class/shared_preferences_data_helper.dart';
import '../controller/chat_controller.dart';
import '../../../core/network_caller/endpoints.dart';
import '../../../core/style/global_text_style.dart';
import '../service/chat_service.dart';
import 'app_constants.dart';

class ChatScreen extends StatefulWidget {
  final String carTransportId;
  final String token;

  const ChatScreen({
    super.key,
    required this.carTransportId,
    required this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController.connectSocket(
      Urls.socketUrl,
      widget.token,
      widget.carTransportId,
    );

    ever(chatController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: false,
        backgroundColor: AppConstants.whiteColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Padding(
            padding: EdgeInsets.only(left: 16.r),
            child: Container(
              height: 22.h,
              width: 22.w,
              padding: EdgeInsets.all(6.r),
              child:  Icon(
                Icons.arrow_back,
                color: AppConstants.orangeAccent,
              ),
            ),
          ),
        ),
        actions: [
          Obx(
                () => Padding(
              padding: EdgeInsets.all(8.r),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: chatController.isConnected.value &&
                          Get.find<WebSocketService>().isAuthenticated.value
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    chatController.isConnected.value &&
                        Get.find<WebSocketService>().isAuthenticated.value
                        ? "Online"
                        : "Offline",
                    style: globalTextStyle(
                      fontSize: 12.sp,
                      color: chatController.isConnected.value &&
                          Get.find<WebSocketService>().isAuthenticated.value
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Obx(
                () => chatController.isLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (chatController.isLoading.value && chatController.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (chatController.messages.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("No messages yet...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      final displayedMessages = chatController.messages.reversed.take(50).toList();
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(12.r),
        reverse: true,
        itemCount: displayedMessages.length,
        itemBuilder: (context, index) {
          final msg = displayedMessages[index];
          return _buildMessageBubble(msg);
        },
      );
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    return FutureBuilder<String?>(
      future: AuthController.getUserId(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data ?? '';
        final isMine = msg['senderId'] == currentUserId;
        final opacity = msg['isTemp'] == true ||
            msg['status'] == 'sending' ||
            msg['status'] == 'uploading'
            ? 0.6
            : 1.0;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Opacity(
              opacity: opacity,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isMine
                      ? AppConstants.blackColor
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isMine
                        ? const Radius.circular(12)
                        : const Radius.circular(4),
                    bottomRight: isMine
                        ? const Radius.circular(4)
                        : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (msg['images'] != null &&
                        msg['images'] is List &&
                        msg['images'].isNotEmpty)
                      ...msg['images'].take(1).map<Widget>((url) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 5.h),
                          child: Image.network(
                            url.startsWith('http') ? url : 'file://$url',
                            width: 150.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 150.w,
                                height: 100.h,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150.w,
                              height: 100.h,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        );
                      }).toList(),
                    if (msg['message'] != null &&
                        msg['message'].toString().isNotEmpty)
                      Text(
                        msg['message'],
                        style: globalTextStyle(
                          fontSize: 16.sp,
                          color: isMine ? AppConstants.whiteColor : Colors.black,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        _formatTimestamp(msg['createdAt']),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isMine
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                    if (msg['status'] != null) _buildMessageStatus(msg['status']),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageStatus(String status) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case 'sending':
        icon = Icons.access_time;
        color = Colors.white;
        tooltip = 'Sending...';
        break;
      case 'sent':
        icon = Icons.done;
        color = Colors.white;
        tooltip = 'Sent';
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.blue;
        tooltip = 'Delivered';
        break;
      case 'read':
        icon = Icons.done_all;
        color = Colors.green;
        tooltip = 'Read';
        break;
      case 'uploading':
        icon = Icons.cloud_upload;
        color = Colors.white;
        tooltip = 'Uploading...';
        break;
      default:
        icon = Icons.error;
        color = Colors.red;
        tooltip = 'Error';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 12.sp, color: color),
    );
  }

  String _formatTimestamp(dynamic createdAt) {
    try {
      if (createdAt is String && createdAt.isNotEmpty) {
        final dt = DateTime.tryParse(createdAt);
        if (dt != null) {
          final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final m = dt.minute.toString().padLeft(2, '0');
          final ampm = dt.hour >= 12 ? 'PM' : 'AM';
          return '$h:$m $ampm';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo, color: Colors.green),
              onPressed: () async {
                await chatController.pickImage(source: ImageSource.gallery);
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.green),
              onPressed: () async {
                await chatController.pickImage(source: ImageSource.camera);
              },
            ),
            Expanded(
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (text) => _sendMessage(),
              ),
            ),
            Obx(
                  () => IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: chatController.isConnected.value &&
                    Get.find<WebSocketService>().isAuthenticated.value
                    ? _sendMessage
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      chatController.sendText(text);
      _msgController.clear();
    }
  }
}