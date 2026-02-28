/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async' as i3;

import 'package:anonaccred_server/src/generated/account.dart' as i4;
import 'package:anonaccred_server/src/generated/account_device.dart' as i9;
import 'package:anonaccred_server/src/generated/authentication_result.dart'
    as i10;
import 'package:anonaccred_server/src/generated/consume_result.dart' as i8;
import 'package:anonaccred_server/src/generated/device_pairing_event.dart'
    as i11;
import 'package:anonaccred_server/src/generated/device_pairing_info.dart'
    as i12;
import 'package:anonaccred_server/src/generated/endpoints.dart';
import 'package:anonaccred_server/src/generated/inventory.dart' as i7;
import 'package:anonaccred_server/src/generated/payment_rail.dart' as i6;
import 'package:anonaccred_server/src/generated/payment_request.dart' as i13;
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/generated/transaction.dart' as i5;
import 'package:serverpod/serverpod.dart' as i2;
import 'package:serverpod_test/serverpod_test.dart' as i1;

export 'package:serverpod_test/serverpod_test_public_exports.dart';

/// Creates a new test group that takes a callback that can be used to write tests.
/// The callback has two parameters: `sessionBuilder` and `endpoints`.
/// `sessionBuilder` is used to build a `Session` object that represents the server state during an endpoint call and is used to set up scenarios.
/// `endpoints` contains all your Serverpod endpoints and lets you call them:
/// ```dart
/// withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
///   test('when calling `hello` then should return greeting', () async {
///     final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
///     expect(greeting, 'Hello Michael');
///   });
/// });
/// ```
///
/// **Configuration options**
///
/// [applyMigrations] Whether pending migrations should be applied when starting Serverpod. Defaults to `true`
///
/// [enableSessionLogging] Whether session logging should be enabled. Defaults to `false`
///
/// [rollbackDatabase] Options for when to rollback the database during the test lifecycle.
/// By default `withServerpod` does all database operations inside a transaction that is rolled back after each `test` case.
/// Just like the following enum describes, the behavior of the automatic rollbacks can be configured:
/// ```dart
/// /// Options for when to rollback the database during the test lifecycle.
/// enum RollbackDatabase {
///   /// After each test. This is the default.
///   afterEach,
///
///   /// After all tests.
///   afterAll,
///
///   /// Disable rolling back the database.
///   disabled,
/// }
/// ```
///
/// [runMode] The run mode that Serverpod should be running in. Defaults to `test`.
///
/// [serverpodLoggingMode] The logging mode used when creating Serverpod. Defaults to `ServerpodLoggingMode.normal`
///
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 30)`.
///
/// [testServerOutputMode] Options for controlling test server output during test execution. Defaults to `TestServerOutputMode.normal`.
/// ```dart
/// /// Options for controlling test server output during test execution.
/// enum TestServerOutputMode {
///   /// Default mode - only stderr is printed (stdout suppressed).
///   /// This hides normal startup/shutdown logs while preserving error messages.
///   normal,
///
///   /// All logging - both stdout and stderr are printed.
///   /// Useful for debugging when you need to see all server output.
///   verbose,
///
///   /// No logging - both stdout and stderr are suppressed.
///   /// Completely silent mode, useful when you don't want any server output.
///   silent,
/// }
/// ```
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [i2.Serverpod] for more information.
@i1.isTestGroup
void withServerpod(
  String testGroupName,
  i1.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  bool? enableSessionLogging,
  i2.ExperimentalFeatures? experimentalFeatures,
  i1.RollbackDatabase? rollbackDatabase,
  String? runMode,
  i2.RuntimeParametersListBuilder? runtimeParametersBuilder,
  i2.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
  i1.TestServerOutputMode? testServerOutputMode,
}) {
  i1.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    i1.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      testServerOutputMode: testServerOutputMode,
      experimentalFeatures: experimentalFeatures,
      runtimeParametersBuilder: runtimeParametersBuilder,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
    maybeTestServerOutputMode: testServerOutputMode,
  )(testClosure);
}

class TestEndpoints {
  late final _AccountEndpoint account;

  late final _CommerceEndpoint commerce;

  late final _DeviceEndpoint device;

  late final _IAPEndpoint iAP;

  late final _IAPWebhookEndpoint iAPWebhook;

  late final _ModuleEndpoint module;

  late final _PaymentEndpoint payment;

  late final _X402Endpoint x402;
}

class _InternalTestEndpoints extends TestEndpoints
    implements i1.InternalTestEndpoints {
  @override
  void initialize(
    i2.SerializationManager serializationManager,
    i2.EndpointDispatch endpoints,
  ) {
    account = _AccountEndpoint(
      endpoints,
      serializationManager,
    );
    commerce = _CommerceEndpoint(
      endpoints,
      serializationManager,
    );
    device = _DeviceEndpoint(
      endpoints,
      serializationManager,
    );
    iAP = _IAPEndpoint(
      endpoints,
      serializationManager,
    );
    iAPWebhook = _IAPWebhookEndpoint(
      endpoints,
      serializationManager,
    );
    module = _ModuleEndpoint(
      endpoints,
      serializationManager,
    );
    payment = _PaymentEndpoint(
      endpoints,
      serializationManager,
    );
    x402 = _X402Endpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _AccountEndpoint {
  _AccountEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<i4.AnonAccount> createAccount(
    i1.TestSessionBuilder sessionBuilder,
    String ultimateSigningPublicKeyHex,
    String encryptedDataKey,
    String ultimatePublicKey,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'createAccount',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'createAccount',
          parameters: i1.testObjectToJson({
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
            'encryptedDataKey': encryptedDataKey,
            'ultimatePublicKey': ultimatePublicKey,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i4.AnonAccount>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i4.AnonAccount> getAccountById(
    i1.TestSessionBuilder sessionBuilder,
    int accountId,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'getAccountById',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'getAccountById',
          parameters: i1.testObjectToJson({'accountId': accountId}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i4.AnonAccount>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i4.AnonAccount?> getAccountByPublicKey(
    i1.TestSessionBuilder sessionBuilder,
    String ultimateSigningPublicKeyHex,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'getAccountByPublicKey',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'getAccountByPublicKey',
          parameters: i1.testObjectToJson({
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i4.AnonAccount?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i4.AnonAccount?> getAccountForRecovery(
    i1.TestSessionBuilder sessionBuilder,
    String ultimatePublicKey,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'getAccountForRecovery',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'getAccountForRecovery',
          parameters: i1.testObjectToJson({
            'ultimatePublicKey': ultimatePublicKey,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i4.AnonAccount?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _CommerceEndpoint {
  _CommerceEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<Map<String, double>> registerProducts(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    Map<String, double> products,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'registerProducts',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'registerProducts',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'products': products,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, double>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, double>> getProductCatalog(
    i1.TestSessionBuilder sessionBuilder,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getProductCatalog',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getProductCatalog',
          parameters: i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, double>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i5.TransactionPayment> createOrder(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    int accountId,
    Map<String, double> items,
    i6.PaymentRail paymentRail,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'createOrder',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'createOrder',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'accountId': accountId,
            'items': items,
            'paymentRail': paymentRail,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i5.TransactionPayment>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<List<i7.AccountInventory>> getInventory(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    int accountId,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getInventory',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getInventory',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'accountId': accountId,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<List<i7.AccountInventory>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<double> getBalance(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getBalance',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getBalance',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'accountId': accountId,
            'consumableType': consumableType,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<double>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i8.ConsumeResult> consumeInventory(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    int accountId,
    String consumableType,
    double quantity,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'consumeInventory',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'consumeInventory',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'accountId': accountId,
            'consumableType': consumableType,
            'quantity': quantity,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i8.ConsumeResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> getProductCatalogWithX402(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature, {
    Map<String, String>? headers,
  }) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getProductCatalogWithX402',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getProductCatalogWithX402',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'headers': headers,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> getBalanceWithX402(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    int accountId,
    String consumableType, {
    Map<String, String>? headers,
  }) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getBalanceWithX402',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getBalanceWithX402',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'accountId': accountId,
            'consumableType': consumableType,
            'headers': headers,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _DeviceEndpoint {
  _DeviceEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<i9.AccountDevice> registerDevice(
    i1.TestSessionBuilder sessionBuilder,
    int accountId,
    String deviceSigningPublicKeyHex,
    String encryptedDataKey,
    String label,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'registerDevice',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'registerDevice',
          parameters: i1.testObjectToJson({
            'accountId': accountId,
            'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
            'encryptedDataKey': encryptedDataKey,
            'label': label,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i9.AccountDevice>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i10.AuthenticationResult> authenticateDevice(
    i1.TestSessionBuilder sessionBuilder,
    String challenge,
    String signature,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'authenticateDevice',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'authenticateDevice',
          parameters: i1.testObjectToJson({
            'challenge': challenge,
            'signature': signature,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i10.AuthenticationResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> generateAuthChallenge(
    i1.TestSessionBuilder sessionBuilder,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'generateAuthChallenge',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'generateAuthChallenge',
          parameters: i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<bool> revokeDevice(
    i1.TestSessionBuilder sessionBuilder,
    int deviceId,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'revokeDevice',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'revokeDevice',
          parameters: i1.testObjectToJson({'deviceId': deviceId}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<List<i9.AccountDevice>> listDevices(
    i1.TestSessionBuilder sessionBuilder,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'listDevices',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'listDevices',
          parameters: i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<List<i9.AccountDevice>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Stream<i11.DevicePairingEvent> monitorRegistration(
    i1.TestSessionBuilder sessionBuilder,
    String signingKeyHex,
  ) {
    final _localTestStreamManager =
        i1.TestStreamManager<i11.DevicePairingEvent>();
    i1.callStreamFunctionAndHandleExceptions(
      () async {
        final _localUniqueSession =
            (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
              endpoint: 'device',
              method: 'monitorRegistration',
            );
        final _localCallContext = await _endpointDispatch
            .getMethodStreamCallContext(
              createSessionCallback: (_) => _localUniqueSession,
              endpointPath: 'device',
              methodName: 'monitorRegistration',
              arguments: {'signingKeyHex': signingKeyHex},
              requestedInputStreams: [],
              serializationManager: _serializationManager,
            );
        await _localTestStreamManager.callStreamMethod(
          _localCallContext,
          _localUniqueSession,
          {},
        );
      },
      _localTestStreamManager.outputStreamController,
    );
    return _localTestStreamManager.outputStreamController.stream;
  }

  i3.Future<i9.AccountDevice> registerDeviceForAccount(
    i1.TestSessionBuilder sessionBuilder,
    String newDeviceSigningPublicKeyHex,
    String newDeviceEncryptedDataKey,
    String label,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'registerDeviceForAccount',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'registerDeviceForAccount',
          parameters: i1.testObjectToJson({
            'newDeviceSigningPublicKeyHex': newDeviceSigningPublicKeyHex,
            'newDeviceEncryptedDataKey': newDeviceEncryptedDataKey,
            'label': label,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i9.AccountDevice>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i12.DevicePairingInfo?> getDeviceBySigningKey(
    i1.TestSessionBuilder sessionBuilder,
    String signingPublicKeyHex,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'getDeviceBySigningKey',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'getDeviceBySigningKey',
          parameters: i1.testObjectToJson({
            'signingPublicKeyHex': signingPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i12.DevicePairingInfo?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _IAPEndpoint {
  _IAPEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<Map<String, dynamic>> validateAppleTransaction(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String transactionId,
    String productId,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'validateAppleTransaction',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'validateAppleTransaction',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'transactionId': transactionId,
            'productId': productId,
            'orderId': orderId,
            'accountId': accountId,
            'consumableType': consumableType,
            'quantity': quantity,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> validateGooglePurchase(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String packageName,
    String productId,
    String purchaseToken,
    String orderId,
    int accountId,
    String consumableType,
    double quantity,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'validateGooglePurchase',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'validateGooglePurchase',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'packageName': packageName,
            'productId': productId,
            'purchaseToken': purchaseToken,
            'orderId': orderId,
            'accountId': accountId,
            'consumableType': consumableType,
            'quantity': quantity,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> handleAppleWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'handleAppleWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'handleAppleWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> handleGoogleWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'handleGoogleWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'handleGoogleWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _IAPWebhookEndpoint {
  _IAPWebhookEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<String> handleAppleWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAPWebhook',
            method: 'handleAppleWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAPWebhook',
          methodName: 'handleAppleWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> handleGoogleWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAPWebhook',
            method: 'handleGoogleWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAPWebhook',
          methodName: 'handleGoogleWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _ModuleEndpoint {
  _ModuleEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<String> hello(
    i1.TestSessionBuilder sessionBuilder,
    String name,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'module',
            method: 'hello',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'module',
          methodName: 'hello',
          parameters: i1.testObjectToJson({'name': name}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<bool> authenticateUser(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String challenge,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'module',
            method: 'authenticateUser',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'module',
          methodName: 'authenticateUser',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'challenge': challenge,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> processPayment(
    i1.TestSessionBuilder sessionBuilder,
    String orderId,
    String paymentRail,
    double amount,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'module',
            method: 'processPayment',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'module',
          methodName: 'processPayment',
          parameters: i1.testObjectToJson({
            'orderId': orderId,
            'paymentRail': paymentRail,
            'amount': amount,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<int> manageInventory(
    i1.TestSessionBuilder sessionBuilder,
    int accountId,
    String consumableType,
    String operation,
    int? quantity,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'module',
            method: 'manageInventory',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'module',
          methodName: 'manageInventory',
          parameters: i1.testObjectToJson({
            'accountId': accountId,
            'consumableType': consumableType,
            'operation': operation,
            'quantity': quantity,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _PaymentEndpoint {
  _PaymentEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<i13.PaymentRequest> initiatePayment(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String orderId,
    i6.PaymentRail railType,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'initiatePayment',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'initiatePayment',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'orderId': orderId,
            'railType': railType,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i13.PaymentRequest>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<i5.TransactionPayment> checkPaymentStatus(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String orderId,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'checkPaymentStatus',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'checkPaymentStatus',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'orderId': orderId,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<i5.TransactionPayment>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> processMoneroWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'processMoneroWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'processMoneroWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> processX402Webhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'processX402Webhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'processX402Webhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> processAppleIAPWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'processAppleIAPWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'processAppleIAPWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<String> processGoogleIAPWebhook(
    i1.TestSessionBuilder sessionBuilder,
    Map<String, dynamic> webhookData,
  ) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'processGoogleIAPWebhook',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'processGoogleIAPWebhook',
          parameters: i1.testObjectToJson({'webhookData': webhookData}),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> requestPaymentStatusWithX402(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String orderId, {
    Map<String, String>? headers,
  }) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'payment',
            method: 'requestPaymentStatusWithX402',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'payment',
          methodName: 'requestPaymentStatusWithX402',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'orderId': orderId,
            'headers': headers,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}

class _X402Endpoint {
  _X402Endpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final i2.EndpointDispatch _endpointDispatch;

  final i2.SerializationManager _serializationManager;

  i3.Future<Map<String, dynamic>> requestPaidResource(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String resourceId,
    int accountId, {
    Map<String, String>? headers,
  }) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'x402',
            method: 'requestPaidResource',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'x402',
          methodName: 'requestPaidResource',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'resourceId': resourceId,
            'accountId': accountId,
            'headers': headers,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });

  i3.Future<Map<String, dynamic>> requestConsumableAccess(
    i1.TestSessionBuilder sessionBuilder,
    String publicKey,
    String signature,
    String consumableType,
    double quantity,
    int accountId, {
    Map<String, String>? headers,
  }) async => i1.callAwaitableFunctionAndHandleExceptions(() async {
      final _localUniqueSession =
          (sessionBuilder as i1.InternalTestSessionBuilder).internalBuild(
            endpoint: 'x402',
            method: 'requestConsumableAccess',
          );
      try {
        final _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'x402',
          methodName: 'requestConsumableAccess',
          parameters: i1.testObjectToJson({
            'publicKey': publicKey,
            'signature': signature,
            'consumableType': consumableType,
            'quantity': quantity,
            'accountId': accountId,
            'headers': headers,
          }),
          serializationManager: _serializationManager,
        );
        final _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as i3.Future<Map<String, dynamic>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
}
