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
import '../endpoints/device_endpoint.dart' as _i3;
import '../endpoints/device_management_endpoint.dart' as _i4;

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
      'device': _i3.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          'anonaccount',
        ),
      'deviceManagement': _i4.DeviceManagementEndpoint()
        ..initialize(
          server,
          'deviceManagement',
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
                  ),
        ),
        'getAccountForRecovery': _i1.MethodConnector(
          name: 'getAccountForRecovery',
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
            'ultimatePublicKey': _i1.ParameterDescription(
              name: 'ultimatePublicKey',
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
              ) async => (endpoints['account'] as _i2.AccountEndpoint)
                  .getAccountForRecovery(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    ultimatePublicKey: params['ultimatePublicKey'],
                    signature: params['signature'],
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
        'verifyPow': _i1.MethodConnector(
          name: 'verifyPow',
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
                  (endpoints['account'] as _i2.AccountEndpoint).verifyPow(
                    session,
                    params['challenge'],
                    params['proofOfWork'],
                    params['publicKeyHex'],
                    params['signature'],
                    params['payload'],
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
                  (endpoints['device'] as _i3.DeviceEndpoint).registerDevice(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    ultimateSigningPublicKeyHex:
                        params['ultimateSigningPublicKeyHex'],
                    deviceSigningPublicKeyHex:
                        params['deviceSigningPublicKeyHex'],
                    encryptedDataKey: params['encryptedDataKey'],
                    label: params['label'],
                  ),
        ),
        'generateAuthChallenge': _i1.MethodConnector(
          name: 'generateAuthChallenge',
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
            'devicePublicKey': _i1.ParameterDescription(
              name: 'devicePublicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i3.DeviceEndpoint)
                  .generateAuthChallenge(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    devicePublicKey: params['devicePublicKey'],
                  ),
        ),
        'getDeviceBySigningKey': _i1.MethodConnector(
          name: 'getDeviceBySigningKey',
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
            'signingPublicKeyHex': _i1.ParameterDescription(
              name: 'signingPublicKeyHex',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i3.DeviceEndpoint)
                  .getDeviceBySigningKey(
                    session,
                    challenge: params['challenge'],
                    proofOfWork: params['proofOfWork'],
                    signature: params['signature'],
                    signingPublicKeyHex: params['signingPublicKeyHex'],
                  ),
        ),
        'getChallenge': _i1.MethodConnector(
          name: 'getChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i3.DeviceEndpoint)
                  .getChallenge(session),
        ),
        'verifyPow': _i1.MethodConnector(
          name: 'verifyPow',
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
              ) async => (endpoints['device'] as _i3.DeviceEndpoint).verifyPow(
                session,
                params['challenge'],
                params['proofOfWork'],
                params['publicKeyHex'],
                params['signature'],
                params['payload'],
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
              ) => (endpoints['device'] as _i3.DeviceEndpoint)
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
        'authenticateDevice': _i1.MethodConnector(
          name: 'authenticateDevice',
          params: {
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
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
                          as _i4.DeviceManagementEndpoint)
                      .authenticateDevice(
                        session,
                        params['challenge'],
                        params['signature'],
                      ),
        ),
        'revokeDevice': _i1.MethodConnector(
          name: 'revokeDevice',
          params: {
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i4.DeviceManagementEndpoint)
                      .revokeDevice(
                        session,
                        params['deviceId'],
                      ),
        ),
        'listDevices': _i1.MethodConnector(
          name: 'listDevices',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['deviceManagement']
                          as _i4.DeviceManagementEndpoint)
                      .listDevices(session),
        ),
        'registerDeviceForAccount': _i1.MethodConnector(
          name: 'registerDeviceForAccount',
          params: {
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
                          as _i4.DeviceManagementEndpoint)
                      .registerDeviceForAccount(
                        session,
                        params['newDeviceSigningPublicKeyHex'],
                        params['newDeviceEncryptedDataKey'],
                        params['label'],
                      ),
        ),
      },
    );
  }
}
