import 'package:get/get.dart';

import '../../../../../../core/network_caller/endpoints.dart';
import '../../../../../../core/network_caller/network_config.dart';
import '../../../../../../core/services_class/shared_preferences_data_helper.dart'
    show AuthController;
import '../../choose_taxi/model/payment_method_model.dart';

class GetSavedCardApiController extends GetxController {
  final RxBool _isLoading = false.obs;

  RxBool get isLoading => _isLoading;

  final RxString _errorMessage = ''.obs;

  RxString get errorMessage => _errorMessage;

  final RxList<PaymentMethod> _savedCards = <PaymentMethod>[].obs;

  RxList<PaymentMethod> get savedCards => _savedCards;

  /// Fetches saved payment cards from the API.
  /// Returns true if the fetch was successful, false otherwise.
  Future<bool> getSavedCardApiMethod() async {
    _isLoading.value = true;
    _errorMessage.value = ''; // Clear previous errors
    _savedCards.clear(); // Clear previous cards

    try {
      // Check for authentication token
      final token = AuthController
          .accessToken; // Replace with await AuthController.getAccessToken() if needed
      if (token == null || token.isEmpty) {
        _errorMessage.value = 'Authentication token is missing.';
        _isLoading.value = false;
        return false;
      }

      final NetworkResponse response = await NetworkCall.getRequest(
        url: Urls.paymentsSavedCards,
      );

      print(
        'GetSavedCardApiMethod Response: isSuccess=${response.isSuccess}, responseData=${response.responseData}, errorMessage=${response.errorMessage}',
      ); // Debug log (remove in production)

      if (response.isSuccess) {
        // Parse responseData as Map and extract the 'data' key
        final Map<String, dynamic> responseData =
            response.responseData as Map<String, dynamic>? ?? {};
        final List<dynamic> data = responseData['data'] as List<dynamic>? ?? [];

        if (data.isEmpty) {
          _errorMessage.value = 'No saved cards found.';
          _isLoading.value = false;
          return false;
        }

        _savedCards.value = data
            .map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>))
            .toList();
        print(
          'Parsed ${_savedCards.length} saved cards',
        ); // Debug log (remove in production)
        return true;
      } else {
        _errorMessage.value =
            response.errorMessage ?? 'Failed to fetch saved cards.';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred: $e';
      print(
        'GetSavedCardApiMethod Exception: $e',
      ); // Debug log (remove in production)
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clears the error message.
  void clearError() {
    _errorMessage.value = '';
  }
}
