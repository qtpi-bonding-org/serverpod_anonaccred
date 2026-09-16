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
import 'package:anonaccount_server/anonaccount_server.dart' as _i9eoghi2;
import 'package:anonaccred_server/src/generated/future_calls.dart' as _ikqnf7jm;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../endpoints/commerce_endpoint.dart' as _ix7awdju;
import '../endpoints/group_commerce_endpoint.dart' as _i6x3250r;
import '../endpoints/iap_endpoint.dart' as _i7bz9bfc;
import '../endpoints/polar_endpoint.dart' as _ivhxvr71;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'commerce': _ix7awdju.CommerceEndpoint()
        ..initialize(server, 'commerce', 'anonaccred'),
      'groupCommerce': _i6x3250r.GroupCommerceEndpoint()
        ..initialize(server, 'groupCommerce', 'anonaccred'),
      'iAP': _i7bz9bfc.IAPEndpoint()..initialize(server, 'iAP', 'anonaccred'),
      'polar': _ivhxvr71.PolarEndpoint()
        ..initialize(server, 'polar', 'anonaccred'),
    };
    connectors['commerce'] = _is.EndpointConnector(
      name: 'commerce',
      endpoint: endpoints['commerce']!,
      methodConnectors: {
        'getEntitlements': _is.MethodConnector(
          name: 'getEntitlements',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .getEntitlements(session),
        ),
        'getEntitlementBalance': _is.MethodConnector(
          name: 'getEntitlementBalance',
          params: {
            'tag': _is.ParameterDescription(
              name: 'tag',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .getEntitlementBalance(session, params['tag']),
        ),
        'consumeEntitlement': _is.MethodConnector(
          name: 'consumeEntitlement',
          params: {
            'tag': _is.ParameterDescription(
              name: 'tag',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'quantity': _is.ParameterDescription(
              name: 'quantity',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['commerce'] as _ix7awdju.CommerceEndpoint)
                  .consumeEntitlement(
                    session,
                    params['tag'],
                    params['quantity'],
                  ),
        ),
      },
    );
    connectors['groupCommerce'] = _is.EndpointConnector(
      name: 'groupCommerce',
      endpoint: endpoints['groupCommerce']!,
      methodConnectors: {
        'getGroupEntitlements': _is.MethodConnector(
          name: 'getGroupEntitlements',
          params: {
            'shareGroupUuid': _is.ParameterDescription(
              name: 'shareGroupUuid',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['groupCommerce'] as _i6x3250r.GroupCommerceEndpoint)
                  .getGroupEntitlements(session, params['shareGroupUuid']),
        ),
        'getGroupEntitlementBalance': _is.MethodConnector(
          name: 'getGroupEntitlementBalance',
          params: {
            'shareGroupUuid': _is.ParameterDescription(
              name: 'shareGroupUuid',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'tag': _is.ParameterDescription(
              name: 'tag',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['groupCommerce'] as _i6x3250r.GroupCommerceEndpoint)
                  .getGroupEntitlementBalance(
                    session,
                    params['shareGroupUuid'],
                    params['tag'],
                  ),
        ),
        'consumeGroupEntitlement': _is.MethodConnector(
          name: 'consumeGroupEntitlement',
          params: {
            'shareGroupUuid': _is.ParameterDescription(
              name: 'shareGroupUuid',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'tag': _is.ParameterDescription(
              name: 'tag',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'quantity': _is.ParameterDescription(
              name: 'quantity',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['groupCommerce'] as _i6x3250r.GroupCommerceEndpoint)
                  .consumeGroupEntitlement(
                    session,
                    params['shareGroupUuid'],
                    params['tag'],
                    params['quantity'],
                  ),
        ),
      },
    );
    connectors['iAP'] = _is.EndpointConnector(
      name: 'iAP',
      endpoint: endpoints['iAP']!,
      methodConnectors: {
        'validateAppleTransaction': _is.MethodConnector(
          name: 'validateAppleTransaction',
          params: {
            'transactionId': _is.ParameterDescription(
              name: 'transactionId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'productId': _is.ParameterDescription(
              name: 'productId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'internalTransactionId': _is.ParameterDescription(
              name: 'internalTransactionId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['iAP'] as _i7bz9bfc.IAPEndpoint)
                  .validateAppleTransaction(
                    session,
                    params['transactionId'],
                    params['productId'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
        'validateGooglePurchase': _is.MethodConnector(
          name: 'validateGooglePurchase',
          params: {
            'packageName': _is.ParameterDescription(
              name: 'packageName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'productId': _is.ParameterDescription(
              name: 'productId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'purchaseToken': _is.ParameterDescription(
              name: 'purchaseToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'internalTransactionId': _is.ParameterDescription(
              name: 'internalTransactionId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['iAP'] as _i7bz9bfc.IAPEndpoint)
                  .validateGooglePurchase(
                    session,
                    params['packageName'],
                    params['productId'],
                    params['purchaseToken'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
      },
    );
    connectors['polar'] = _is.EndpointConnector(
      name: 'polar',
      endpoint: endpoints['polar']!,
      methodConnectors: {
        'redeemLicenseKey': _is.MethodConnector(
          name: 'redeemLicenseKey',
          params: {
            'licenseKey': _is.ParameterDescription(
              name: 'licenseKey',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'shareGroupUuid': _is.ParameterDescription(
              name: 'shareGroupUuid',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
            'internalTransactionId': _is.ParameterDescription(
              name: 'internalTransactionId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['polar'] as _ivhxvr71.PolarEndpoint).redeemLicenseKey(
                session,
                params['licenseKey'],
                shareGroupUuid: params['shareGroupUuid'],
                internalTransactionId: params['internalTransactionId'],
              ),
        ),
      },
    );
    modules['anonaccount'] = _i9eoghi2.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _ikqnf7jm.FutureCalls();
  }
}
