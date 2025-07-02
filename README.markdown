# eSewa Payment

A Flutter package for integrating eSewa payments using `flutter_inappwebview`.

## Features

- Seamless integration of eSewa payments for live and dev (UAT) environments.
- Automatic HMAC-SHA256 signature generation for secure transactions.
- Simplified API with hidden `signed_field_names` and `signature` fields.
- Decodes and processes Base64-encoded success responses.
- Structured success (`EsewaResponse`) and failure (`EsewaFailure`) callbacks.
- Adheres to SOLID principles for maintainability and extensibility.
- Supports eSewa login with verification token (test token: `123456`).

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  esewa_wallet: ^1.0.0
```

Run:

```bash
flutter pub get
```

## Usage

1. **Import the package**:

```dart
import 'package:esewa_wallet/esewa_wallet.dart';
```

2. **Create a `PaymentData` instance** with your payment details and secret key:

```dart
final paymentData = PaymentData(
  amount: '100',
  taxAmount: '10',
  totalAmount: '100',
  transactionUuid: '11-201-13',
  productCode: 'EPAYTEST',
  productServiceCharge: '0',
  productDeliveryCharge: '0',
  successUrl: 'https://developer.esewa.com.np/success',
  failureUrl: 'https://developer.esewa.com.np/failure',
  secretKey: '8gBm/:&EnhH.1/q', // UAT secret key
);
```

3. **Initiate payment** using the `ESewaPayment` singleton for either live or dev environment:

```dart
// For development (UAT) environment
final paymentService = ESewaPayment.dev(paymentData: paymentData);
paymentService.initiatePayment(
  context,
  onSuccess: (response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response.transactionCode} (${response.status})'),
      ),
    );
  },
  onFailure: (failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${failure.error}')),
    );
  },
);

// For live environment
final paymentDataLive = PaymentData(
  amount: '100',
  taxAmount: '10',
  totalAmount: '100',
  transactionUuid: '11-201-13',
  productCode: 'EPAYTEST',
  productServiceCharge: '0',
  productDeliveryCharge: '0',
  successUrl: 'https://your-live-success-url.com',
  failureUrl: 'https://your-live-failure-url.com',
  secretKey: 'your-live-secret-key', // Replace with live secret key
);
final paymentServiceLive = ESewaPayment.live(paymentData: paymentDataLive);
paymentServiceLive.initiatePayment(
  context,
  onSuccess: (response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response.transactionCode} (${response.status})'),
      ),
    );
  },
  onFailure: (failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${failure.error}')),
    );
  },
);
```

## Payment Flow

1. The `ESewaPayment` singleton submits payment data to the eSewa API via a WebView.
2. Users are redirected to the eSewa login page to enter their eSewa ID and MPIN.
3. A 6-digit verification token is sent to the user's mobile (SMS) or email. For testing in the UAT environment, use the token `123456`.
4. On successful payment, the user is redirected to the `successUrl` with a Base64-encoded response (in the `data` query parameter), which is decoded into an `EsewaResponse`.
5. On failure, the user is redirected to the `failureUrl`, and an `EsewaFailure` is returned with an error message.

## Testing in UAT Environment

Use the following credentials for testing in the dev (UAT) environment:

- **eSewa ID**: 9806800001, 9806800002, 9806800003, 9806800004, or 9806800005
- **MPIN**: 1122
- **Token**: 123456

These credentials allow you to test the payment flow without needing to receive a real token via SMS or email.

## Signature Generation

The package automatically generates a Base64-encoded HMAC-SHA256 signature using the fields `total_amount,transaction_uuid,product_code` in that order. Example:

- **Input**: `total_amount=100,transaction_uuid=11-201-13,product_code=EPAYTEST`
- **Secret Key**: `8gBm/:&EnhH.1/q`
- **Output**: `4Ov7pCI1zIOdwtV2BRMUNjz1upIlT/COTxfLhWvVurE=`

## Success Response

On successful payment, the response is Base64-encoded in the `successUrl` (e.g., `https://developer.esewa.com.np/success?data=<base64>`). The decoded response is converted to an `EsewaResponse` with fields like:

- `transaction_code` (e.g., "000AWEO")
- `status` (e.g., "COMPLETE")
- `total_amount` (e.g., "1000.0")
- `transaction_uuid` (e.g., "250610-162413")
- `product_code` (e.g., "EPAYTEST")
- `signed_field_names` (e.g., "transaction_code,status,total_amount,transaction_uuid,product_code,signed_field_names")
- `signature` (e.g., "62GcfZTmVkzhtUeh+QJ1AqiJrjoWWGof3U+eTPTZ7fA=")

The package does not verify the response signature in this version. To enable verification, ensure the `secretKey` is provided to `SignatureGenerator.verifyResponseSignature` (not implemented here).

## Example

See the `example/` directory for a complete sample app demonstrating both live and dev environments.

## Requirements

- Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

- Ensure `flutter_inappwebview` and `crypto` are included in `pubspec.yaml`:

```yaml
dependencies:
  flutter_inappwebview: ^6.0.0
  crypto: ^3.0.3
```

## License

MIT
