class PaymentMethodResponse {
  final List<PaymentType> paymentTypes;

  PaymentMethodResponse({required this.paymentTypes});

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponse(
      paymentTypes: (json['payment_types'] as List)
          .map((e) => PaymentType.fromJson(e))
          .toList(),
    );
  }
}

class PaymentType {
  final int id;
  final String type;
  final String? cardNumber;
  final String? name;
  final String? bankName;
  final String? gatewayToken;
  final String? gatewayUrl;

  PaymentType({
    required this.id,
    required this.type,
    this.cardNumber,
    this.name,
    this.bankName,
    this.gatewayToken,
    this.gatewayUrl,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as int,
      type: json['type'] as String,
      cardNumber: json['card_number'] as String?,
      name: json['name'] as String?,
      bankName: json['bank_name'] as String?,
      gatewayToken: json['gateway_token'] as String?,
      gatewayUrl: json['gateway_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'card_number': cardNumber,
      'name': name,
      'bank_name': bankName,
      'gateway_token': gatewayToken,
      'gateway_url': gatewayUrl,
    };
  }
}
