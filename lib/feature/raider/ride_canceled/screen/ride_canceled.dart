import 'package:flutter/material.dart';


class RideCanceled extends StatelessWidget {
  const RideCanceled({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/images/cross.png",
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/ride_cancel.png",
                width: size.width * 0.6,
              ),
            ),
            SizedBox(height: 50),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
