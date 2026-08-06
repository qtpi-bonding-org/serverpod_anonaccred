import 'package:anonaccount_server/anonaccount_server.dart';
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/payments/polar_client.dart';
import 'package:test/test.dart';
import 'test_tools/commerce_test_harness.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Group commerce lifecycle', (sessionBuilder, endpoints) {
    test(
      'member consumes, gets revoked, can no longer consume; balance and other members unaffected',
      () async {
        final buyer = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'buyer');
        final member = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'member');
        final otherMember = await CommerceTestHarness.create(sessionBuilder, endpoints, label: 'other');

        final session = sessionBuilder.build();
        final group = await ShareGroup.db.insertRow(
          session,
          ShareGroup(
            ultimateSigningPublicKeyHex: 'a' * 128,
            ultimateEncryptionPublicKeyHex: 'a' * 128,
            encryptedDataKey: 'x',
            createdAt: DateTime.now(),
          ),
        );
        for (final h in [buyer, member, otherMember]) {
          await GroupMember.db.insertRow(
            session,
            GroupMember(
              shareGroupId: group.id!,
              anonAccountId: h.accountUuid,
              role: GroupMemberRole.member,
              memberSigningPublicKeyHex: h.accountUuid.toString().padRight(128, '0').substring(0, 128),
              memberEncryptionPublicKeyHex: h.accountUuid.toString().padRight(128, '0').substring(0, 128),
              encryptedDataKey: 'x',
              encryptedMemberKey: 'x',
              joinedAt: DateTime.now(),
              addedByAttestorPublicKeyHex: 'a' * 128,
              addedByAttestation: 'x',
            ),
          );
        }
        await session.close();

        await seedRailProduct(
          sessionBuilder.build(),
          rail: PaymentRail.polar,
          storeProductId: 'benefit-group-license-1',
          tag: 'group_storage',
          quantity: 50,
        );
        buyer.polarMock.addMockLicense(
          'GROUP-LICENSE-1',
          PolarLicenseValidation(
            id: 'lk-group-license-1',
            key: 'GROUP-LICENSE-1',
            status: 'granted',
            organizationId: 'mock-org',
            benefitId: 'benefit-group-license-1',
            customerId: 'cust-buyer',
            expiresAt: null,
            raw: const {},
          ),
        );
        final purchase = await buyer.redeemPolarForGroup(licenseKey: 'GROUP-LICENSE-1', shareGroupUuid: group.id!);
        expect(purchase.success, isTrue);

        final consumeResult = await member.consumeGroup(group.id!, purchase.tag!, 10);
        expect(consumeResult.success, isTrue);

        final revokeSession = sessionBuilder.build();
        final memberRow = (await GroupMember.db.findFirstRow(
          revokeSession,
          where: (t) => t.shareGroupId.equals(group.id!) & t.anonAccountId.equals(member.accountUuid),
        ))!;
        await GroupMember.db.updateRow(revokeSession, memberRow.copyWith(isRevoked: true));
        await revokeSession.close();

        await expectLater(
          member.consumeGroup(group.id!, purchase.tag!, 1),
          throwsA(isA<AuthenticationException>()),
        );

        final otherStillWorks = await otherMember.consumeGroup(group.id!, purchase.tag!, 5);
        expect(otherStillWorks.success, isTrue);
      },
    );
  });
}
