import 'package:flutter/material.dart';

class BackgroundImageForLocation extends StatelessWidget {
  const BackgroundImageForLocation({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/Location010.png"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), // shadow color
                blurRadius: 10,  // spread of shadow
                offset: const Offset(0, 4), // shadow position
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
