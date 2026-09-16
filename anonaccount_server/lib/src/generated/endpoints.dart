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
import 'package:anonaccount_protocol/anonaccount_protocol.dart' as _ijl9ntd6;
import 'package:anonaccount_server/src/generated/group_member_role.dart'
    as _ieyt77v6;
import 'package:anonaccount_server/src/generated/member_device_grant.dart'
    as _ij4d8jf2;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../endpoints/account_endpoint.dart' as _iaho7ul5;
import '../endpoints/data_key_endpoint.dart' as _i7u23sdj;
import '../endpoints/device_endpoint.dart' as _ipl99gaq;
import '../endpoints/device_management_endpoint.dart' as _i59fzg7i;
import '../endpoints/entrypoint_endpoint.dart' as _i7fewh4s;
import '../endpoints/group_endpoint.dart' as _iknqvl2r;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'account': _iaho7ul5.AccountEndpoint()
        ..initialize(server, 'account', 'anonaccount'),
      'dataKey': _i7u23sdj.DataKeyEndpoint()
        ..initialize(server, 'dataKey', 'anonaccount'),
      'device': _ipl99gaq.DeviceEndpoint()
        ..initialize(server, 'device', 'anonaccount'),
      'deviceManagement': _i59fzg7i.DeviceManagementEndpoint()
        ..initialize(server, 'deviceManagement', 'anonaccount'),
      'entrypoint': _i7fewh4s.EntrypointEndpoint()
        ..initialize(server, 'entrypoint', 'anonaccount'),
      'group': _iknqvl2r.GroupEndpoint()
        ..initialize(server, 'group', 'anonaccount'),
    };
    connectors['account'] = _is.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'createAccount': _is.MethodConnector(
          name: 'createAccount',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'ultimateKeys': _is.ParameterDescription(
              name: 'ultimateKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'encryptedDataKey': _is.ParameterDescription(
              name: 'encryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceKeys': _is.ParameterDescription(
              name: 'deviceKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'deviceKeyAttestation': _is.ParameterDescription(
              name: 'deviceKeyAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceEncryptedDataKey': _is.ParameterDescription(
              name: 'deviceEncryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceLabel': _is.ParameterDescription(
              name: 'deviceLabel',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _iaho7ul5.AccountEndpoint).createAccount(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                publicKeyHex: params['publicKeyHex'],
                ultimateKeys: params['ultimateKeys'],
                encryptedDataKey: params['encryptedDataKey'],
                deviceKeys: params['deviceKeys'],
                deviceKeyAttestation: params['deviceKeyAttestation'],
                deviceEncryptedDataKey: params['deviceEncryptedDataKey'],
                deviceLabel: params['deviceLabel'],
              ),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _iaho7ul5.AccountEndpoint).getChallenge(
                session,
              ),
        ),
        'verifySignedPow': _is.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _iaho7ul5.AccountEndpoint)
                  .verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['account'] as _iaho7ul5.AccountEndpoint)
                  .verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['dataKey'] = _is.EndpointConnector(
      name: 'dataKey',
      endpoint: endpoints['dataKey']!,
      methodConnectors: {
        'retrieveEncryptedDataKey': _is.MethodConnector(
          name: 'retrieveEncryptedDataKey',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'deviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['dataKey'] as _i7u23sdj.DataKeyEndpoint)
                  .retrieveEncryptedDataKey(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    deviceSigningPublicKeyHex:
                        params['deviceSigningPublicKeyHex'],
                  ),
        ),
        'recoverEncryptedDataKey': _is.MethodConnector(
          name: 'recoverEncryptedDataKey',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _is.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['dataKey'] as _i7u23sdj.DataKeyEndpoint)
                  .recoverEncryptedDataKey(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                  ),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['dataKey'] as _i7u23sdj.DataKeyEndpoint).getChallenge(
                session,
              ),
        ),
        'verifySignedPow': _is.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['dataKey'] as _i7u23sdj.DataKeyEndpoint)
                  .verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['dataKey'] as _i7u23sdj.DataKeyEndpoint)
                  .verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['device'] = _is.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'registerDevice': _is.MethodConnector(
          name: 'registerDevice',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceKeyAttestation': _is.ParameterDescription(
              name: 'deviceKeyAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _is.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceKeys': _is.ParameterDescription(
              name: 'deviceKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'encryptedDataKey': _is.ParameterDescription(
              name: 'encryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'label': _is.ParameterDescription(
              name: 'label',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['device'] as _ipl99gaq.DeviceEndpoint).registerDevice(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                deviceKeyAttestation: params['deviceKeyAttestation'],
                ultimateSigningPublicKeyHex:
                    params['ultimateSigningPublicKeyHex'],
                deviceKeys: params['deviceKeys'],
                encryptedDataKey: params['encryptedDataKey'],
                label: params['label'],
              ),
        ),
        'signIn': _is.MethodConnector(
          name: 'signIn',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'devicePublicKeyHex': _is.ParameterDescription(
              name: 'devicePublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['device'] as _ipl99gaq.DeviceEndpoint).signIn(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                devicePublicKeyHex: params['devicePublicKeyHex'],
              ),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['device'] as _ipl99gaq.DeviceEndpoint).getChallenge(
                session,
              ),
        ),
        'verifySignedPow': _is.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['device'] as _ipl99gaq.DeviceEndpoint).verifySignedPow(
                session,
                params['challenge'],
                params['proofOfWork'],
                params['publicKeyHex'],
                params['signature'],
                params['payload'],
              ),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['device'] as _ipl99gaq.DeviceEndpoint).verifyHashcash(
                session,
                params['challenge'],
                params['proofOfWork'],
              ),
        ),
        'monitorRegistration': _is.MethodStreamConnector(
          name: 'monitorRegistration',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signingKeyHex': _is.ParameterDescription(
              name: 'signingKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['device'] as _ipl99gaq.DeviceEndpoint)
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
    connectors['deviceManagement'] = _is.EndpointConnector(
      name: 'deviceManagement',
      endpoint: endpoints['deviceManagement']!,
      methodConnectors: {
        'revokeDevice': _is.MethodConnector(
          name: 'revokeDevice',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'deviceId': _is.ParameterDescription(
              name: 'deviceId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .revokeDevice(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    publicKeyHex: params['publicKeyHex'],
                    signature: params['signature'],
                    deviceId: params['deviceId'],
                  ),
        ),
        'listDevices': _is.MethodConnector(
          name: 'listDevices',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .listDevices(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    publicKeyHex: params['publicKeyHex'],
                    signature: params['signature'],
                  ),
        ),
        'registerDeviceForAccount': _is.MethodConnector(
          name: 'registerDeviceForAccount',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newDeviceKeys': _is.ParameterDescription(
              name: 'newDeviceKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'pairingAttestation': _is.ParameterDescription(
              name: 'pairingAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newDeviceEncryptedDataKey': _is.ParameterDescription(
              name: 'newDeviceEncryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'label': _is.ParameterDescription(
              name: 'label',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'ultimateEncryptionPublicKeyHex': _is.ParameterDescription(
              name: 'ultimateEncryptionPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'ultimateSigningPublicKeyHex': _is.ParameterDescription(
              name: 'ultimateSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .registerDeviceForAccount(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    publicKeyHex: params['publicKeyHex'],
                    signature: params['signature'],
                    newDeviceKeys: params['newDeviceKeys'],
                    pairingAttestation: params['pairingAttestation'],
                    newDeviceEncryptedDataKey:
                        params['newDeviceEncryptedDataKey'],
                    label: params['label'],
                    ultimateEncryptionPublicKeyHex:
                        params['ultimateEncryptionPublicKeyHex'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                  ),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .getChallenge(session),
        ),
        'verifySignedPow': _is.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .verifySignedPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
                  ),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['deviceManagement']
                      as _i59fzg7i.DeviceManagementEndpoint)
                  .verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['entrypoint'] = _is.EndpointConnector(
      name: 'entrypoint',
      endpoint: endpoints['entrypoint']!,
      methodConnectors: {
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['entrypoint'] as _i7fewh4s.EntrypointEndpoint)
                  .getChallenge(session),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['entrypoint'] as _i7fewh4s.EntrypointEndpoint)
                  .verifyHashcash(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                  ),
        ),
      },
    );
    connectors['group'] = _is.EndpointConnector(
      name: 'group',
      endpoint: endpoints['group']!,
      methodConnectors: {
        'createGroup': _is.MethodConnector(
          name: 'createGroup',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupUltimateKeys': _is.ParameterDescription(
              name: 'groupUltimateKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'groupEncryptedDataKey': _is.ParameterDescription(
              name: 'groupEncryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'creatorMemberKeys': _is.ParameterDescription(
              name: 'creatorMemberKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'creatorMemberEncryptedDataKey': _is.ParameterDescription(
              name: 'creatorMemberEncryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupUltimateAttestation': _is.ParameterDescription(
              name: 'groupUltimateAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'creatorEncryptedMemberKey': _is.ParameterDescription(
              name: 'creatorEncryptedMemberKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'creatorEncryptedMemberKeyAttestation': _is.ParameterDescription(
              name: 'creatorEncryptedMemberKeyAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'creatorEncryptedUltimateKey': _is.ParameterDescription(
              name: 'creatorEncryptedUltimateKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'creatorEncryptedUltimateKeyAttestation': _is.ParameterDescription(
              name: 'creatorEncryptedUltimateKeyAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).createGroup(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                groupUltimateKeys: params['groupUltimateKeys'],
                groupEncryptedDataKey: params['groupEncryptedDataKey'],
                creatorMemberKeys: params['creatorMemberKeys'],
                creatorMemberEncryptedDataKey:
                    params['creatorMemberEncryptedDataKey'],
                groupUltimateAttestation: params['groupUltimateAttestation'],
                creatorEncryptedMemberKey: params['creatorEncryptedMemberKey'],
                creatorEncryptedMemberKeyAttestation:
                    params['creatorEncryptedMemberKeyAttestation'],
                creatorEncryptedUltimateKey:
                    params['creatorEncryptedUltimateKey'],
                creatorEncryptedUltimateKeyAttestation:
                    params['creatorEncryptedUltimateKeyAttestation'],
              ),
        ),
        'listMyGroups': _is.MethodConnector(
          name: 'listMyGroups',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).listMyGroups(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
              ),
        ),
        'addGroupMember': _is.MethodConnector(
          name: 'addGroupMember',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupId': _is.ParameterDescription(
              name: 'groupId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'newMemberAccountId': _is.ParameterDescription(
              name: 'newMemberAccountId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<_ieyt77v6.GroupMemberRole>(),
              nullable: false,
            ),
            'memberKeys': _is.ParameterDescription(
              name: 'memberKeys',
              type: _is.getType<_ijl9ntd6.PublicKeyDuo>(),
              nullable: false,
            ),
            'encryptedDataKey': _is.ParameterDescription(
              name: 'encryptedDataKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'encryptedMemberKey': _is.ParameterDescription(
              name: 'encryptedMemberKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'encryptedMemberKeyAttestation': _is.ParameterDescription(
              name: 'encryptedMemberKeyAttestation',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'groupUltimateSignature': _is.ParameterDescription(
              name: 'groupUltimateSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).addGroupMember(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                groupId: params['groupId'],
                newMemberAccountId: params['newMemberAccountId'],
                role: params['role'],
                memberKeys: params['memberKeys'],
                encryptedDataKey: params['encryptedDataKey'],
                encryptedMemberKey: params['encryptedMemberKey'],
                encryptedMemberKeyAttestation:
                    params['encryptedMemberKeyAttestation'],
                callerMemberSigningPublicKeyHex:
                    params['callerMemberSigningPublicKeyHex'],
                memberAuthSignature: params['memberAuthSignature'],
                groupUltimateSignature: params['groupUltimateSignature'],
              ),
        ),
        'removeGroupMember': _is.MethodConnector(
          name: 'removeGroupMember',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'groupUltimateSignature': _is.ParameterDescription(
              name: 'groupUltimateSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).removeGroupMember(
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
        'changeGroupMemberRole': _is.MethodConnector(
          name: 'changeGroupMemberRole',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'newRole': _is.ParameterDescription(
              name: 'newRole',
              type: _is.getType<_ieyt77v6.GroupMemberRole>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'groupUltimateSignature': _is.ParameterDescription(
              name: 'groupUltimateSignature',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint)
                  .changeGroupMemberRole(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    memberId: params['memberId'],
                    newRole: params['newRole'],
                    callerMemberSigningPublicKeyHex:
                        params['callerMemberSigningPublicKeyHex'],
                    memberAuthSignature: params['memberAuthSignature'],
                    groupUltimateSignature: params['groupUltimateSignature'],
                  ),
        ),
        'getGroup': _is.MethodConnector(
          name: 'getGroup',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupId': _is.ParameterDescription(
              name: 'groupId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).getGroup(
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
        'listGroupMembers': _is.MethodConnector(
          name: 'listGroupMembers',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupId': _is.ParameterDescription(
              name: 'groupId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'callerMemberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerMemberSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).listGroupMembers(
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
        'leaveGroup': _is.MethodConnector(
          name: 'leaveGroup',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'memberSigningPublicKeyHex': _is.ParameterDescription(
              name: 'memberSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).leaveGroup(
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
        'grantMemberDevice': _is.MethodConnector(
          name: 'grantMemberDevice',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'grants': _is.ParameterDescription(
              name: 'grants',
              type: _is.getType<List<_ij4d8jf2.MemberDeviceGrant>>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).grantMemberDevice(
                session,
                challenge: params['challenge'],
                proofOfWork: params['proofOfWork'],
                signature: params['signature'],
                callerDeviceSigningPublicKeyHex:
                    params['callerDeviceSigningPublicKeyHex'],
                grants: params['grants'],
              ),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).getChallenge(
                session,
              ),
        ),
        'verifySignedPow': _is.MethodConnector(
          name: 'verifySignedPow',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'publicKeyHex': _is.ParameterDescription(
              name: 'publicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).verifySignedPow(
                session,
                params['challenge'],
                params['proofOfWork'],
                params['publicKeyHex'],
                params['signature'],
                params['payload'],
              ),
        ),
        'verifyHashcash': _is.MethodConnector(
          name: 'verifyHashcash',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['group'] as _iknqvl2r.GroupEndpoint).verifyHashcash(
                session,
                params['challenge'],
                params['proofOfWork'],
              ),
        ),
        'monitorGroupMembership': _is.MethodStreamConnector(
          name: 'monitorGroupMembership',
          params: {
            'challenge': _is.ParameterDescription(
              name: 'challenge',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'proofOfWork': _is.ParameterDescription(
              name: 'proofOfWork',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'signature': _is.ParameterDescription(
              name: 'signature',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'callerDeviceSigningPublicKeyHex': _is.ParameterDescription(
              name: 'callerDeviceSigningPublicKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'groupId': _is.ParameterDescription(
              name: 'groupId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'memberSigningKeyHex': _is.ParameterDescription(
              name: 'memberSigningKeyHex',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'memberAuthSignature': _is.ParameterDescription(
              name: 'memberAuthSignature',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['group'] as _iknqvl2r.GroupEndpoint)
                  .monitorGroupMembership(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    callerDeviceSigningPublicKeyHex:
                        params['callerDeviceSigningPublicKeyHex'],
                    groupId: params['groupId'],
                    memberSigningKeyHex: params['memberSigningKeyHex'],
                    memberAuthSignature: params['memberAuthSignature'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
