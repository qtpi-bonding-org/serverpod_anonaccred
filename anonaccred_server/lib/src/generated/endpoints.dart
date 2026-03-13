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
import '../endpoints/iap_webhook_endpoint.dart' as _i4;
import '../endpoints/module_endpoint.dart' as _i5;
import '../endpoints/payment_endpoint.dart' as _i6;
import '../endpoints/x402_endpoint.dart' as _i7;
import 'package:anonaccred_server/src/generated/payment_rail.dart' as _i8;
import 'package:anonaccount_server/anonaccount_server.dart' as _i9;

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
      'iAPWebhook': _i4.IAPWebhookEndpoint()
        ..initialize(
          server,
          'iAPWebhook',
          'anonaccred',
        ),
      'module': _i5.ModuleEndpoint()
        ..initialize(
          server,
          'module',
          'anonaccred',
        ),
      'payment': _i6.PaymentEndpoint()
        ..initialize(
          server,
          'payment',
          'anonaccred',
        ),
      'x402': _i7.X402Endpoint()
        ..initialize(
          server,
          'x402',
          'anonaccred',
        ),
    };
    connectors['commerce'] = _i1.EndpointConnector(
      name: 'commerce',
      endpoint: endpoints['commerce']!,
      methodConnectors: {
        'registerProducts': _i1.MethodConnector(
          name: 'registerProducts',
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
            'products': _i1.ParameterDescription(
              name: 'products',
              type: _i1.getType<Map<String, double>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .registerProducts(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['products'],
                  ),
        ),
        'initiatePayment': _i1.MethodConnector(
          name: 'initiatePayment',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'rail': _i1.ParameterDescription(
              name: 'rail',
              type: _i1.getType<_i8.PaymentRail>(),
              nullable: false,
            ),
            'storeProductId': _i1.ParameterDescription(
              name: 'storeProductId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'clientReference': _i1.ParameterDescription(
              name: 'clientReference',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'customPrice': _i1.ParameterDescription(
              name: 'customPrice',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .initiatePayment(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['rail'],
                    params['storeProductId'],
                    clientReference: params['clientReference'],
                    customPrice: params['customPrice'],
                  ),
        ),
        'getActiveStoreProductIds': _i1.MethodConnector(
          name: 'getActiveStoreProductIds',
          params: {
            'railName': _i1.ParameterDescription(
              name: 'railName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getActiveStoreProductIds(
                    session,
                    params['railName'],
                  ),
        ),
        'getProductCatalog': _i1.MethodConnector(
          name: 'getProductCatalog',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getProductCatalog(session),
        ),
        'getEntitlements': _i1.MethodConnector(
          name: 'getEntitlements',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getEntitlements(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                  ),
        ),
        'getEntitlementBalance': _i1.MethodConnector(
          name: 'getEntitlementBalance',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
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
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['tag'],
                  ),
        ),
        'consumeEntitlement': _i1.MethodConnector(
          name: 'consumeEntitlement',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
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
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['tag'],
                    params['quantity'],
                  ),
        ),
        'getProductCatalogWithX402': _i1.MethodConnector(
          name: 'getProductCatalogWithX402',
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
            'headers': _i1.ParameterDescription(
              name: 'headers',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getProductCatalogWithX402(
                    session,
                    params['publicKey'],
                    params['signature'],
                    headers: params['headers'],
                  ),
        ),
        'getEntitlementBalanceWithX402': _i1.MethodConnector(
          name: 'getEntitlementBalanceWithX402',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'tag': _i1.ParameterDescription(
              name: 'tag',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'headers': _i1.ParameterDescription(
              name: 'headers',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i2.CommerceEndpoint)
                  .getEntitlementBalanceWithX402(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['tag'],
                    headers: params['headers'],
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
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
                    params['publicKey'],
                    params['signature'],
                    params['transactionId'],
                    params['productId'],
                    params['accountId'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
        'validateGooglePurchase': _i1.MethodConnector(
          name: 'validateGooglePurchase',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
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
                    params['publicKey'],
                    params['signature'],
                    params['packageName'],
                    params['productId'],
                    params['purchaseToken'],
                    params['accountId'],
                    internalTransactionId: params['internalTransactionId'],
                  ),
        ),
      },
    );
    connectors['iAPWebhook'] = _i1.EndpointConnector(
      name: 'iAPWebhook',
      endpoint: endpoints['iAPWebhook']!,
      methodConnectors: {
        'handleAppleWebhook': _i1.MethodConnector(
          name: 'handleAppleWebhook',
          params: {
            'webhookDataJson': _i1.ParameterDescription(
              name: 'webhookDataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['iAPWebhook'] as _i4.IAPWebhookEndpoint)
                  .handleAppleWebhook(
                    session,
                    params['webhookDataJson'],
                  ),
        ),
        'handleGoogleWebhook': _i1.MethodConnector(
          name: 'handleGoogleWebhook',
          params: {
            'webhookDataJson': _i1.ParameterDescription(
              name: 'webhookDataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['iAPWebhook'] as _i4.IAPWebhookEndpoint)
                  .handleGoogleWebhook(
                    session,
                    params['webhookDataJson'],
                  ),
        ),
      },
    );
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
              ) async => (endpoints['module'] as _i5.ModuleEndpoint).hello(
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
                  (endpoints['module'] as _i5.ModuleEndpoint).authenticateUser(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['challenge'],
                  ),
        ),
        'processPayment': _i1.MethodConnector(
          name: 'processPayment',
          params: {
            'internalTransactionId': _i1.ParameterDescription(
              name: 'internalTransactionId',
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
                  (endpoints['module'] as _i5.ModuleEndpoint).processPayment(
                    session,
                    params['internalTransactionId'],
                    params['paymentRail'],
                    params['amount'],
                  ),
        ),
        'manageEntitlements': _i1.MethodConnector(
          name: 'manageEntitlements',
          params: {
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'tag': _i1.ParameterDescription(
              name: 'tag',
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
              type: _i1.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['module'] as _i5.ModuleEndpoint)
                  .manageEntitlements(
                    session,
                    params['accountId'],
                    params['tag'],
                    params['operation'],
                    params['quantity'],
                  ),
        ),
      },
    );
    connectors['payment'] = _i1.EndpointConnector(
      name: 'payment',
      endpoint: endpoints['payment']!,
      methodConnectors: {
        'checkPaymentStatus': _i1.MethodConnector(
          name: 'checkPaymentStatus',
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
            'internalTransactionId': _i1.ParameterDescription(
              name: 'internalTransactionId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .checkPaymentStatus(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['internalTransactionId'],
                  ),
        ),
        'processMoneroWebhook': _i1.MethodConnector(
          name: 'processMoneroWebhook',
          params: {
            'webhookDataJson': _i1.ParameterDescription(
              name: 'webhookDataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .processMoneroWebhook(
                    session,
                    params['webhookDataJson'],
                  ),
        ),
        'processX402Webhook': _i1.MethodConnector(
          name: 'processX402Webhook',
          params: {
            'webhookDataJson': _i1.ParameterDescription(
              name: 'webhookDataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .processX402Webhook(
                    session,
                    params['webhookDataJson'],
                  ),
        ),
      },
    );
    connectors['x402'] = _i1.EndpointConnector(
      name: 'x402',
      endpoint: endpoints['x402']!,
      methodConnectors: {
        'requestPaidResource': _i1.MethodConnector(
          name: 'requestPaidResource',
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
            'resourceId': _i1.ParameterDescription(
              name: 'resourceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'headers': _i1.ParameterDescription(
              name: 'headers',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['x402'] as _i7.X402Endpoint).requestPaidResource(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['resourceId'],
                    params['accountId'],
                    headers: params['headers'],
                  ),
        ),
        'requestConsumableAccess': _i1.MethodConnector(
          name: 'requestConsumableAccess',
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'headers': _i1.ParameterDescription(
              name: 'headers',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['x402'] as _i7.X402Endpoint)
                  .requestConsumableAccess(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['tag'],
                    params['quantity'],
                    params['accountId'],
                    headers: params['headers'],
                  ),
        ),
      },
    );
    modules['anonaccount'] = _i9.Endpoints()..initializeEndpoints(server);
  }
}
