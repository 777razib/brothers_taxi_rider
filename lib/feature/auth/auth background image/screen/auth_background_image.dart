import 'package:flutter/material.dart';

class AuthBackgroundImage extends StatelessWidget {
  const AuthBackgroundImage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/images/loginBackgroundImages.png",
          fit: BoxFit.cover, // fills background
        ),
        child, // sits on top of background
      ],
    );
  }
}
