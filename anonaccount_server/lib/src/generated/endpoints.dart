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
import '../endpoints/device_endpoint.dart' as _i2;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'device': _i2.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          'anonaccount',
        ),
    };
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'registerDevice': _i1.MethodConnector(
          name: 'registerDevice',
          params: {
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
                  (endpoints['device'] as _i2.DeviceEndpoint).registerDevice(
                    session,
                    params['ultimateSigningPublicKeyHex'],
                    params['deviceSigningPublicKeyHex'],
                    params['encryptedDataKey'],
                    params['label'],
                  ),
        ),
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
              ) async => (endpoints['device'] as _i2.DeviceEndpoint)
                  .authenticateDevice(
                    session,
                    params['challenge'],
                    params['signature'],
                  ),
        ),
        'generateAuthChallenge': _i1.MethodConnector(
          name: 'generateAuthChallenge',
          params: {
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
              ) async => (endpoints['device'] as _i2.DeviceEndpoint)
                  .generateAuthChallenge(
                    session,
                    params['devicePublicKey'],
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
                  (endpoints['device'] as _i2.DeviceEndpoint).revokeDevice(
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
              ) async => (endpoints['device'] as _i2.DeviceEndpoint)
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
              ) async => (endpoints['device'] as _i2.DeviceEndpoint)
                  .registerDeviceForAccount(
                    session,
                    params['newDeviceSigningPublicKeyHex'],
                    params['newDeviceEncryptedDataKey'],
                    params['label'],
                  ),
        ),
        'getDeviceBySigningKey': _i1.MethodConnector(
          name: 'getDeviceBySigningKey',
          params: {
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
              ) async => (endpoints['device'] as _i2.DeviceEndpoint)
                  .getDeviceBySigningKey(
                    session,
                    params['signingPublicKeyHex'],
                  ),
        ),
        'monitorRegistration': _i1.MethodStreamConnector(
          name: 'monitorRegistration',
          params: {
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
              ) => (endpoints['device'] as _i2.DeviceEndpoint)
                  .monitorRegistration(
                    session,
                    params['signingKeyHex'],
                  ),
        ),
      },
    );
  }
}
