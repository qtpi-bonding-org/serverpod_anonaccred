/// Root of the SDK exception tree.
///
/// Sealed so that every consumer's `switch` over exception types gives
/// exhaustive-checking. Adding a new subclass is a minor-version bump
/// and forces compile-time review at every call site.
sealed class AnonaccountException implements Exception {
  const AnonaccountException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class AccountAlreadyRegisteredException extends AnonaccountException {
  const AccountAlreadyRegisteredException(super.message);
}

final class AccountNotFoundException extends AnonaccountException {
  const AccountNotFoundException(super.message);
}

final class InvalidUltimateKeyException extends AnonaccountException {
  const InvalidUltimateKeyException(super.message);
}

final class PairingTokenInvalidException extends AnonaccountException {
  const PairingTokenInvalidException(super.message);
}

final class PairingTokenExpiredException extends AnonaccountException {
  const PairingTokenExpiredException(super.message);
}

final class PairingNotAuthorizedException extends AnonaccountException {
  const PairingNotAuthorizedException(super.message);
}

final class CryptoOperationException extends AnonaccountException {
  const CryptoOperationException(super.message);
}

final class NetworkException extends AnonaccountException {
  const NetworkException(super.message);
}
