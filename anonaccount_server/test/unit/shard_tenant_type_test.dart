import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:test/test.dart';

void main() {
  test('ShardTenantType exposes the shared account/group convention', () {
    expect(ShardTenantType.account, 'account');
    expect(ShardTenantType.group, 'group');
  });
}
