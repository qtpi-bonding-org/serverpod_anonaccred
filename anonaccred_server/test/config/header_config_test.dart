import 'package:test/test.dart';
import '../../lib/src/config/header_config.dart';

void main() {
  group('AnonAccredHeaderConfig', () {
    test('should use default prefix when environment variable not set', () {
      expect(AnonAccredHeaderConfig.headerPrefix, equals('QUANITYA'));
    });

    test('should generate correct device public key header name', () {
      expect(AnonAccredHeaderConfig.devicePubKeyHeader, equals('X-QUANITYA-DEVICE-PUBKEY'));
      expect(AnonAccredHeaderConfig.devicePubKeyHeaderLower, equals('x-quanitya-device-pubkey'));
    });

    test('should generate correct payment header name', () {
      expect(AnonAccredHeaderConfig.paymentHeader, equals('X-PAYMENT'));
    });

    test('should provide header variations for case-insensitive matching', () {
      final variations = AnonAccredHeaderConfig.devicePubKeyHeaderVariations;
      
      expect(variations, contains('X-QUANITYA-DEVICE-PUBKEY'));
      expect(variations, contains('x-quanitya-device-pubkey'));
      expect(variations, contains('x-QUANITYA-device-pubkey'));
      expect(variations, contains('X-quanitya-DEVICE-PUBKEY'));
      expect(variations, contains('x-quanitya-device-pubkey'));
    });

    test('should provide payment header variations', () {
      final variations = AnonAccredHeaderConfig.paymentHeaderVariations;
      
      expect(variations, contains('X-PAYMENT'));
      expect(variations, contains('x-payment'));
      expect(variations, contains('X-Payment'));
    });

    test('should extract header value from variations', () {
      final headers = {
        'x-quanitya-device-pubkey': ['test_pubkey_value'],
        'X-PAYMENT': ['test_payment_value'],
      };

      final devicePubKey = AnonAccredHeaderConfig.getHeaderValue(
        headers,
        AnonAccredHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(devicePubKey, equals('test_pubkey_value'));

      final payment = AnonAccredHeaderConfig.getHeaderValue(
        headers,
        AnonAccredHeaderConfig.paymentHeaderVariations,
      );
      expect(payment, equals('test_payment_value'));
    });

    test('should return null when header not found', () {
      final headers = <String, List<String>>{};

      final devicePubKey = AnonAccredHeaderConfig.getHeaderValue(
        headers,
        AnonAccredHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(devicePubKey, isNull);
    });

    test('should detect header presence', () {
      final headers = {
        'x-quanitya-device-pubkey': ['test_value'],
      };

      final hasHeader = AnonAccredHeaderConfig.hasHeader(
        headers,
        AnonAccredHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(hasHeader, isTrue);

      final noHeader = AnonAccredHeaderConfig.hasHeader(
        <String, List<String>>{},
        AnonAccredHeaderConfig.devicePubKeyHeaderVariations,
      );
      expect(noHeader, isFalse);
    });

    test('should validate configuration successfully with valid prefix', () {
      // This should not throw
      expect(() => AnonAccredHeaderConfig.validateConfiguration(), returnsNormally);
    });

    test('should log configuration details', () {
      // This test verifies the configuration can be accessed without errors
      expect(AnonAccredHeaderConfig.headerPrefix, isNotEmpty);
      expect(AnonAccredHeaderConfig.devicePubKeyHeader, isNotEmpty);
      expect(AnonAccredHeaderConfig.paymentHeader, isNotEmpty);
    });
  });
}