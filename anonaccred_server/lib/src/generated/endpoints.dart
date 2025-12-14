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
import '../endpoints/commerce_endpoint.dart' as _i3;
import '../endpoints/device_endpoint.dart' as _i4;
import '../endpoints/module_endpoint.dart' as _i5;
import '../endpoints/payment_endpoint.dart' as _i6;
import '../endpoints/x402_endpoint.dart' as _i7;
import 'package:anonaccred_server/src/generated/payment_rail.dart' as _i8;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'account': _i2.AccountEndpoint()
        ..initialize(
          server,
          'account',
          'anonaccred',
        ),
      'commerce': _i3.CommerceEndpoint()
        ..initialize(
          server,
          'commerce',
          'anonaccred',
        ),
      'device': _i4.DeviceEndpoint()
        ..initialize(
          server,
          'device',
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
    connectors['account'] = _i1.EndpointConnector(
      name: 'account',
      endpoint: endpoints['account']!,
      methodConnectors: {
        'createAccount': _i1.MethodConnector(
          name: 'createAccount',
          params: {
            'publicMasterKey': _i1.ParameterDescription(
              name: 'publicMasterKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'encryptedDataKey': _i1.ParameterDescription(
              name: 'encryptedDataKey',
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
                    params['publicMasterKey'],
                    params['encryptedDataKey'],
                  ),
        ),
        'getAccountById': _i1.MethodConnector(
          name: 'getAccountById',
          params: {
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
              ) async =>
                  (endpoints['account'] as _i2.AccountEndpoint).getAccountById(
                    session,
                    params['accountId'],
                  ),
        ),
        'getAccountByPublicKey': _i1.MethodConnector(
          name: 'getAccountByPublicKey',
          params: {
            'publicMasterKey': _i1.ParameterDescription(
              name: 'publicMasterKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['account'] as _i2.AccountEndpoint)
                  .getAccountByPublicKey(
                    session,
                    params['publicMasterKey'],
                  ),
        ),
      },
    );
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
              ) async => (endpoints['commerce'] as _i3.CommerceEndpoint)
                  .registerProducts(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['products'],
                  ),
        ),
        'getProductCatalog': _i1.MethodConnector(
          name: 'getProductCatalog',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['commerce'] as _i3.CommerceEndpoint)
                  .getProductCatalog(session),
        ),
        'createOrder': _i1.MethodConnector(
          name: 'createOrder',
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
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<Map<String, double>>(),
              nullable: false,
            ),
            'paymentRail': _i1.ParameterDescription(
              name: 'paymentRail',
              type: _i1.getType<_i8.PaymentRail>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['commerce'] as _i3.CommerceEndpoint).createOrder(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['items'],
                    params['paymentRail'],
                  ),
        ),
        'getInventory': _i1.MethodConnector(
          name: 'getInventory',
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
              ) async =>
                  (endpoints['commerce'] as _i3.CommerceEndpoint).getInventory(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                  ),
        ),
        'getBalance': _i1.MethodConnector(
          name: 'getBalance',
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
            'consumableType': _i1.ParameterDescription(
              name: 'consumableType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['commerce'] as _i3.CommerceEndpoint).getBalance(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['consumableType'],
                  ),
        ),
        'consumeInventory': _i1.MethodConnector(
          name: 'consumeInventory',
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
            'consumableType': _i1.ParameterDescription(
              name: 'consumableType',
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
              ) async => (endpoints['commerce'] as _i3.CommerceEndpoint)
                  .consumeInventory(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['consumableType'],
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
              ) async => (endpoints['commerce'] as _i3.CommerceEndpoint)
                  .getProductCatalogWithX402(
                    session,
                    params['publicKey'],
                    params['signature'],
                    headers: params['headers'],
                  ),
        ),
        'getBalanceWithX402': _i1.MethodConnector(
          name: 'getBalanceWithX402',
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
            'consumableType': _i1.ParameterDescription(
              name: 'consumableType',
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
              ) async => (endpoints['commerce'] as _i3.CommerceEndpoint)
                  .getBalanceWithX402(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['accountId'],
                    params['consumableType'],
                    headers: params['headers'],
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
            'accountId': _i1.ParameterDescription(
              name: 'accountId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'publicSubKey': _i1.ParameterDescription(
              name: 'publicSubKey',
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
                    params['accountId'],
                    params['publicSubKey'],
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
              ) async => (endpoints['device'] as _i4.DeviceEndpoint)
                  .authenticateDevice(
                    session,
                    params['challenge'],
                    params['signature'],
                  ),
        ),
        'generateAuthChallenge': _i1.MethodConnector(
          name: 'generateAuthChallenge',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i4.DeviceEndpoint)
                  .generateAuthChallenge(session),
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
                  (endpoints['device'] as _i4.DeviceEndpoint).revokeDevice(
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
              ) async => (endpoints['device'] as _i4.DeviceEndpoint)
                  .listDevices(session),
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
                  (endpoints['module'] as _i5.ModuleEndpoint).processPayment(
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
                  (endpoints['module'] as _i5.ModuleEndpoint).manageInventory(
                    session,
                    params['accountId'],
                    params['consumableType'],
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
            'orderId': _i1.ParameterDescription(
              name: 'orderId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'railType': _i1.ParameterDescription(
              name: 'railType',
              type: _i1.getType<_i8.PaymentRail>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['payment'] as _i6.PaymentEndpoint).initiatePayment(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['orderId'],
                    params['railType'],
                  ),
        ),
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
            'orderId': _i1.ParameterDescription(
              name: 'orderId',
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
                    params['orderId'],
                  ),
        ),
        'processMoneroWebhook': _i1.MethodConnector(
          name: 'processMoneroWebhook',
          params: {
            'webhookData': _i1.ParameterDescription(
              name: 'webhookData',
              type: _i1.getType<Map<String, dynamic>>(),
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
                    params['webhookData'],
                  ),
        ),
        'processX402Webhook': _i1.MethodConnector(
          name: 'processX402Webhook',
          params: {
            'webhookData': _i1.ParameterDescription(
              name: 'webhookData',
              type: _i1.getType<Map<String, dynamic>>(),
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
                    params['webhookData'],
                  ),
        ),
        'processAppleIAPWebhook': _i1.MethodConnector(
          name: 'processAppleIAPWebhook',
          params: {
            'webhookData': _i1.ParameterDescription(
              name: 'webhookData',
              type: _i1.getType<Map<String, dynamic>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .processAppleIAPWebhook(
                    session,
                    params['webhookData'],
                  ),
        ),
        'processGoogleIAPWebhook': _i1.MethodConnector(
          name: 'processGoogleIAPWebhook',
          params: {
            'webhookData': _i1.ParameterDescription(
              name: 'webhookData',
              type: _i1.getType<Map<String, dynamic>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .processGoogleIAPWebhook(
                    session,
                    params['webhookData'],
                  ),
        ),
        'requestPaymentStatusWithX402': _i1.MethodConnector(
          name: 'requestPaymentStatusWithX402',
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
            'orderId': _i1.ParameterDescription(
              name: 'orderId',
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
              ) async => (endpoints['payment'] as _i6.PaymentEndpoint)
                  .requestPaymentStatusWithX402(
                    session,
                    params['publicKey'],
                    params['signature'],
                    params['orderId'],
                    headers: params['headers'],
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
            'consumableType': _i1.ParameterDescription(
              name: 'consumableType',
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
                    params['consumableType'],
                    params['quantity'],
                    params['accountId'],
                    headers: params['headers'],
                  ),
        ),
      },
    );
  }
}
