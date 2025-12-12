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
import '../endpoints/module_endpoint.dart' as _i2;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'module': _i2.ModuleEndpoint()
        ..initialize(
          server,
          'module',
          'anonaccred',
        ),
    };
    connectors['module'] = _i1.EndpointConnector(
      name: 'module',
      endpoint: endpoints['module']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['module'] as _i2.ModuleEndpoint).hello(
                session,
                params['name'],
              ),
        ),
        'authenticateUser': _i1.MethodConnector(
          name: 'authenticateUser',
          params: {
            'publicKey': _i1.ParameterDescription(
              name: 'publicKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'challenge': _i1.ParameterDescription(
              name: 'challenge',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['module'] as _i2.ModuleEndpoint).authenticateUser(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['challenge'],
                  ),
        ),
        'processPayment': _i1.MethodConnector(
          name: 'processPayment',
          params: {
            'orderId': _i1.ParameterDescription(
              name: 'orderId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'paymentRail': _i1.ParameterDescription(
              name: 'paymentRail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amount': _i1.ParameterDescription(
              name: 'amount',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['module'] as _i2.ModuleEndpoint).processPayment(
                    session,
                    params['orderId'],
                    params['paymentRail'],
                    params['amount'],
                  ),
        ),
        'manageInventory': _i1.MethodConnector(
          name: 'manageInventory',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'consumableType': _i1.ParameterDescription(
              name: 'consumableType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'operation': _i1.ParameterDescription(
              name: 'operation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'quantity': _i1.ParameterDescription(
              name: 'quantity',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['module'] as _i2.ModuleEndpoint).manageInventory(
                    session,
                    params['accountId'],
                    params['consumableType'],
                    params['operation'],
                    params['quantity'],
                  ),
        ),
      },
    );
  }
}
