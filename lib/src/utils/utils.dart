import 'dart:convert' show base64Encode, utf8, base64Decode, jsonDecode;
import 'package:crypto/crypto.dart' show Hmac, sha256;
import 'package:esewa_wallet/src/models/esewa_response.dart' show EsewaResponse;

/// Utility class for generating HMAC-SHA256 signatures and decoding eSewa success responses.
class SignatureGenerator {
  /// Generates an HMAC-SHA256 signature for the eSewa payment request.
  ///
  /// [totalAmount] is the total transaction amount (e.g., "100").
  /// [transactionUuid] is the unique transaction identifier (e.g., "11-201-13").
  /// [productCode] is the product code (e.g., "EPAYTEST").
  /// [secretKey] is the merchant's secret key for signing the request.
  /// Returns a Base64-encoded signature string.
  static String generateSignature({
    required String totalAmount,
    required String transactionUuid,
    required String productCode,
    required String secretKey,
  }) {
    /// Constructs the message in the required order: total_amount,transaction_uuid,product_code.
    final message =
        'total_amount=$totalAmount,transaction_uuid=$transactionUuid,product_code=$productCode';

    /// Encodes the secret key to bytes for HMAC-SHA256 computation.
    final keyBytes = utf8.encode(secretKey);

    /// Encodes the message to bytes for HMAC-SHA256 computation.
    final messageBytes = utf8.encode(message);

    /// Initializes the HMAC-SHA256 algorithm with the secret key.
    final hmacSha256 = Hmac(sha256, keyBytes);

    /// Computes the HMAC-SHA256 digest of the message.
    final digest = hmacSha256.convert(messageBytes);

    /// Encodes the digest to Base64 for eSewa API compatibility.
    return base64Encode(digest.bytes);
  }

  /// Decodes the Base64-encoded success response from the eSewa success URL.
  ///
  /// [url] is the success URL containing the Base64-encoded response in the 'data' query parameter.
  /// Returns an [EsewaResponse] instance if decoding succeeds, or null if it fails.
  static EsewaResponse? decodeSuccessResponse(String url) {
    /// Attempts to decode the response, handling potential errors gracefully.
    try {
      /// Parses the URL to extract query parameters.
      final uri = Uri.parse(url);

      /// Retrieves the Base64-encoded response from the 'data' query parameter.
      final base64Response = uri.queryParameters['data'] ?? '';

      /// Decodes the Base64 string to bytes.
      final decodedBytes = base64Decode(base64Response);

      /// Converts the bytes to a UTF-8 string.
      final decodedString = utf8.decode(decodedBytes);

      /// Converts the JSON string to an [EsewaResponse] instance.
      return EsewaResponse.fromJson(jsonDecode(decodedString));
    } catch (e) {
      /// Returns null if decoding fails (e.g., invalid Base64 or JSON).
      return null;
    }
  }
}
