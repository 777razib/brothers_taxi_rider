/*


import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:naderhosn/core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/network_caller/endpoints.dart';
import '../../../../core/network_path/natwork_path.dart';

class StripeService extends GetxController {
StripeService._();
static final StripeService instance = StripeService._();

/// Initiates a payment with Stripe for the given amount, card, and transport ID.
Future<bool> makePayment(double amount, String cardId, String transportId) async {
try {
Stripe.publishableKey = APIKeys.stripePublishable_keys;
await Stripe.instance.applySettings();

String? clientSecret = await _createPaymentIntent(amount, 'usd');
if (clientSecret == null) {
EasyLoading.showError('Failed to create payment intent.');
return false;
}

await Stripe.instance.initPaymentSheet(
paymentSheetParameters: SetupPaymentSheetParameters(
paymentIntentClientSecret: clientSecret,
merchantDisplayName: 'Brothers Taxi',
style: ThemeMode.light,
allowsDelayedPaymentMethods: true,
),
);

return await _processPayment(transportId, cardId, 'CARD');
} catch (e) {
print('Error in makePayment: $e');
EasyLoading.showError('Failed to initialize payment: $e');
return false;
}
}

/// Creates a payment intent using Stripe API and returns the client secret.
Future<String?> _createPaymentIntent(double amount, String currency) async {
try {
final Dio dio = Dio();
Map<String, dynamic> body = {
'amount': _calculateAmount(amount),
'currency': currency,
};

String urlEncodedBody = body.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
    .join('&');

var response = await dio.post(
APIKeys.stripeAPILink,
data: urlEncodedBody,
options: Options(
headers: {
'Authorization': 'Bearer ${APIKeys.stripeSecret_keys}',
'Content-Type': 'application/x-www-form-urlencoded',
},
),
);

print('CreatePaymentIntent - Status Code: ${response.statusCode}');
print('CreatePaymentIntent - Status Message: ${response.statusMessage}');
print('CreatePaymentIntent - Response Data: ${response.data}');

if (response.statusCode == 200 && response.data != null) {
final Map<String, dynamic> data = response.data as Map<String, dynamic>? ?? {};
return data['client_secret'] as String?;
} else {
print('Unexpected status code: ${response.statusCode}');
EasyLoading.showError('Invalid response from payment intent creation.');
return null;
}
} on DioException catch (e) {
print('DioException in _createPaymentIntent: ${e.response?.data}');
print('Full Dio error: $e');
EasyLoading.showError('Failed to create payment intent: ${e.response?.statusCode}');
return null;
} catch (e) {
print('Unexpected error in _createPaymentIntent: $e');
EasyLoading.showError('Unexpected error during payment intent creation.');
return null;
}
}

/// Processes the payment by presenting the payment sheet and posting data to backend.
Future<bool> _processPayment(String transportId, String cardId, String paymentMethod) async {
try {
// Present the payment sheet.
await Stripe.instance.presentPaymentSheet();

// Payment succeeded - post data to backend.
await _postPaymentData(transportId, cardId, paymentMethod);

EasyLoading.showSuccess('Payment successful!');
print('Payment successful for transportId: $transportId, cardId: $cardId');
return true;
} catch (e) {
EasyLoading.showError('Payment failed or cancelled: $e');
print('Error during payment process: $e');
return false;
}
}

/// Converts amount to cents for Stripe API.
String _calculateAmount(double amount) {
final calculatedAmount = (amount * 100).toInt();
return calculatedAmount.toString();
}

/// Posts payment confirmation to your backend.
Future<void> _postPaymentData(String transportId, String cardId, String paymentMethod) async {
try {
final token = await AuthController.accessToken;

if (token == null || token.isEmpty) {
EasyLoading.showError('Authentication token not found.');
return;
}

Map<String, dynamic> requestBody = {
'transportId': transportId,
'paymentMethod': paymentMethod,
'cardId': cardId,
};

final response = await http.post(
Uri.parse(Urls.paymentsCardPayment),
headers: {
'Authorization': 'Bearer $token',
'Content-Type': 'application/json',
},
body: jsonEncode(requestBody),
);

print('PostPaymentData - Status Code: ${response.statusCode}');
print('PostPaymentData - Response Body: ${response.body}');

if (response.statusCode == 200) {
EasyLoading.showSuccess('Payment confirmed!');
} else {
print('Failed to post payment data: ${response.statusCode} - ${response.body}');
EasyLoading.showError('Payment confirmation failed: ${response.statusCode}');
}
} catch (e) {
print('Error posting payment data: $e');
EasyLoading.showError('Error confirming payment: $e');
}
}
}*/
