import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/style/global_text_style.dart';
import '../../pickup_accept/screen/pickup_accept.dart';
import '../controler/confirm_pickup_controller.dart';

class LineProgressController extends GetxController {
  var percentage = 0.obs;

  // Timer variable
  late Timer _timer;
  void startProgress() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (percentage.value < 100) {
        percentage.value += 1;
      } else {
        _timer.cancel();
        Get.to(() => PickupAcceptScreen());
      }
    });
  }

  @override
  void onInit() {
    startProgress();
    super.onInit();
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}



class ExpandedBottomSheet2 extends StatelessWidget {
  ExpandedBottomSheet2({super.key});

  final ConfirmPickupController controller = Get.put(ConfirmPickupController());
  final LineProgressController controllerLineProgress = Get.put(
    LineProgressController(),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Trip requested ",
                    style: globalTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Finding drivers nearby ",
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Obx(
                  () => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controllerLineProgress.percentage.value / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFDC71),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 243, 243),
                    border: Border.all(width: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trip",
                              style: globalTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFf777F8B),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Meet at the pick-up point",
                              style: globalTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            controller.changeSheet(3);
                          },
                          child: Image.asset(
                            "assets/images/option_button.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
