import 'package:serverpod/serverpod.dart';
import 'protocol_failures.dart';
import 'try_operation.dart';
import 'exception_factory.dart';
import 'generated/protocol.dart';
import 'helpers.dart';

/// Server-side account query operations.
///
/// These are service methods, not endpoints — consuming projects decide
/// how (or whether) to expose them to clients.
class AccountQueryService {
  /// Get account by ID, requiring it to exist.
  ///
  /// Throws [AuthenticationException] if not found.
  static Future<AnonAccount> getAccountById(
    Session session,
    UuidValue accountId,
  ) async {
    return tryOperation(
      session,
      'getAccountById',
      () async {
        final account = await AnonAccount.db.findById(session, accountId);
        return AnonAccountHelpers.requireAccount(
          account,
          accountId.toString(),
          'getAccountById',
        );
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
    );
  }

  /// Get account by public master key lookup.
  static Future<AnonAccount?> getAccountByPublicKey(
    Session session,
    String ultimateSigningPublicKeyHex,
  ) async {
    return tryOperation(
      session,
      'getAccountByPublicKey',
      () async {
        AnonAccountHelpers.validatePublicKey(
          ultimateSigningPublicKeyHex,
          'getAccountByPublicKey',
        );
        return await AnonAccount.db.findFirstRow(
          session,
          where: (t) =>
              t.ultimateSigningPublicKeyHex.equals(ultimateSigningPublicKeyHex),
        );
      },
      onFailure: accountFailure,
      code: AnonAccountErrorCodes.internalError,
    );
  }
}
