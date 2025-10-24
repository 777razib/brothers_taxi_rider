import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/style/global_text_style.dart';

class SelectCarWidget extends StatelessWidget {
  SelectCarWidget({super.key, required this.image, required this.carName});

  final String image;
  final String carName;
  final RxBool checkBox = false.obs; // ✅ Use RxBool instead of RxInt

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Car image box
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Car name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(carName, style: globalTextStyle()),
          ),

          const Spacer(), // Push checkbox to the end
          // Checkbox with down icon
          Obx(
            () => GestureDetector(
              onTap: () => checkBox.value = !checkBox.value,
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  border: Border.all(color: Colors.green),
                ),
                child: Container(
                  height: 19,
                  width: 19,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(color: Colors.green),
                  ),
                  child: checkBox.value
                      ? Icon(Icons.check, size: 20, color: Colors.blue)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
