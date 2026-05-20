import 'package:anonaccount_sdk/src/auth/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('AnonaccountException is sealed and message is preserved', () {
    const e = CryptoOperationException('boom');
    expect(e.message, 'boom');
    expect(e, isA<AnonaccountException>());
    expect(e.toString(), contains('CryptoOperationException'));
    expect(e.toString(), contains('boom'));
  });

  test('every subclass extends AnonaccountException', () {
    const subclasses = <AnonaccountException>[
      AccountAlreadyRegisteredException('x'),
      AccountNotFoundException('x'),
      InvalidUltimateKeyException('x'),
      PairingTokenInvalidException('x'),
      PairingTokenExpiredException('x'),
      PairingNotAuthorizedException('x'),
      CryptoOperationException('x'),
      NetworkException('x'),
    ];
    for (final e in subclasses) {
      expect(e, isA<AnonaccountException>());
      expect(e.message, 'x');
    }
  });

  test('exhaustive switch compiles', () {
    String classify(AnonaccountException e) => switch (e) {
          AccountAlreadyRegisteredException() => 'already',
          AccountNotFoundException() => 'missing',
          InvalidUltimateKeyException() => 'bad-key',
          PairingTokenInvalidException() => 'bad-token',
          PairingTokenExpiredException() => 'expired',
          PairingNotAuthorizedException() => 'forbidden',
          CryptoOperationException() => 'crypto',
          NetworkException() => 'net',
        };
    expect(classify(const NetworkException('x')), 'net');
  });
}
