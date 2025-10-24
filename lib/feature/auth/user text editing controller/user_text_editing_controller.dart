import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserTextEditingController extends GetxController {
  TextEditingController phone = TextEditingController();
  TextEditingController countryCode = TextEditingController(text: '+1');
  TextEditingController otp = TextEditingController();

  // Store the selected country code object
  CountryCode? selectedCountryCode;

  /// Getter to return country code + phone together
  String get countryCodeAndPhone => "${countryCode.text}${phone.text}".trim();


  /// Get the current country code display text
  String get currentCountryCodeDisplay {
    if (selectedCountryCode != null) {
      return selectedCountryCode!.dialCode ?? '+1';
    }
    return countryCode.text.isNotEmpty ? countryCode.text : '+1';
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure country code has a default value
    if (countryCode.text.isEmpty) {
      countryCode.text = '+1';
    }
    // Initialize with default US country code
    selectedCountryCode = CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flagUri: '🇺🇸',
    );
  }

  @override
  void onClose() {
    phone.dispose();
    countryCode.dispose();
    otp.dispose();
    super.onClose();
  }
}
