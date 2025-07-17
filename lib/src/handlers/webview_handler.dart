import 'package:esewa_wallet/src/models/esewa_failure.dart';
import 'package:esewa_wallet/src/models/esewa_response.dart';
import 'package:esewa_wallet/src/utils/utils.dart';
import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        MaterialPageRoute,
        Navigator,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        Widget,
        CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show
        InAppWebView,
        InAppWebViewController,
        InAppWebViewInitialData,
        NavigationActionPolicy,
        InAppWebViewSettings;

/// Defines an abstract interface for handling WebView-based payment form loading.
abstract class WebViewHandler {
  /// Loads the eSewa payment form in a WebView and handles success/failure callbacks.
  ///
  /// [context] is the BuildContext for navigation.
  /// [paymentData] contains the payment details (e.g., amount, signature) as a key-value map.
  /// [actionUrl] is the eSewa API endpoint (live or dev) for form submission.
  /// [onSuccess] is called with [EsewaResponse] when the payment succeeds.
  /// [onFailure] is called with [EsewaFailure] when the payment fails or response is invalid.
  void loadPaymentForm(
    BuildContext context,
    Map<String, String> paymentData,
    String actionUrl, {
    required Function(EsewaResponse) onSuccess,
    required Function(EsewaFailure) onFailure,
  });
}

/// Concrete implementation of [WebViewHandler] using flutter_inappwebview.
class InAppWebViewHandler implements WebViewHandler {
  /// Implements the [loadPaymentForm] method to display the eSewa payment form.
  ///
  /// Navigates to a [_WebViewPage] with the provided [paymentData] and [actionUrl].
  /// Triggers [onSuccess] or [onFailure] based on the payment outcome.
  @override
  void loadPaymentForm(
    BuildContext context,
    Map<String, String> paymentData,
    String actionUrl, {
    required Function(EsewaResponse) onSuccess,
    required Function(EsewaFailure) onFailure,
  }) {
    /// Pushes a new route to display the WebView page for payment processing.
    Navigator.push(
      context,
      MaterialPageRoute(
        /// Creates a [_WebViewPage] with the payment data and callbacks.
        builder: (context) => _WebViewPage(
          paymentData: paymentData,
          actionUrl: actionUrl,
          onSuccess: onSuccess,
          onFailure: onFailure,
        ),
      ),
    );
  }
}

/// A StatefulWidget that displays the eSewa payment form in a WebView.

class _WebViewPage extends StatefulWidget {
  /// Payment details (e.g., amount, signature) for the form submission.
  final Map<String, String> paymentData;

  /// The eSewa API endpoint (live or dev) for form submission.
  final String actionUrl;

  /// Callback triggered on successful payment with the decoded response.
  final Function(EsewaResponse) onSuccess;

  /// Callback triggered on payment failure or invalid response.
  final Function(EsewaFailure) onFailure;

  /// Constructor for [_WebViewPage] with required payment data and callbacks.
  const _WebViewPage({
    required this.paymentData,
    required this.actionUrl,
    required this.onSuccess,
    required this.onFailure,
  });

  /// Creates the state for this widget.
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

/// The state class for [_WebViewPage], managing the WebView's lifecycle.
class _WebViewPageState extends State<_WebViewPage> {
  /// Controller for interacting with the InAppWebView instance.
  late final InAppWebViewController webViewController;
  bool _isPageLoading = true;

  /// Builds the WebView UI with an AppBar and payment form.
  @override
  Widget build(BuildContext context) {
    /// Returns a Scaffold with an AppBar and InAppWebView for payment processing.
    return Scaffold(
      /// Displays a title in the AppBar for the payment page.
      appBar: AppBar(title: const Text('Pay Via Esewa')),

      /// Renders the WebView to load the eSewa payment form.
      body: Stack(
        children: [
          InAppWebView(
            /// Sets initial HTML data to auto-submit the payment form.
            initialData: InAppWebViewInitialData(
              data: _generateFormHtml(widget.paymentData, widget.actionUrl),
            ),

            /// Configures WebView settings to enable JavaScript and URL overrides.
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
            ),

            onLoadStart: (controller, url) {
              setState(() {
                _isPageLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isPageLoading = false;
              });
            },

            /// Assigns the WebView controller when the WebView is created.
            onWebViewCreated: (controller) {
              webViewController = controller;

              setState(() {
                _isPageLoading = false;
              });
            },

            /// Handles URL navigation to detect success or failure redirects.
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              /// Extracts the URL from the navigation action.
              final url = navigationAction.request.url.toString();

              /// Checks if the URL indicates a successful payment.
              if (url.contains('success')) {
                /// Closes the WebView page.
                Navigator.pop(context);

                /// Decodes the Base64-encoded response from the success URL.
                final responseData = SignatureGenerator.decodeSuccessResponse(
                  url,
                );

                /// Logs the response data for debugging in production.
                debugPrint('Response Data: ${responseData?.toJson()}');

                /// Verifies the response status and signature.
                if (responseData != null && responseData.status == "COMPLETE") {
                  /// Triggers the success callback with the decoded response.
                  widget.onSuccess(responseData);
                } else {
                  /// Triggers the failure callback for invalid responses.
                  widget.onFailure(
                    EsewaFailure(error: 'Invalid response signature'),
                  );
                }

                /// Cancels further navigation after handling success.
                return NavigationActionPolicy.CANCEL;
              } else if (url.contains('failure')) {
                /// Closes the WebView page on failure.
                Navigator.pop(context);

                /// Triggers the failure callback with a generic error message.
                widget.onFailure(EsewaFailure(error: 'Payment failed'));

                /// Cancels further navigation after handling failure.
                return NavigationActionPolicy.CANCEL;
              }

              /// Allows other URLs (e.g., login page) to load normally.
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_isPageLoading) Center(child: const CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Generates HTML for the payment form with auto-submission.
  ///
  /// [paymentData] contains the form fields (e.g., amount, signature).
  /// [actionUrl] is the eSewa API endpoint for submission.
  /// Returns an HTML string with a form that auto-submits to the eSewa endpoint.

  String _generateFormHtml(Map<String, String> paymentData, String actionUrl) {
    /// Converts payment data into HTML input fields.
    final inputs = paymentData.entries
        .map(
          (entry) =>
              '<input type="hidden" name="${entry.key}" value="${entry.value}">',
        )
        .join();

    /// Returns HTML with a form that auto-submits to the eSewa endpoint.
    return '''
      <!DOCTYPE html>
      <html>
      <body>
        <form id="paymentForm" action="$actionUrl" method="POST">
          $inputs
        </form>
        <script>
          document.getElementById('paymentForm').submit();
        </script>
      </body>
      </html>
    ''';
  }
}
