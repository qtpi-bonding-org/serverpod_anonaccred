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
import '../endpoints/commerce_endpoint.dart' as _i2;
import '../endpoints/iap_endpoint.dart' as _i3;
import 'package:anonaccount_server/anonaccount_server.dart' as _i4;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i5;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i6;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'commerce': _i2.CommerceEndpoint()
        ..initialize(
          server,
          'commerce',
          'anonaccred',
        ),
      'iAP': _i3.IAPEndpoint()
        ..initialize(
          server,
          'iAP',
          'anonaccred',
        ),
    };
    connectors['commerce'] = _i1.EndpointConnector(
      name: 'commerce',
      endpoint: endpoints['commerce']!,
      methodConnectors: {
        'getEntitlements': _i1.MethodConnector(
          name: 'getEntitlements',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getEntitlements(session),
        ),
        'getEntitlementBalance': _i1.MethodConnector(
          name: 'getEntitlementBalance',
          params: {
            'tag': _i1.ParameterDescription(
              name: 'tag',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getEntitlementBalance(
                    session,
                    params['tag'],
                  ),
        ),
        'consumeEntitlement': _i1.MethodConnector(
          name: 'consumeEntitlement',
          params: {
            'tag': _i1.ParameterDescription(
              name: 'tag',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'quantity': _i1.ParameterDescription(
              name: 'quantity',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .consumeEntitlement(
                    session,
                    params['tag'],
                    params['quantity'],
                  ),
        ),
      },
    );
    connectors['iAP'] = _i1.EndpointConnector(
      name: 'iAP',
      endpoint: endpoints['iAP']!,
      methodConnectors: {
        'validateAppleTransaction': _i1.MethodConnector(
          name: 'validateAppleTransaction',
          params: {
            'transactionId': _i1.ParameterDescription(
              name: 'transactionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'internalTransactionId': _i1.ParameterDescription(
              name: 'internalTransactionId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['iAP'] as _i3.IAPEndpoint)
                  .validateAppleTransaction(
                    session,
                    params['transactionId'],
                    params['productId'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
        'validateGooglePurchase': _i1.MethodConnector(
          name: 'validateGooglePurchase',
          params: {
            'packageName': _i1.ParameterDescription(
              name: 'packageName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'purchaseToken': _i1.ParameterDescription(
              name: 'purchaseToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'internalTransactionId': _i1.ParameterDescription(
              name: 'internalTransactionId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['iAP'] as _i3.IAPEndpoint).validateGooglePurchase(
                    session,
                    params['packageName'],
                    params['productId'],
                    params['purchaseToken'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
      },
    );
    modules['anonaccount'] = _i4.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i5.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i6.Endpoints()
      ..initializeEndpoints(server);
  }
}
