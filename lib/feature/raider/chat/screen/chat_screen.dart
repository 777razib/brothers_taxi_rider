/*
import 'dart:io';
import 'package:brother_taxi_riders/core/services_class/shared_preferences_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/style/global_text_style.dart';
import '../controller/chat_controller.dart';
import 'app_constants.dart';

class ChatScreen extends StatefulWidget {
  final String carTransportId;
  // final String name;
  // final String? photos;

  ChatScreen({
    super.key,
    required this.carTransportId,
    // required this.name,
    // this.photos,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatController.fetchChats(widget.carTransportId);


    ever(chatController.chats, (_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.whiteColor,
      leading: _buildBackButton(),
      title: _buildAppBarTitle(),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Padding(
        padding: EdgeInsets.only(left: 16.r),
        child: Container(
          height: 22.h,
          width: 22.w,
          padding: EdgeInsets.all(6.r),
          child: const Icon(Icons.arrow_back, color: AppConstants.orangeAccent),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        // _buildProfileImage(),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   widget.name,
            //   style: globalTextStyle(
            //     color: AppConstants.blackColor,
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w700,
            //   ),
            // ),
            // Text(
            //   'online',
            //   style: globalTextStyle(
            //     color: AppConstants.greenColor,
            //     fontSize: 12.sp,
            //     fontWeight: FontWeight.w400,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  // Widget _buildProfileImage() {
  //   return Container(
  //     height: 32,
  //     width: 32,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8.r),
  //       image: DecorationImage(
  //         image: widget.photos != null && widget.photos!.isNotEmpty
  //             ? NetworkImage(widget.photos!)
  //             : const AssetImage(ImagePath.edit1) as ImageProvider,
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildTypingIndicator(),
          _buildOptionsPanel(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (chatController.isLoadingChats.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (chatController.chats.isEmpty) {
        return const Center(child: Text("No messages found."));
      }

      return ListView.builder(
        controller: scrollController,
        reverse: true,
        itemCount: chatController.chats.length,
        itemBuilder: (context, index) {
          final chat = chatController.chats[chatController.chats.length - 1 - index];
          return _MessageBubble(chat: chat);
        },
      );
    });
  }

  Widget _buildOptionsPanel() {
    return Obx(() => AnimatedSize(
      duration: AppConstants.animationDuration,
      child: chatController.isOptionsVisible.value
          ? _OptionsPanel(chatController: chatController)
          : const SizedBox.shrink(),
    ));
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildMessageInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageInputRow() {
    return Row(
      children: [
        _buildSelectedImagePreview(),
        Expanded(child: _buildMessageTextField()),
      ],
    );
  }

  Widget _buildSelectedImagePreview() {
    return Obx(() {
      if (chatController.selectedImagePath.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Stack(
          children: [
            Image.file(
              File(chatController.selectedImagePath.value),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            _buildRemoveImageButton(),
          ],
        ),
      );
    });
  }

  Widget _buildRemoveImageButton() {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => chatController.selectedImagePath.value = "",
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Icon(
            Icons.close,
            size: 16,
            color: AppConstants.whiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTextField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: TextField(
        controller: _messageController,
        maxLines: null,
        minLines: 1,
        onChanged: (_) {
          if (chatController.currentChatId.value.isNotEmpty) {
            chatController.userTyping(chatController.currentChatId.value);
          } else {
            chatController.userTyping(widget.carTransportId);
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: AppConstants.whiteColor,
          hintText: "Your message",
          hintStyle: TextStyle(
            color: AppConstants.blackColor.withOpacity(0.4),
          ),
          prefixIcon: _buildOptionsButton(),
          suffixIcon: _buildSendButton(),
          border: _buildInputBorder(),
          enabledBorder: _buildInputBorder(),
          focusedBorder: _buildInputBorder(),
        ),
      ),
    );
  }

  Widget _buildOptionsButton() {
    return GestureDetector(
      onTap: () => chatController.isOptionsVisible.toggle(),
      child: const Icon(Icons.add, color: AppConstants.blackColor),
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      icon: const Icon(Icons.send, color: AppConstants.blueAccent),
      onPressed: _sendMessage,
    );
  }

  InputBorder _buildInputBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(15),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    final selectedImage = chatController.selectedImagePath.value;

    if (message.isEmpty && selectedImage.isEmpty) {
      _showEmptyMessageDialog();
      return;
    }

    if (selectedImage.isNotEmpty) {
      chatController.uploadImage(widget.carTransportId, message);
      // chatController.selectedImagePath.value = "";
    } else {
      chatController.sendMessage(widget.carTransportId, message);
    }

    _messageController.clear();
  }

  void _showEmptyMessageDialog() {
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: const Text("Empty message"),
        content: const Text("Please type a message or select an image."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Obx(() {
      if (!chatController.isPeerTyping.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(width: 6),
              Text(
                'typing…',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> chat;
  final ChatController chatController = Get.find<ChatController>();

  _MessageBubble({required this.chat});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(

        future: AuthController.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final userId = snapshot.data ?? '';

          final isMine = chat['senderId'] == userId;


          return Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? AppConstants.whiteColor : const Color(
                    0xFF252525),
                borderRadius: _getBorderRadius(isMine),
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (chat['images'] != null && chat['images'].isNotEmpty)
                    _MessageImage(imageUrl: chat['images'][0]),
                  if (chat['message'] != null && chat['message'].isNotEmpty)
                    _MessageText(message: chat['message']!, isMine: isMine),
                  _MessageTimestamp(createdAt: chat['createdAt']),
                ],
              ),
            ),
          );
        }
    );
  }

  BorderRadius _getBorderRadius(bool isMine) {
    return BorderRadius.only(
      topLeft: isMine ? const Radius.circular(12) : const Radius.circular(4),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(12),
    );
  }
}

class _MessageImage extends StatelessWidget {
  final String imageUrl;

  const _MessageImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Image.network(
        imageUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Text(
            "Image failed to load",
            style: TextStyle(color: Colors.red),
          );
        },
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  final String message;
  final bool isMine;

  const _MessageText({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: globalTextStyle(
        color: isMine ? AppConstants.blackColor : AppConstants.whiteColor.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _OptionsPanel extends StatelessWidget {
  final ChatController chatController;

  const _OptionsPanel({required this.chatController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: chatController.pickImage,
              child: Image.asset(
                "assets/icons/car.png",
                width: 35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTimestamp extends StatelessWidget {
  final dynamic createdAt;

  const _MessageTimestamp({required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final String label = _format(createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  String _format(dynamic value) {
    try {
      if (value is String && value.isNotEmpty) {
        final dt = DateTime.tryParse(value);
        if (dt != null) return _hhmm(dt);
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  String _hhmm(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}*/
