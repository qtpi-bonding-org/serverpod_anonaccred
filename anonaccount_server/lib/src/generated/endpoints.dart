/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/account_endpoint.dart' as _i2;
import '../endpoints/data_key_endpoint.dart' as _i3;
import '../endpoints/device_endpoint.dart' as _i4;
import '../endpoints/device_management_endpoint.dart' as _i5;
import '../endpoints/entrypoint_endpoint.dart' as _i6;
import '../endpoints/group_endpoint.dart' as _i7;
import 'package:anonaccount_server/src/generated/group_member_role.dart' as _i8;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i9;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i10;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'account': _i2.AccountEndpoint()
        ..initialize(
          server,
          'account',
          'anonaccount',
        ),
      'dataKey': _i3.DataKeyEndpoint()
        ..initialize(
          server,
          'dataKey',
          'anonaccount',
        ),
      'device': _i4.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          'anonaccount',
        ),
      'deviceManagement': _i5.DeviceManagementEndpoint()
        ..initialize(
          server,
          'deviceManagement',
          'anonaccount',
        ),
      'entrypoint': _i6.EntrypointEndpoint()
        ..initialize(
          server,
          'entrypoint',
          'anonaccount',
        ),
      'group': _i7.GroupEndpoint()
        ..initialize(
          server,
          'group',
          'anonaccount',
        ),
    };
    connectors['account'] = _i1.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'createAccount': _i1.MethodConnector(
          name: 'createAccount',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'encryptedDataKey': _i1.ParameterDescription(
              name: 'encryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ultimatePublicKey': _i1.ParameterDescription(
              name: 'ultimatePublicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceKeyAttestation': _i1.ParameterDescription(
              name: 'deviceKeyAttestation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'deviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceEncryptedDataKey': _i1.ParameterDescription(
              name: 'deviceEncryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceLabel': _i1.ParameterDescription(
              name: 'deviceLabel',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _i2.AccountEndpoint).createAccount(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    publicKeyHex: params['publicKeyHex'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                    encryptedDataKey: params['encryptedDataKey'],
                    ultimatePublicKey: params['ultimatePublicKey'],
                    deviceKeyAttestation: params['deviceKeyAttestation'],
                    deviceSigningPublicKeyHex:
                        params['deviceSigningPublicKeyHex'],
                    deviceEncryptedDataKey: params['deviceEncryptedDataKey'],
                    deviceLabel: params['deviceLabel'],
                  ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint)
                  .getChallenge(session),
        ),
        'verifySignedPow': _i1.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _i2.AccountEndpoint).verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['account'] as _i2.AccountEndpoint).verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['dataKey'] = _i1.EndpointConnector(
      name: 'dataKey',
      endpoint: endpoints['dataKey']!,
      methodConnectors: {
        'retrieveEncryptedDataKey': _i1.MethodConnector(
          name: 'retrieveEncryptedDataKey',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'deviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dataKey'] as _i3.DataKeyEndpoint)
                  .retrieveEncryptedDataKey(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    deviceSigningPublicKeyHex:
                        params['deviceSigningPublicKeyHex'],
                  ),
        ),
        'recoverEncryptedDataKey': _i1.MethodConnector(
          name: 'recoverEncryptedDataKey',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dataKey'] as _i3.DataKeyEndpoint)
                  .recoverEncryptedDataKey(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                  ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dataKey'] as _i3.DataKeyEndpoint)
                  .getChallenge(session),
        ),
        'verifySignedPow': _i1.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dataKey'] as _i3.DataKeyEndpoint).verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dataKey'] as _i3.DataKeyEndpoint).verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'registerDevice': _i1.MethodConnector(
          name: 'registerDevice',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceKeyAttestation': _i1.ParameterDescription(
              name: 'deviceKeyAttestation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'deviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'encryptedDataKey': _i1.ParameterDescription(
              name: 'encryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i4.DeviceEndpoint).registerDevice(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    deviceKeyAttestation: params['deviceKeyAttestation'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                    deviceSigningPublicKeyHex:
                        params['deviceSigningPublicKeyHex'],
                    encryptedDataKey: params['encryptedDataKey'],
                    label: params['label'],
                  ),
        ),
        'signIn': _i1.MethodConnector(
          name: 'signIn',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'devicePublicKeyHex': _i1.ParameterDescription(
              name: 'devicePublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i4.DeviceEndpoint).signIn(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                devicePublicKeyHex: params['devicePublicKeyHex'],
              ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i4.DeviceEndpoint)
                  .getChallenge(session),
        ),
        'verifySignedPow': _i1.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i4.DeviceEndpoint).verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i4.DeviceEndpoint).verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
        'monitorRegistration': _i1.MethodStreamConnector(
          name: 'monitorRegistration',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signingKeyHex': _i1.ParameterDescription(
              name: 'signingKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['device'] as _i4.DeviceEndpoint)
                  .monitorRegistration(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    signingKeyHex: params['signingKeyHex'],
                  ),
        ),
      },
    );
    connectors['deviceManagement'] = _i1.EndpointConnector(
      name: 'deviceManagement',
      endpoint: endpoints['deviceManagement']!,
      methodConnectors: {
        'revokeDevice': _i1.MethodConnector(
          name: 'revokeDevice',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .revokeDevice(
                        session,
                        challenge: params['challenge'],
                        proofOfWork: params['proofOfWork'],
                        publicKeyHex: params['publicKeyHex'],
                        signature: params['signature'],
                        deviceId: params['deviceId'],
                      ),
        ),
        'listDevices': _i1.MethodConnector(
          name: 'listDevices',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .listDevices(
                        session,
                        challenge: params['challenge'],
                        proofOfWork: params['proofOfWork'],
                        publicKeyHex: params['publicKeyHex'],
                        signature: params['signature'],
                      ),
        ),
        'registerDeviceForAccount': _i1.MethodConnector(
          name: 'registerDeviceForAccount',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'newDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newDeviceEncryptedDataKey': _i1.ParameterDescription(
              name: 'newDeviceEncryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .registerDeviceForAccount(
                        session,
                        challenge: params['challenge'],
                        proofOfWork: params['proofOfWork'],
                        publicKeyHex: params['publicKeyHex'],
                        signature: params['signature'],
                        newDeviceSigningPublicKeyHex:
                            params['newDeviceSigningPublicKeyHex'],
                        newDeviceEncryptedDataKey:
                            params['newDeviceEncryptedDataKey'],
                        label: params['label'],
                      ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .getChallenge(session),
        ),
        'verifySignedPow': _i1.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .verifySignedPow(
                        session,
                        params['challenge'],
                        params['proofOfWork'],
                        params['publicKeyHex'],
                        params['signature'],
                        params['payload'],
                      ),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i5.DeviceManagementEndpoint)
                      .verifyHashcash(
                        session,
                        params['challenge'],
                        params['proofOfWork'],
                      ),
        ),
      },
    );
    connectors['entrypoint'] = _i1.EndpointConnector(
      name: 'entrypoint',
      endpoint: endpoints['entrypoint']!,
      methodConnectors: {
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['entrypoint'] as _i6.EntrypointEndpoint)
                  .getChallenge(session),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['entrypoint'] as _i6.EntrypointEndpoint)
                  .verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['group'] = _i1.EndpointConnector(
      name: 'group',
      endpoint: endpoints['group']!,
      methodConnectors: {
        'createGroup': _i1.MethodConnector(
          name: 'createGroup',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupUltimateSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'groupUltimateSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupUltimatePublicKey': _i1.ParameterDescription(
              name: 'groupUltimatePublicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupEncryptedDataKey': _i1.ParameterDescription(
              name: 'groupEncryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'creatorMemberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'creatorMemberSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'creatorMemberPublicKey': _i1.ParameterDescription(
              name: 'creatorMemberPublicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'creatorMemberEncryptedDataKey': _i1.ParameterDescription(
              name: 'creatorMemberEncryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupUltimateAttestation': _i1.ParameterDescription(
              name: 'groupUltimateAttestation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['group'] as _i7.GroupEndpoint).createGroup(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                groupUltimateSigningPublicKeyHex:
                    params['groupUltimateSigningPublicKeyHex'],
                groupUltimatePublicKey: params['groupUltimatePublicKey'],
                groupEncryptedDataKey: params['groupEncryptedDataKey'],
                creatorMemberSigningPublicKeyHex:
                    params['creatorMemberSigningPublicKeyHex'],
                creatorMemberPublicKey: params['creatorMemberPublicKey'],
                creatorMemberEncryptedDataKey:
                    params['creatorMemberEncryptedDataKey'],
                groupUltimateAttestation: params['groupUltimateAttestation'],
              ),
        ),
        'listMyGroups': _i1.MethodConnector(
          name: 'listMyGroups',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['group'] as _i7.GroupEndpoint).listMyGroups(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
              ),
        ),
        'addGroupMember': _i1.MethodConnector(
          name: 'addGroupMember',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'newMemberAccountId': _i1.ParameterDescription(
              name: 'newMemberAccountId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i8.GroupMemberRole>(),
              nullable: false,
            ),
            'memberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'memberSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberPublicKey': _i1.ParameterDescription(
              name: 'memberPublicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'encryptedDataKey': _i1.ParameterDescription(
              name: 'encryptedDataKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'memberAuthSignature': _i1.ParameterDescription(
              name: 'memberAuthSignature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'groupUltimateSignature': _i1.ParameterDescription(
              name: 'groupUltimateSignature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['group'] as _i7.GroupEndpoint).addGroupMember(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    groupId: params['groupId'],
                    newMemberAccountId: params['newMemberAccountId'],
                    role: params['role'],
                    memberSigningPublicKeyHex:
                        params['memberSigningPublicKeyHex'],
                    memberPublicKey: params['memberPublicKey'],
                    encryptedDataKey: params['encryptedDataKey'],
                    callerMemberSigningPublicKeyHex:
                        params['callerMemberSigningPublicKeyHex'],
                    memberAuthSignature: params['memberAuthSignature'],
                    groupUltimateSignature: params['groupUltimateSignature'],
                  ),
        ),
        'removeGroupMember': _i1.MethodConnector(
          name: 'removeGroupMember',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberId': _i1.ParameterDescription(
              name: 'memberId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'memberAuthSignature': _i1.ParameterDescription(
              name: 'memberAuthSignature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'groupUltimateSignature': _i1.ParameterDescription(
              name: 'groupUltimateSignature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['group'] as _i7.GroupEndpoint).removeGroupMember(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    memberId: params['memberId'],
                    callerMemberSigningPublicKeyHex:
                        params['callerMemberSigningPublicKeyHex'],
                    memberAuthSignature: params['memberAuthSignature'],
                    groupUltimateSignature: params['groupUltimateSignature'],
                  ),
        ),
        'getGroup': _i1.MethodConnector(
          name: 'getGroup',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _i1.ParameterDescription(
              name: 'memberAuthSignature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['group'] as _i7.GroupEndpoint).getGroup(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                groupId: params['groupId'],
                callerMemberSigningPublicKeyHex:
                    params['callerMemberSigningPublicKeyHex'],
                memberAuthSignature: params['memberAuthSignature'],
              ),
        ),
        'listGroupMembers': _i1.MethodConnector(
          name: 'listGroupMembers',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'groupId': _i1.ParameterDescription(
              name: 'groupId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _i1.ParameterDescription(
              name: 'memberAuthSignature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['group'] as _i7.GroupEndpoint).listGroupMembers(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    groupId: params['groupId'],
                    callerMemberSigningPublicKeyHex:
                        params['callerMemberSigningPublicKeyHex'],
                    memberAuthSignature: params['memberAuthSignature'],
                  ),
        ),
        'leaveGroup': _i1.MethodConnector(
          name: 'leaveGroup',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberId': _i1.ParameterDescription(
              name: 'memberId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'memberSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'memberSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _i1.ParameterDescription(
              name: 'memberAuthSignature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['group'] as _i7.GroupEndpoint).leaveGroup(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                memberId: params['memberId'],
                memberSigningPublicKeyHex: params['memberSigningPublicKeyHex'],
                memberAuthSignature: params['memberAuthSignature'],
              ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['group'] as _i7.GroupEndpoint).getChallenge(
                session,
              ),
        ),
        'verifySignedPow': _i1.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _i1.ParameterDescription(
              name: 'publicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'payload': _i1.ParameterDescription(
              name: 'payload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['group'] as _i7.GroupEndpoint).verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _i1.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['group'] as _i7.GroupEndpoint).verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
        'monitorGroupMembership': _i1.MethodStreamConnector(
          name: 'monitorGroupMembership',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _i1.ParameterDescription(
              name: 'proofOfWork',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _i1.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'memberSigningKeyHex': _i1.ParameterDescription(
              name: 'memberSigningKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['group'] as _i7.GroupEndpoint)
                  .monitorGroupMembership(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    memberSigningKeyHex: params['memberSigningKeyHex'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i9.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i10.Endpoints()
      ..initializeEndpoints(server);
  }
}
