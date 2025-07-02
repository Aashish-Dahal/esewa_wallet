/// Represents the decoded response from a successful eSewa payment.
class EsewaResponse {
  /// The unique transaction code assigned by eSewa (e.g., "000AWEO").
  final String transactionCode;

  /// The status of the payment (e.g., "COMPLETE").
  final String status;

  /// The total amount of the transaction, as a string (e.g., "1000.0").
  final String totalAmount;

  /// The unique identifier for the transaction, matching the request UUID.
  final String transactionUuid;

  /// The product code used for the transaction (e.g., "EPAYTEST").
  final String productCode;

  /// The comma-separated list of fields used for signature verification
  /// (e.g., "transaction_code,status,total_amount,transaction_uuid,product_code,signed_field_names").
  final String signedFieldNames;

  /// The HMAC-SHA256 signature for verifying the response integrity.
  final String signature;

  /// Constructor for creating an [EsewaResponse] with required response fields.
  ///
  /// All fields are required to ensure the response contains complete data for
  /// validation and processing.
  EsewaResponse({
    required this.transactionCode,
    required this.status,
    required this.totalAmount,
    required this.transactionUuid,
    required this.productCode,
    required this.signedFieldNames,
    required this.signature,
  });

  /// Factory constructor to create an [EsewaResponse] from a JSON map.
  ///
  /// Converts the Base64-decoded JSON response from the eSewa success URL into
  /// an [EsewaResponse] instance. Assumes all fields are strings as provided by
  /// the eSewa API.
  factory EsewaResponse.fromJson(Map<String, dynamic> json) {
    return EsewaResponse(
      transactionCode: json['transaction_code'] as String,
      status: json['status'] as String,
      totalAmount: json['total_amount'] as String,
      transactionUuid: json['transaction_uuid'] as String,
      productCode: json['product_code'] as String,
      signedFieldNames: json['signed_field_names'] as String,
      signature: json['signature'] as String,
    );
  }

  /// Converts the [EsewaResponse] instance to a JSON map.
  ///
  /// Returns a map representation of the response, useful for signature
  /// verification or logging in production.
  Map<String, dynamic> toJson() {
    return {
      'transaction_code': transactionCode,
      'status': status,
      'total_amount': totalAmount,
      'transaction_uuid': transactionUuid,
      'product_code': productCode,
      'signed_field_names': signedFieldNames,
      'signature': signature,
    };
  }
}
