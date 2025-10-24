import 'package:flutter/material.dart';

class ProfileActionWidgets extends StatelessWidget {
  const ProfileActionWidgets({
    super.key,
    required this.voidCallback,
    required this.actionName,
    required this.image,
    this.iconData,
    required this.style,
    this.size,
  });

  final VoidCallback voidCallback;
  final String actionName;
  final String image;
  final IconData? iconData;
  final TextStyle style;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidCallback,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Color(0xFFEDEDF3)),
        ),
        child: Row(
          children: [
            SizedBox(height: 40, width: 40, child: Image.asset(image)),
            const SizedBox(width: 14),
            Text(actionName, style: style),
            Spacer(),
            SizedBox(height: 18, width: 18, child: Icon(iconData, size: size)),
          ],
        ),
      ),
    );
  }
}
