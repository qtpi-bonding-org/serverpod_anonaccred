import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

void main() {
  group('AnonAccountHeaderConfig', () {
    test('should use default prefix when environment variable not set', () {
      expect(AnonAccountHeaderConfig.headerPrefix, equals('QUANITYA'));
    });

    test('should generate correct device public key header name', () {
      expect(AnonAccountHeaderConfig.devicePubKeyHeader, equals('X-QUANITYA-DEVICE-PUBKEY'));
      expect(AnonAccountHeaderConfig.devicePubKeyHeaderLower, equals('x-quanitya-device-pubkey'));
    });

    test('should generate correct payment header name', () {
      expect(AnonAccountHeaderConfig.paymentHeader, equals('X-PAYMENT'));
    });

    test('should provide header variations for case-insensitive matching', () {
      final variations = AnonAccountHeaderConfig.devicePubKeyHeaderVariations;

      expect(variations, contains('X-QUANITYA-DEVICE-PUBKEY'));
      expect(variations, contains('x-quanitya-device-pubkey'));
      expect(variations, contains('x-QUANITYA-device-pubkey'));
      expect(variations, contains('X-quanitya-DEVICE-PUBKEY'));
      expect(variations, contains('x-quanitya-device-pubkey'));
    });

    test('should provide payment header variations', () {
      final variations = AnonAccountHeaderConfig.paymentHeaderVariations;

      expect(variations, contains('X-PAYMENT'));
      expect(variations, contains('x-payment'));
      expect(variations, contains('X-Payment'));
    });

    test('should extract header value from variations', () {
      final headers = {
        'x-quanitya-device-pubkey': ['test_pubkey_value'],
        'X-PAYMENT': ['test_payment_value'],
      };

      final devicePubKey = AnonAccountHeaderConfig.getHeaderValue(
        headers,
        AnonAccountHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(devicePubKey, equals('test_pubkey_value'));

      final payment = AnonAccountHeaderConfig.getHeaderValue(
        headers,
        AnonAccountHeaderConfig.paymentHeaderVariations,
      );
      expect(payment, equals('test_payment_value'));
    });

    test('should return null when header not found', () {
      final headers = <String, List<String>>{};

      final devicePubKey = AnonAccountHeaderConfig.getHeaderValue(
        headers,
        AnonAccountHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(devicePubKey, isNull);
    });

    test('should detect header presence', () {
      final headers = {
        'x-quanitya-device-pubkey': ['test_value'],
      };

      final hasHeader = AnonAccountHeaderConfig.hasHeader(
        headers,
        AnonAccountHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(hasHeader, isTrue);

      final noHeader = AnonAccountHeaderConfig.hasHeader(
        <String, List<String>>{},
        AnonAccountHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(noHeader, isFalse);
    });

    test('should validate configuration successfully with valid prefix', () {
      expect(AnonAccountHeaderConfig.validateConfiguration, returnsNormally);
    });

    test('should log configuration details', () {
      expect(AnonAccountHeaderConfig.headerPrefix, isNotEmpty);
      expect(AnonAccountHeaderConfig.devicePubKeyHeader, isNotEmpty);
      expect(AnonAccountHeaderConfig.paymentHeader, isNotEmpty);
    });
  });
}
