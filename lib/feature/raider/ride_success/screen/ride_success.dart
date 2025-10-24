import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/global_widegts/custom_button.dart';
import '../../rating_rider/screen/rating_rider.dart';

class RideSuccess extends StatelessWidget {
  const RideSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                "assets/images/cross.png",
                width: 50,
                height: 50,
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/ride_success.png",
                width: size.width * 0.6,
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: CustomButton(
                title: "Give Compliment",
                backgroundColor: Color(0xFFFFDC71),
                borderColor: Colors.transparent,
                onPress: () {
                  Get.to(() => RatingScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
