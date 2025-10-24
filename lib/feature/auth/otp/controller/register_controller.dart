import 'package:get/get.dart';

class RegisterController extends GetxController {
  var countryCode = '+44'.obs;
  var phoneNumber = ''.obs;

  void setPhoneNumber(String number) {
    phoneNumber.value = number;
  }

  void setCountryCode(String code) {
    countryCode.value = code;
  }
}
