import 'package:anonaccount_sdk/src/auth/exceptions.dart';
import 'package:anonaccount_sdk/src/util/error_recovery.dart';
import 'package:test/test.dart';

void main() {
  test('withRetry returns the value when operation succeeds first try', () async {
    final result = await CryptoErrorRecovery.withRetry<int>(
      () async => 42,
      operationName: 'noop',
    );
    expect(result, 42);
  });

  test('withRetry retries on transient failure and ultimately succeeds', () async {
    var attempts = 0;
    final result = await CryptoErrorRecovery.withRetry<String>(
      () async {
        attempts++;
        if (attempts < 3) {
          throw const NetworkException('flake');
        }
        return 'ok';
      },
      operationName: 'flaky',
      baseDelay: const Duration(milliseconds: 1),
    );
    expect(result, 'ok');
    expect(attempts, 3);
  });

  test('withRetry rethrows after max attempts', () async {
    var attempts = 0;
    await expectLater(
      CryptoErrorRecovery.withRetry<void>(
        () async {
          attempts++;
          throw const NetworkException('always');
        },
        operationName: 'doomed',
        maxAttempts: 2,
        baseDelay: const Duration(milliseconds: 1),
      ),
      throwsA(isA<NetworkException>()),
    );
    expect(attempts, 2);
  });

  test('withRetry does not retry when shouldRetry returns false', () async {
    var attempts = 0;
    await expectLater(
      CryptoErrorRecovery.withRetry<void>(
        () async {
          attempts++;
          throw const CryptoOperationException('fatal');
        },
        operationName: 'fatal-op',
        baseDelay: const Duration(milliseconds: 1),
        shouldRetry: (_) => false,
      ),
      throwsA(isA<CryptoOperationException>()),
    );
    expect(attempts, 1);
  });
}
