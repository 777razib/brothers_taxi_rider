import 'package:get/get.dart';
import '../../../../../../core/network_caller/network_config.dart';
import '../../../../core/network_caller/endpoints.dart';

class CreateNewCardApiController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Creates a new payment card by sending a request to the API.
  Future<bool> createNewCardApiMethod(String paymentMethod, bool isDefault) async {
    if (paymentMethod.isEmpty) {
      errorMessage.value = 'Payment method cannot be empty.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final Map<String, dynamic> requestBody = {
        'payment_method': paymentMethod,
        'isDefault': isDefault,
      };

      final NetworkResponse response = await NetworkCall.postRequest(
        url: Urls.paymentsCreateCard,
        body: requestBody,
      );

      if (response.isSuccess) {
        return true;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to create card.';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears the error message.
  void clearError() {
    errorMessage.value = '';
  }
}
