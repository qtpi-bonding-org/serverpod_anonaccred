import 'dart:async';

import 'package:anonaccount_client/anonaccount_client.dart' as client;
import 'package:anonaccount_sdk/anonaccount_sdk.dart' as sdk;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_test/serverpod_test.dart';

import 'package:anonaccount_server/src/generated/group_member_role.dart'
    as server_role;
import 'package:anonaccount_server/src/generated/member_device_grant.dart'
    as server_grant;

import 'serverpod_test_tools.dart';

ClientT convertModel<ClientT>(
  dynamic serverModel,
  ClientT Function(Map<String, dynamic>) fromJson,
) => fromJson((serverModel as dynamic).toJson() as Map<String, dynamic>);

class _NullClientShared extends ServerpodClientShared {
  _NullClientShared()
    : super(
        'http://127.0.0.1',
        client.Protocol(),
        streamingConnectionTimeout: const Duration(seconds: 1),
        connectionTimeout: const Duration(seconds: 1),
      );

  @override
  Map<String, EndpointRef> get endpointRefLookup => const {};

  @override
  Map<String, ModuleEndpointCaller> get moduleLookup => const {};
}

/// In-process bridge used by the SDK integration and end-to-end tests.
///
/// [client.Caller]'s own constructor builds the real generated `EndpointX`
/// objects against `this` and assigns them to `late final` fields — a
/// subclass constructor can't intercept or replace those assignments, since
/// a `late final` field accepts exactly one assignment and the superclass
/// constructor claims it first. So rather than swapping the six endpoint
/// fields, this overrides the two transport methods every generated
/// `EndpointX` method funnels through — `callServerEndpoint` and
/// `callStreamingServerEndpoint` — and dispatches by method name to the
/// matching `endpoints.X.method(...)` call against Serverpod's in-process
/// test server.
class SdkTestCaller extends client.Caller {
  SdkTestCaller(this.sessionBuilder, this.endpoints)
    : super(_NullClientShared());

  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    switch (method) {
      case 'getChallenge':
        return convertModel(
          await endpoints.entrypoint.getChallenge(sessionBuilder),
          client.PublicChallengeResponse.fromJson,
        ) as T;

      case 'createAccount':
        return convertModel(
          await endpoints.account.createAccount(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            publicKeyHex: args['publicKeyHex'] as String,
            ultimateKeys: args['ultimateKeys'] as client.PublicKeyDuo,
            encryptedDataKey: args['encryptedDataKey'] as String,
            deviceKeys: args['deviceKeys'] as client.PublicKeyDuo,
            deviceKeyAttestation: args['deviceKeyAttestation'] as String,
            deviceEncryptedDataKey: args['deviceEncryptedDataKey'] as String,
            deviceLabel: args['deviceLabel'] as String,
          ),
          client.AccountCreationResponse.fromJson,
        ) as T;

      case 'retrieveEncryptedDataKey':
        return convertModel(
          await endpoints.dataKey.retrieveEncryptedDataKey(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            deviceSigningPublicKeyHex:
                args['deviceSigningPublicKeyHex'] as String,
          ),
          client.EncryptedDataKeyResponse.fromJson,
        ) as T;

      case 'recoverEncryptedDataKey':
        return convertModel(
          await endpoints.dataKey.recoverEncryptedDataKey(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            ultimateSigningPublicKeyHex:
                args['ultimateSigningPublicKeyHex'] as String,
          ),
          client.EncryptedDataKeyResponse.fromJson,
        ) as T;

      case 'registerDevice':
        return convertModel(
          await endpoints.device.registerDevice(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            deviceKeyAttestation: args['deviceKeyAttestation'] as String,
            ultimateSigningPublicKeyHex:
                args['ultimateSigningPublicKeyHex'] as String,
            deviceKeys: args['deviceKeys'] as client.PublicKeyDuo,
            encryptedDataKey: args['encryptedDataKey'] as String,
            label: args['label'] as String,
          ),
          client.AccountDevice.fromJson,
        ) as T;

      case 'signIn':
        return convertModel(
          await endpoints.device.signIn(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            devicePublicKeyHex: args['devicePublicKeyHex'] as String,
          ),
          client.AuthenticationResult.fromJson,
        ) as T;

      case 'revokeDevice':
        return await endpoints.deviceManagement.revokeDevice(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              publicKeyHex: args['publicKeyHex'] as String,
              signature: args['signature'] as String,
              deviceId: args['deviceId'] as UuidValue,
            )
            as T;

      case 'listDevices':
        return (await endpoints.deviceManagement.listDevices(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              publicKeyHex: args['publicKeyHex'] as String,
              signature: args['signature'] as String,
            ))
            .map((row) => convertModel(row, client.AccountDevice.fromJson))
            .toList() as T;

      case 'registerDeviceForAccount':
        return convertModel(
          await endpoints.deviceManagement.registerDeviceForAccount(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            publicKeyHex: args['publicKeyHex'] as String,
            signature: args['signature'] as String,
            newDeviceKeys: args['newDeviceKeys'] as client.PublicKeyDuo,
            pairingAttestation: args['pairingAttestation'] as String,
            newDeviceEncryptedDataKey:
                args['newDeviceEncryptedDataKey'] as String,
            label: args['label'] as String,
            ultimateEncryptionPublicKeyHex:
                args['ultimateEncryptionPublicKeyHex'] as String,
            ultimateSigningPublicKeyHex:
                args['ultimateSigningPublicKeyHex'] as String,
          ),
          client.AccountDevice.fromJson,
        ) as T;

      case 'createGroup':
        return convertModel(
          await endpoints.group.createGroup(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            callerDeviceSigningPublicKeyHex:
                args['callerDeviceSigningPublicKeyHex'] as String,
            groupUltimateKeys:
                args['groupUltimateKeys'] as client.PublicKeyDuo,
            groupEncryptedDataKey: args['groupEncryptedDataKey'] as String,
            creatorMemberKeys:
                args['creatorMemberKeys'] as client.PublicKeyDuo,
            creatorMemberEncryptedDataKey:
                args['creatorMemberEncryptedDataKey'] as String,
            groupUltimateAttestation:
                args['groupUltimateAttestation'] as String,
            creatorEncryptedMemberKey:
                args['creatorEncryptedMemberKey'] as String,
            creatorEncryptedMemberKeyAttestation:
                args['creatorEncryptedMemberKeyAttestation'] as String,
            creatorEncryptedUltimateKey:
                args['creatorEncryptedUltimateKey'] as String,
            creatorEncryptedUltimateKeyAttestation:
                args['creatorEncryptedUltimateKeyAttestation'] as String,
          ),
          client.ShareGroup.fromJson,
        ) as T;

      case 'listMyGroups':
        return (await endpoints.group.listMyGroups(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              callerDeviceSigningPublicKeyHex:
                  args['callerDeviceSigningPublicKeyHex'] as String,
            ))
            .map(
              (row) => convertModel(row, client.GroupMembershipView.fromJson),
            )
            .toList() as T;

      case 'addGroupMember':
        return convertModel(
          await endpoints.group.addGroupMember(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            callerDeviceSigningPublicKeyHex:
                args['callerDeviceSigningPublicKeyHex'] as String,
            groupId: args['groupId'] as UuidValue,
            newMemberAccountId: args['newMemberAccountId'] as UuidValue,
            role: server_role.GroupMemberRole.values.byName(
              (args['role'] as client.GroupMemberRole).name,
            ),
            memberKeys: args['memberKeys'] as client.PublicKeyDuo,
            encryptedDataKey: args['encryptedDataKey'] as String,
            encryptedMemberKey: args['encryptedMemberKey'] as String,
            encryptedMemberKeyAttestation:
                args['encryptedMemberKeyAttestation'] as String,
            callerMemberSigningPublicKeyHex:
                args['callerMemberSigningPublicKeyHex'] as String?,
            memberAuthSignature: args['memberAuthSignature'] as String?,
            groupUltimateSignature: args['groupUltimateSignature'] as String?,
          ),
          client.GroupMember.fromJson,
        ) as T;

      case 'removeGroupMember':
        return await endpoints.group.removeGroupMember(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              callerDeviceSigningPublicKeyHex:
                  args['callerDeviceSigningPublicKeyHex'] as String,
              memberId: args['memberId'] as UuidValue,
              callerMemberSigningPublicKeyHex:
                  args['callerMemberSigningPublicKeyHex'] as String?,
              memberAuthSignature: args['memberAuthSignature'] as String?,
              groupUltimateSignature:
                  args['groupUltimateSignature'] as String?,
            )
            as T;

      case 'changeGroupMemberRole':
        return convertModel(
          await endpoints.group.changeGroupMemberRole(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            callerDeviceSigningPublicKeyHex:
                args['callerDeviceSigningPublicKeyHex'] as String,
            memberId: args['memberId'] as UuidValue,
            newRole: server_role.GroupMemberRole.values.byName(
              (args['newRole'] as client.GroupMemberRole).name,
            ),
            callerMemberSigningPublicKeyHex:
                args['callerMemberSigningPublicKeyHex'] as String?,
            memberAuthSignature: args['memberAuthSignature'] as String?,
            groupUltimateSignature: args['groupUltimateSignature'] as String?,
          ),
          client.GroupMember.fromJson,
        ) as T;

      case 'leaveGroup':
        return await endpoints.group.leaveGroup(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              callerDeviceSigningPublicKeyHex:
                  args['callerDeviceSigningPublicKeyHex'] as String,
              memberId: args['memberId'] as UuidValue,
              memberSigningPublicKeyHex:
                  args['memberSigningPublicKeyHex'] as String,
              memberAuthSignature: args['memberAuthSignature'] as String,
            )
            as T;

      case 'grantMemberDevice':
        return convertModel(
          await endpoints.group.grantMemberDevice(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            callerDeviceSigningPublicKeyHex:
                args['callerDeviceSigningPublicKeyHex'] as String,
            grants: (args['grants'] as List<client.MemberDeviceGrant>)
                .map(
                  (grant) =>
                      server_grant.MemberDeviceGrant.fromJson(grant.toJson()),
                )
                .toList(),
          ),
          client.GrantMemberDeviceResult.fromJson,
        ) as T;

      case 'getGroup':
        return convertModel(
          await endpoints.group.getGroup(
            sessionBuilder,
            challenge: args['challenge'] as String,
            proofOfWork: args['proofOfWork'] as String,
            signature: args['signature'] as String,
            callerDeviceSigningPublicKeyHex:
                args['callerDeviceSigningPublicKeyHex'] as String,
            groupId: args['groupId'] as UuidValue,
            callerMemberSigningPublicKeyHex:
                args['callerMemberSigningPublicKeyHex'] as String,
            memberAuthSignature: args['memberAuthSignature'] as String,
          ),
          client.ShareGroup.fromJson,
        ) as T;

      case 'listGroupMembers':
        return (await endpoints.group.listGroupMembers(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              callerDeviceSigningPublicKeyHex:
                  args['callerDeviceSigningPublicKeyHex'] as String,
              groupId: args['groupId'] as UuidValue,
              callerMemberSigningPublicKeyHex:
                  args['callerMemberSigningPublicKeyHex'] as String,
              memberAuthSignature: args['memberAuthSignature'] as String,
            ))
            .map((row) => convertModel(row, client.GroupMemberView.fromJson))
            .toList() as T;

      default:
        throw UnimplementedError(
          'SdkTestCaller: unhandled endpoint call $endpoint.$method',
        );
    }
  }

  @override
  dynamic callStreamingServerEndpoint<T, G>(
    String endpoint,
    String method,
    Map<String, dynamic> args,
    Map<String, Stream> streams, {
    bool authenticated = true,
  }) {
    switch (method) {
      case 'monitorRegistration':
        return endpoints.device
            .monitorRegistration(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              signingKeyHex: args['signingKeyHex'] as String,
            )
            .map(
              (event) =>
                  convertModel(event, client.DevicePairingEvent.fromJson),
            );

      case 'monitorGroupMembership':
        return endpoints.group
            .monitorGroupMembership(
              sessionBuilder,
              challenge: args['challenge'] as String,
              proofOfWork: args['proofOfWork'] as String,
              signature: args['signature'] as String,
              callerDeviceSigningPublicKeyHex:
                  args['callerDeviceSigningPublicKeyHex'] as String,
              groupId: args['groupId'] as UuidValue,
              memberSigningKeyHex: args['memberSigningKeyHex'] as String,
              memberAuthSignature: args['memberAuthSignature'] as String,
            )
            .map(
              (event) => convertModel(event, client.GroupMemberView.fromJson),
            );

      default:
        throw UnimplementedError(
          'SdkTestCaller: unhandled streaming call $endpoint.$method',
        );
    }
  }

  Future<client.ShareGroup> endpointGetGroupRaw({
    required String groupId,
    required TestEnvelope envelope,
    required String callerDeviceSigningPublicKeyHex,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async => convertModel(
    await endpoints.group.getGroup(
      sessionBuilder,
      challenge: envelope.challenge,
      proofOfWork: envelope.proofOfWork,
      signature: envelope.signature,
      callerDeviceSigningPublicKeyHex: callerDeviceSigningPublicKeyHex,
      groupId: UuidValue.fromString(groupId),
      callerMemberSigningPublicKeyHex: callerMemberSigningPublicKeyHex,
      memberAuthSignature: memberAuthSignature,
    ),
    client.ShareGroup.fromJson,
  );

  Future<List<client.GroupMemberView>> endpointListGroupMembersRaw({
    required String groupId,
    required TestEnvelope envelope,
    required String callerDeviceSigningPublicKeyHex,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async => (await endpoints.group.listGroupMembers(
    sessionBuilder,
    challenge: envelope.challenge,
    proofOfWork: envelope.proofOfWork,
    signature: envelope.signature,
    callerDeviceSigningPublicKeyHex: callerDeviceSigningPublicKeyHex,
    groupId: UuidValue.fromString(groupId),
    callerMemberSigningPublicKeyHex: callerMemberSigningPublicKeyHex,
    memberAuthSignature: memberAuthSignature,
  )).map((row) => convertModel(row, client.GroupMemberView.fromJson)).toList();
}

class TestEnvelope {
  const TestEnvelope(this.challenge, this.proofOfWork, this.signature);
  final String challenge;
  final String proofOfWork;
  final String signature;
}

extension SdkTestCallerEnvelope on SdkTestCaller {
  Future<TestEnvelope> buildEnvelope({
    required String methodName,
    required sdk.KeyDuo signingKey,
    required String publicKeyHex,
    int difficulty = 20,
  }) async {
    final challenge = await entrypoint.getChallenge();
    final proofOfWork = await sdk.Hashcash.mint(
      challenge.challenge,
      difficulty: challenge.difficulty,
    );
    final signature = await sdk.SigningCrypto.signChallenge(
      '${challenge.challenge}:$methodName:$publicKeyHex',
      signingKey,
    );
    return TestEnvelope(challenge.challenge, proofOfWork, signature);
  }
}
