import 'package:anonaccred_server/anonaccred_server.dart';
import 'package:anonaccred_server/src/group_entitlement_manager.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('GroupCommerceEndpoint Integration Tests', (
    sessionBuilder,
    endpoints,
  ) {
    const validPublicKey =
        'aa23456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    late AnonAccount testAccount;
    late ShareGroup testGroup;
    late TestSessionBuilder authenticatedSessionBuilder;
    late TestSessionBuilder unauthenticatedSessionBuilder;

    setUp(() async {
      final session = sessionBuilder.build();

      var account = await AnonAccount.db.findFirstRow(
        session,
        where: (t) => t.ultimatePublicKey.equals(validPublicKey),
      );
      account ??= await AnonAccount.db.insertRow(
        session,
        AnonAccount(
          id: UuidValue.fromString('b0000000-0000-4000-8000-000000000001'),
          ultimateSigningPublicKeyHex: validPublicKey,
          encryptedDataKey: 'encrypted_for_group_commerce_test',
          ultimatePublicKey: validPublicKey,
        ),
      );
      testAccount = account;

      var device = await AccountDevice.db.findFirstRow(
        session,
        where: (t) => t.deviceSigningPublicKeyHex.equals(validPublicKey),
      );
      device ??= await AccountDevice.db.insertRow(
        session,
        AccountDevice(
          anonAccountId: testAccount.id!,
          deviceSigningPublicKeyHex: validPublicKey,
          encryptedDataKey: 'device_key_for_group_commerce_test',
          label: 'Test Device',
        ),
      );

      // Insert a group and a membership row.
      testGroup = await ShareGroup.db.insertRow(
        session,
        ShareGroup(
          ultimateSigningPublicKeyHex: validPublicKey,
          ultimatePublicKey: validPublicKey,
          encryptedDataKey: 'group_master_wrapped',
        ),
      );
      await GroupMember.db.insertRow(
        session,
        GroupMember(
          shareGroupId: testGroup.id!,
          anonAccountId: testAccount.id!,
          role: GroupMemberRole.admin,
          memberSigningPublicKeyHex: validPublicKey,
          memberPublicKey: validPublicKey,
          encryptedDataKey: 'wrapped_for_member',
        ),
      );

      authenticatedSessionBuilder = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          testAccount.id.toString(),
          {Scope('device:$validPublicKey')},
          authId: validPublicKey,
        ),
      );
      unauthenticatedSessionBuilder = sessionBuilder;

      // Clean any prior group entitlement state for this group.
      await GroupEntitlement.db.deleteWhere(
        session,
        where: (t) => t.shareGroupUuid.equals(testGroup.id!),
      );
      await GroupConsumptionLog.db.deleteWhere(
        session,
        where: (t) => t.shareGroupUuid.equals(testGroup.id!),
      );
    });

    test('getGroupEntitlements returns empty for unfunded group', () async {
      final results = await endpoints.groupCommerce.getGroupEntitlements(
        authenticatedSessionBuilder,
        testGroup.id!,
      );
      expect(results, isEmpty);
    });

    test('getGroupEntitlements rejects non-member callers', () async {
      // Build a foreign group with no membership for testAccount.
      final session = sessionBuilder.build();
      final foreign = await ShareGroup.db.insertRow(
        session,
        ShareGroup(
          ultimateSigningPublicKeyHex: validPublicKey,
          ultimatePublicKey: validPublicKey,
          encryptedDataKey: 'other_group',
        ),
      );

      expect(
        () => endpoints.groupCommerce.getGroupEntitlements(
          authenticatedSessionBuilder,
          foreign.id!,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getGroupEntitlements fails without authentication', () async {
      expect(
        () => endpoints.groupCommerce.getGroupEntitlements(
          unauthenticatedSessionBuilder,
          testGroup.id!,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('consumeGroupEntitlement: happy path with sufficient balance',
        () async {
      final session = sessionBuilder.build();
      final existing = await Entitlement.db.findFirstRow(
        session,
        where: (t) => t.tag.equals('group_api_calls'),
      );
      if (existing == null) {
        await Entitlement.db.insertRow(
          session,
          Entitlement(
            name: 'Group API Calls',
            tag: 'group_api_calls',
            type: EntitlementType.consumable,
            serverValidated: true,
          ),
        );
      }
      await session.db.transaction((txn) async {
        await GroupEntitlementManager.grantGroupEntitlement(
          session,
          shareGroupUuid: testGroup.id!,
          tag: 'group_api_calls',
          quantity: 200.0,
          transaction: txn,
        );
      });

      final result = await endpoints.groupCommerce.consumeGroupEntitlement(
        authenticatedSessionBuilder,
        testGroup.id!,
        'group_api_calls',
        50.0,
      );
      expect(result.success, isTrue);
      expect(result.availableBalance, equals(150.0));

      // Verify log row was written with consumingAccountUuid attribution.
      final logs = await GroupConsumptionLog.db.find(
        session,
        where: (t) => t.shareGroupUuid.equals(testGroup.id!),
      );
      expect(logs, hasLength(1));
      expect(logs.single.consumingAccountUuid, equals(testAccount.id));
      expect(logs.single.amount, equals(50.0));
    });

    test('consumeGroupEntitlement: fails on insufficient balance', () async {
      final session = sessionBuilder.build();
      final existing = await Entitlement.db.findFirstRow(
        session,
        where: (t) => t.tag.equals('group_storage_gb'),
      );
      if (existing == null) {
        await Entitlement.db.insertRow(
          session,
          Entitlement(
            name: 'Group Storage GB',
            tag: 'group_storage_gb',
            type: EntitlementType.consumable,
            serverValidated: true,
          ),
        );
      }
      await session.db.transaction((txn) async {
        await GroupEntitlementManager.grantGroupEntitlement(
          session,
          shareGroupUuid: testGroup.id!,
          tag: 'group_storage_gb',
          quantity: 5.0,
          transaction: txn,
        );
      });

      final result = await endpoints.groupCommerce.consumeGroupEntitlement(
        authenticatedSessionBuilder,
        testGroup.id!,
        'group_storage_gb',
        50.0,
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Insufficient balance'));
    });

    test('consumeGroupEntitlement: rejected for non-member caller', () async {
      final session = sessionBuilder.build();
      final foreign = await ShareGroup.db.insertRow(
        session,
        ShareGroup(
          ultimateSigningPublicKeyHex: validPublicKey,
          ultimatePublicKey: validPublicKey,
          encryptedDataKey: 'other_group_2',
        ),
      );

      expect(
        () => endpoints.groupCommerce.consumeGroupEntitlement(
          authenticatedSessionBuilder,
          foreign.id!,
          'group_api_calls',
          1.0,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
