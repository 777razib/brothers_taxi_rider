class PaymentMethod {
  final String? id;
  final String? payment_method; // Maps to API's cardType
  final bool? isDefault;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final String? stripePaymentMethodId;

  PaymentMethod({
    this.id,
    this.payment_method,
    this.isDefault,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.stripePaymentMethodId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String?,
      payment_method: json['cardType'] as String?,
      // Map cardType to payment_method
      isDefault: json['isDefault'] as bool?,
      last4: json['last4'] as String?,
      expiryMonth: json['expiryMonth'] as int?,
      expiryYear: json['expiryYear'] as int?,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardType': payment_method, // Map back to cardType for API
      'isDefault': isDefault,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'stripePaymentMethodId': stripePaymentMethodId,
    };
  }
}
