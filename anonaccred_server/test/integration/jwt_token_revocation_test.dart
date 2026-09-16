import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import '../test_helpers/auth_services_test_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

/// Regression coverage for the anonaccred commerce/IAP JWT path's dependency
/// on `AuthServices.instance.tokenManager`, verified against serverpod 4.0.0
/// per docs/2026-08-21-serverpod-4-migration-notes.md's "Task 1 token-manager
/// source check". Exercises the same tokenManager singleton commerce_endpoint
/// .dart's JwtEndpoint base relies on, calling it directly rather than
/// through a mocked AuthenticationOverride session, since the claims here are
/// about token-store behavior a mocked session bypasses entirely.
///
/// The first two tests below were originally written assuming
/// `revokeAllTokens` invalidates an already-issued access token immediately.
/// Running them against real 4.0.0 source disproved that: `JwtTokenManager
/// .revokeAllTokens` (serverpod_auth_core_server-4.0.0/lib/src/common
/// /integrations/adapters/jwt_token_manager.dart) only deletes rows from the
/// refresh-token table; `validateToken` cryptographically verifies the access
/// JWT's signature and expiry and never consults that table. An already-
/// issued, not-yet-expired access token keeps validating after revocation —
/// only a subsequent refresh attempt is blocked. The tests were corrected to
/// assert this, per the plan's "trust the test, don't patch it to match a
/// guess" instruction, rather than being rewritten to force the originally
/// assumed (and now known to be false) outcome.
void main() {
  setUpAll(initializeTestAuthServices);

  withServerpod('JWT token revocation', (sessionBuilder, endpoints) {
    test(
      'revokeAllTokens deletes the refresh token row for that authUserId '
      'but does not invalidate an already-issued, not-yet-expired access '
      'token',
      () async {
        final session = sessionBuilder.build();
        final accountId = (await AuthServices.instance.authUsers.create(
          session,
        )).id;

        final issued = await AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: accountId,
          method: 'anonaccount',
          scopes: {Scope('device:test-device-key')},
        );

        final beforeRevoke = await AuthServices.instance.tokenManager
            .validateToken(session, issued.token);
        expect(beforeRevoke, isNotNull);
        expect(
          await RefreshToken.db.find(
            session,
            where: (t) => t.authUserId.equals(accountId),
          ),
          isNotEmpty,
        );

        await AuthServices.instance.tokenManager.revokeAllTokens(
          session,
          authUserId: accountId,
        );

        expect(
          await RefreshToken.db.find(
            session,
            where: (t) => t.authUserId.equals(accountId),
          ),
          isEmpty,
        );
        final afterRevoke = await AuthServices.instance.tokenManager
            .validateToken(session, issued.token);
        expect(afterRevoke, isNotNull);
      },
    );

    test(
      'revoking one device deletes refresh tokens for every device on the '
      'same account, but their already-issued access tokens keep validating',
      () async {
        final session = sessionBuilder.build();
        final accountId = (await AuthServices.instance.authUsers.create(
          session,
        )).id;

        final deviceAToken = await AuthServices.instance.tokenManager
            .issueToken(
              session,
              authUserId: accountId,
              method: 'anonaccount',
              scopes: {Scope('device:device-a-key')},
            );
        final deviceBToken = await AuthServices.instance.tokenManager
            .issueToken(
              session,
              authUserId: accountId,
              method: 'anonaccount',
              scopes: {Scope('device:device-b-key')},
            );

        await AuthServices.instance.tokenManager.revokeAllTokens(
          session,
          authUserId: accountId,
        );

        expect(
          await RefreshToken.db.find(
            session,
            where: (t) => t.authUserId.equals(accountId),
          ),
          isEmpty,
        );
        expect(
          await AuthServices.instance.tokenManager.validateToken(
            session,
            deviceAToken.token,
          ),
          isNotNull,
        );
        expect(
          await AuthServices.instance.tokenManager.validateToken(
            session,
            deviceBToken.token,
          ),
          isNotNull,
        );
      },
    );

    test(
      'issueToken for a second device on the same account does not throw '
      'SignInWhileAuthenticatedException on a session with no prior '
      'authentication',
      () async {
        final session = sessionBuilder.build();
        final accountId = (await AuthServices.instance.authUsers.create(
          session,
        )).id;

        expect(session.authenticated, isNull);

        await AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: accountId,
          method: 'anonaccount',
          scopes: {Scope('device:device-a-key')},
        );

        await expectLater(
          AuthServices.instance.tokenManager.issueToken(
            session,
            authUserId: accountId,
            method: 'anonaccount',
            scopes: {Scope('device:device-b-key')},
          ),
          completes,
        );
      },
    );
  });
}
