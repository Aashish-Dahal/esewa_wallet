import 'package:esewa_wallet/src/models/payment_data.dart' show PaymentData;
import 'package:esewa_wallet/src/utils/constant.dart'
    show ESewaEnvironment, esewaDevUrl, esewaLiveUrl;

/// Defines an abstract interface for payment configuration, ensuring a consistent contract
///
/// for different payment methods to implement their specific configurations.

abstract class PaymentConfig {
  /// Method to retrieve payment data as a key-value map for form submission

  Map<String, String> getPaymentData();

  /// Method to retrieve the URL for submitting the payment form

  String getFormActionUrl();
}

/// Concrete implementation of PaymentConfig for eSewa-specific payment configuration

class ESewaConfig implements PaymentConfig {
  /// Stores the payment data (e.g., amount, transactionUuid) for the transaction

  final PaymentData paymentData;

  /// Specifies the environment (live or dev) for the payment API endpoint

  final ESewaEnvironment environment;

  /// Constructor for initializing the configuration with required payment data

  ESewaConfig({
    /// Requires PaymentData to ensure all necessary payment details are provided
    required this.paymentData,

    /// Defaults to dev environment for safety in non-production settings
    this.environment = ESewaEnvironment.dev,
  });

  /// Implements getPaymentData to return payment details from PaymentData

  @override
  Map<String, String> getPaymentData() => paymentData.toMap();

  /// Implements getFormActionUrl to return the appropriate API endpoint based on environment

  @override
  String getFormActionUrl() {
    /// Switches on the environment to select the correct API endpoint
    switch (environment) {
      /// Returns the live API endpoint for production transactions
      case ESewaEnvironment.live:
        return esewaLiveUrl;

      /// Returns the dev (UAT) API endpoint for testing transactions
      case ESewaEnvironment.dev:
        return esewaDevUrl;
    }
  }
}
