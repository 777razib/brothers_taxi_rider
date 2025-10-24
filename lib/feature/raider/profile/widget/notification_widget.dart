import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/notification_controller.dart';

class NotificationWidget extends StatelessWidget {
  NotificationWidget({
    super.key,
    required this.voidCallback,
    required this.actionName,
    required this.image,
    required this.style,
    required this.tagId,
  });

  final VoidCallback voidCallback;
  final String actionName;
  final String image;
  final TextStyle style;
  final String tagId;

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized only once per tag
    final NotificationController controller = Get.put(
      NotificationController(),
      tag: tagId,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Color(0xFFEDEDF3)),
      ),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            SizedBox(height: 40, width: 40, child: Image.asset(image)),
            const SizedBox(width: 14),
            Text(actionName, style: style),
            const Spacer(),

            Obx(() {
              final switchOn = Get.find<NotificationController>(
                tag: tagId,
              ).isSwitchOn.value;

              return GestureDetector(
                onTap: () {
                  controller.toggleSwitch();
                  voidCallback();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 20,
                  width: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: switchOn ? Colors.amber : Colors.grey.shade400,
                  ),
                  alignment: switchOn
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
