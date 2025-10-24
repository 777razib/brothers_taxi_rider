import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../location_picker/screen/location_picker.dart';
import '../controler/confirm_pickup_controller.dart';

class ExpandedBottomSheet3 extends StatelessWidget {
  ExpandedBottomSheet3({super.key});

  final ConfirmPickupController controller = Get.put(ConfirmPickupController());

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.1,
      maxChildSize: 0.7,
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Trip details",
                    style: globalTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Divider(),
                SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(width: 0.4, color: Colors.black45),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First row
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ), // Location icon
                              SizedBox(
                                width: 10,
                              ), // Space between icon and text
                              Text(
                                'Meet at the pick-up point for \nRode No.12, North',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(
                                Icons.share_location,
                                color: Colors.black,
                              ), // Location icon
                              SizedBox(
                                width: 10,
                              ), // Space between icon and text
                              Text(
                                'Washing tone DC',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 50,
                      child: InkWell(
                        onTap: () => Get.to(() => LocationPicker()),
                        child: Image.asset(
                          "assets/images/add.png",
                          fit: BoxFit.contain,
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/card.png",
                      width: 35,
                      height: 35,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "\$186.00",
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFF1F1F1),
                        ),
                        child: Text(
                          "Switch",
                          style: globalTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButton(
                  title: "Unconfirm trip",
                  borderColor: Colors.transparent,
                  backgroundColor: Color(0xFFF1F1F1),
                  textStyle: globalTextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  onPress: () {
                    controller.changeSheet(4);
                  },
                ),
                SizedBox(height: 20),
                CustomButton(
                  title: "Close",
                  borderColor: Colors.transparent,
                  textStyle: globalTextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Color(0xFFFFDC71),
                  onPress: () {
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
