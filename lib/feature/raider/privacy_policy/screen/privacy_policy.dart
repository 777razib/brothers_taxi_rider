import 'package:flutter/material.dart';

import '../../../../core/style/global_text_style.dart';

class PrivacyPolicy extends StatelessWidget {
  PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy policy ",
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(text, style: globalTextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  String text =
      "Welcome to [App Name]. These Terms and Conditions govern your use of our mobile application and any related services. By using the app, you agree to these terms. If you do not agree, please discontinue use of the app. To use this app, you must be at least 18 years old. By creating an account, you confirm that the information you provide is accurate and that you are the legal owner or guardian of the dog profile you otp. You are responsible for keeping your account secure and agree not to impersonate anyone or provide false information. This app is designed to help dog owners connect and arrange meetups. You are solely responsible for your safety and your dog’s safety during any in-person meetings. We do not verify or monitor raider behavior or meetups and cannot be held liable for any incidents, injuries, or disputes that occur during such events. We encourage respectful behavior and compliance with local pet laws, including leash regulations. The app may request access to your add location to provide nearby dog or park suggestions. You may control these settings from your device at any time. Notifications may also be sent for messages, event reminders, or updates relevant to your usage.";
}
