import 'generated/protocol.dart';

AuthenticationException authFailure({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
}) =>
    AuthenticationException(
      code: code,
      message: message,
      operation: operation,
      details: details,
    );

/// [AnonAccountException] has no `operation` field, so the operation is
/// carried in `details` rather than dropped.
AnonAccountException accountFailure({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
}) =>
    AnonAccountException(
      code: code,
      message: message,
      details: {'operation': operation, ...details},
    );