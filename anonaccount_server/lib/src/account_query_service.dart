import 'package:serverpod/serverpod.dart';
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
    int accountId,
  ) async {
    try {
      final account = await AnonAccount.db.findById(session, accountId);
      return AnonAccountHelpers.requireAccount(
        account,
        accountId,
        'getAccountById',
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Get account by public master key lookup.
  static Future<AnonAccount?> getAccountByPublicKey(
    Session session,
    String ultimateSigningPublicKeyHex,
  ) async {
    try {
      AnonAccountHelpers.validatePublicKey(
        ultimateSigningPublicKeyHex,
        'getAccountByPublicKey',
      );
      return await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimateSigningPublicKeyHex
            .equals(ultimateSigningPublicKeyHex),
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AnonAccountExceptionFactory.createException(
        code: AnonAccountErrorCodes.internalError,
        message: 'Unexpected error during account lookup: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

}
