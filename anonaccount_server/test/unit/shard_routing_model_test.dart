import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

Future<ShardRouting> _insertRouting(
  TestSessionBuilder sessionBuilder,
  ShardRouting row,
) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_insertRouting',
  );
  try {
    return await ShardRouting.db.insertRow(session, row);
  } finally {
    await session.close();
  }
}

Future<ShardRouting?> _findRouting(
  TestSessionBuilder sessionBuilder, {
  required UuidValue tenantId,
  required String tenantType,
}) async {
  final session = (sessionBuilder as InternalTestSessionBuilder).internalBuild(
    endpoint: 'test',
    method: '_findRouting',
  );
  try {
    return await ShardRouting.db.findFirstRow(
      session,
      where: (t) => t.tenantId.equals(tenantId) & t.tenantType.equals(tenantType),
    );
  } finally {
    await session.close();
  }
}

void main() {
  withServerpod('Given ShardRouting model', (sessionBuilder, endpoints) {
    test('inserts and looks up a row by tenantId + tenantType', () async {
      final tenantId =
          UuidValue.fromString('10000000-0000-4000-8000-000000000001');
      final inserted = await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );
      expect(inserted.id, isNotNull);

      final found = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.account,
      );
      expect(found, isNotNull);
      expect(found!.shardName, 'shard_01');
    });

    test('the same tenantId can hold separate account and group rows', () async {
      final tenantId =
          UuidValue.fromString('20000000-0000-4000-8000-000000000002');
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.group,
          shardName: 'shard_02',
          updatedAt: DateTime.now(),
        ),
      );

      final accountRow = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.account,
      );
      final groupRow = await _findRouting(
        sessionBuilder,
        tenantId: tenantId,
        tenantType: ShardTenantType.group,
      );
      expect(accountRow!.shardName, 'shard_01');
      expect(groupRow!.shardName, 'shard_02');
    });

    test('duplicate (tenantId, tenantType) violates the unique index', () async {
      final tenantId =
          UuidValue.fromString('30000000-0000-4000-8000-000000000003');
      await _insertRouting(
        sessionBuilder,
        ShardRouting(
          tenantId: tenantId,
          tenantType: ShardTenantType.account,
          shardName: 'shard_01',
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => _insertRouting(
          sessionBuilder,
          ShardRouting(
            tenantId: tenantId,
            tenantType: ShardTenantType.account,
            shardName: 'shard_02',
            updatedAt: DateTime.now(),
          ),
        ),
        throwsA(anything),
      );
    });

    test('lookup for a tenant with no row returns null', () async {
      final found = await _findRouting(
        sessionBuilder,
        tenantId:
            UuidValue.fromString('40000000-0000-4000-8000-000000000004'),
        tenantType: ShardTenantType.account,
      );
      expect(found, isNull);
    });
  });
}
