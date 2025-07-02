import 'package:esewa_wallet/esewa_wallet.dart'
    show
        ESewaConfig,
        InAppWebViewHandler,
        PaymentConfig,
        PaymentData,
        WebViewHandler;
import 'package:esewa_wallet/src/models/esewa_failure.dart';
import 'package:esewa_wallet/src/models/esewa_response.dart';
import 'package:esewa_wallet/src/utils/constant.dart' show ESewaEnvironment;
import 'package:flutter/material.dart' show BuildContext;

/// The main class for initiating eSewa payments, implemented as a singleton.
class ESewaPayment {
  /// The singleton instance of [ESewaPayment], ensuring a single configuration per session.
  static ESewaPayment? _instance;

  /// The payment configuration, providing payment data and API endpoint.
  final PaymentConfig config;

  /// The WebView handler for rendering the eSewa payment form.
  final WebViewHandler _webViewHandler;

  /// Private constructor for internal use, initializing the configuration and WebView handler.
  ///
  /// [config] is required to provide payment details and environment settings.
  /// Initializes [_webViewHandler] with a default [InAppWebViewHandler].
  ESewaPayment._({required this.config})
    : _webViewHandler = InAppWebViewHandler();

  /// Factory constructor for creating a singleton instance for the live environment.
  ///
  /// [paymentData] contains the payment details (e.g., amount, transactionUuid).
  /// Returns the singleton instance, configured for the live eSewa API.
  factory ESewaPayment.live({required PaymentData paymentData}) {
    _instance = ESewaPayment._(
      config: ESewaConfig(
        paymentData: paymentData,
        environment: ESewaEnvironment.live,
      ),
    );
    return _instance!;
  }

  /// Factory constructor for creating a singleton instance for the dev (UAT) environment.
  ///
  /// [paymentData] contains the payment details (e.g., amount, transactionUuid).
  /// Returns the singleton instance, configured for the dev eSewa API.
  factory ESewaPayment.dev({required PaymentData paymentData}) {
    _instance = ESewaPayment._(
      config: ESewaConfig(
        paymentData: paymentData,
        environment: ESewaEnvironment.dev,
      ),
    );
    return _instance!;
  }

  /// Initiates the eSewa payment process by loading the payment form in a WebView.
  ///
  /// [context] is the BuildContext for navigation.
  /// [onSuccess] is called with [EsewaResponse] when the payment succeeds.
  /// [onFailure] is called with [EsewaFailure] when the payment fails or response is invalid.
  void initiatePayment(
    BuildContext context, {
    required Function(EsewaResponse) onSuccess,
    required Function(EsewaFailure) onFailure,
  }) {
    /// Retrieves payment data from the configuration for form submission.
    final paymentData = config.getPaymentData();

    /// Retrieves the eSewa API endpoint (live or dev) for form submission.
    final actionUrl = config.getFormActionUrl();

    /// Loads the payment form in a WebView using the configured handler.
    _webViewHandler.loadPaymentForm(
      context,
      paymentData,
      actionUrl,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
}
