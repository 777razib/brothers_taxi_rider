import 'package:get/get.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../user text editing controller/user_text_editing_controller.dart';
import '../model/rider_model.dart';

class LoginApiRiderController extends GetxController {
  var isChecked = false.obs;
  var isPasswordHidden = true.obs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserTextEditingController userTextEditingController =
  Get.put(UserTextEditingController());


  Future<bool> loginApiRiderMethod() async {
    bool isSuccess = false;
    try {
      Map<String, dynamic> mapBody = {
        "phoneNumber": userTextEditingController.countryCodeAndPhone.trim(),
        "role": "RIDER",
      };

      NetworkResponse response = await NetworkCall.postRequest(
        url: NetworkPath.login, // <-- ensure this is the correct endpoint
        body: mapBody,
      );

      if (response.isSuccess) {
        print("---------------------$mapBody");
        var riderModel = RiderModel.fromJson(response.responseData!["data"]);
        print("---------------hhh------$riderModel");

        _errorMessage = null;
        isSuccess = true;
        update();
      } else {
        _errorMessage = response.errorMessage;
      }
    } catch (e) {
      print(e);
    }
    return isSuccess;
  }
}
