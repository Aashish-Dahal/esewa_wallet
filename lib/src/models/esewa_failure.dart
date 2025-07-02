/// Represents a failure in the eSewa payment process, encapsulating error details.
class EsewaFailure {
  /// The error message describing the reason for the payment failure.
  ///
  /// This is a required field that provides details such as 'Payment failed' or
  /// 'Invalid response signature' for debugging and user feedback.
  final String error;

  /// Constructor for creating an [EsewaFailure] instance with a required error message.
  ///
  /// [error] must be provided to indicate the cause of the failure.
  EsewaFailure({required this.error});
}
