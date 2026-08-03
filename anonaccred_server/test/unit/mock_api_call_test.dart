import 'package:anonaccred_server/src/payments/mock_api_call.dart';
import 'package:test/test.dart';

void main() {
  test('equal parameter maps compare equal', () {
    expect(
      ApiCall('getPurchase', {'packageName': 'com.quanitya.app'}),
      equals(ApiCall('getPurchase', {'packageName': 'com.quanitya.app'})),
    );
  });

  test('different parameter maps do not compare equal', () {
    expect(
      ApiCall('getPurchase', {'packageName': 'com.quanitya.app'}),
      isNot(equals(ApiCall('getPurchase', {'packageName': 'com.other.app'}))),
    );
  });
}
