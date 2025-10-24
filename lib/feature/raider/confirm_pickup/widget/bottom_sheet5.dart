
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../bottom_nav_user/screen/bottom_nav_user.dart';
import '../controler/confirm_pickup_controller.dart';

class ExpandedBottomSheet5 extends StatelessWidget {
  ExpandedBottomSheet5({super.key});

  final ConfirmPickupController controller = Get.put(ConfirmPickupController());

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Text(
                      "Cancel trip?",
                      style: globalTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.changeSheet(2),
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  "Why do you want to cancel? ",
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "This trip is being offered to a driver right now and should be confirmed within seconds.",
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 25),
                CustomButton(
                  title: "Cancel request ",
                  borderColor: Colors.transparent,
                  backgroundColor: Color(0xFFF1F1F1),
                  textStyle: globalTextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  onPress: () {
                    Get.to(() => BottomNavbarUser());
                  },
                ),
                SizedBox(height: 10),
                CustomButton(
                  title: "Wait for driver ",
                  borderColor: Colors.transparent,
                  textStyle: globalTextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Color(0xFFFFDC71),
                  onPress: () {
                    controller.selectContainerEffect(0);

                    controller.changeSheet(2);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}