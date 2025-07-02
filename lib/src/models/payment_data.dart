import 'package:esewa_wallet/src/utils/utils.dart' show SignatureGenerator;

/// Encapsulates payment details required for an eSewa transaction.
class PaymentData {
  /// The base amount of the transaction (e.g., "100").
  final String amount;

  /// The tax amount applied to the transaction (e.g., "10").
  final String taxAmount;

  /// The total amount of the transaction, including taxes and charges (e.g., "100").
  final String totalAmount;

  /// The unique identifier for the transaction (e.g., "11-201-13").
  final String transactionUuid;

  /// The product code for the transaction (e.g., "EPAYTEST").
  final String productCode;

  /// The service charge for the product (e.g., "0").
  final String productServiceCharge;

  /// The delivery charge for the product (e.g., "0").
  final String productDeliveryCharge;

  /// The URL to redirect to on successful payment (e.g., "https://developer.esewa.com.np/success").
  final String successUrl;

  /// The URL to redirect to on failed payment (e.g., "https://developer.esewa.com.np/failure").
  final String failureUrl;

  /// The private field specifying the fields used for signature generation
  /// (fixed as "total_amount,transaction_uuid,product_code").
  final String _signedFieldNames;

  /// The private HMAC-SHA256 signature generated for the transaction.
  final String _signature;

  /// Constructor for creating a [PaymentData] instance with required payment details.
  ///
  /// [amount], [taxAmount], [totalAmount], [transactionUuid], [productCode],
  /// [productServiceCharge], [productDeliveryCharge], [successUrl], [failureUrl],
  /// and [secretKey] are required to ensure complete payment data.
  /// The [_signedFieldNames] and [_signature] are computed automatically.
  PaymentData({
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.transactionUuid,
    required this.productCode,
    required this.productServiceCharge,
    required this.productDeliveryCharge,
    required this.successUrl,
    required this.failureUrl,
    required String secretKey,
  }) : _signedFieldNames = 'total_amount,transaction_uuid,product_code',
       _signature = SignatureGenerator.generateSignature(
         totalAmount: totalAmount,
         transactionUuid: transactionUuid,
         productCode: productCode,
         secretKey: secretKey,
       );

  /// Converts the [PaymentData] instance to a key-value map for form submission.
  ///
  /// Returns a map containing all payment fields, including the private

  Map<String, String> toMap() {
    return {
      'amount': amount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'transaction_uuid': transactionUuid,
      'product_code': productCode,
      'product_service_charge': productServiceCharge,
      'product_delivery_charge': productDeliveryCharge,
      'success_url': successUrl,
      'failure_url': failureUrl,
      'signed_field_names': _signedFieldNames,
      'signature': _signature,
    };
  }
}
