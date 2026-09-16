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

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:io' as _idi;
import 'package:anonaccred_server/src/generated/account_entitlement.dart'
    as _i2efidd8;
import 'package:anonaccred_server/src/generated/consume_result.dart'
    as _igd9vbiz;
import 'package:anonaccred_server/src/generated/future_calls.dart' as _ikqnf7jm;
import 'package:anonaccred_server/src/generated/future_calls_generated_models/privacy_scrub_future_call_scrub_model.dart'
    as _ihs1px3z;
import 'package:anonaccred_server/src/generated/group_entitlement.dart'
    as _i9k1womh;
import 'package:anonaccred_server/src/generated/iap_validation_response.dart'
    as _iwz4c2rd;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_test/serverpod_test.dart' as _ist;
import 'package:anonaccred_server/src/generated/protocol.dart';
import 'package:anonaccred_server/src/generated/endpoints.dart';
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
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 120)`.
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
/// [configOverride] A function to override the server configuration. This function is called with
/// the default server configuration after it is loaded from the config/ directory
/// and before it is used to start the server. Use this to override particular
/// settings in the server configuration.
///
/// [databaseInterceptor] Optional interceptor that replaces the default database for each session.
/// See [Serverpod.databaseInterceptor] for more information.
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [Serverpod] for more information.
///
/// [serverDirectory] The server package directory `config/<runMode>.yaml`, `config/passwords.yaml`,
/// and `migrations/<module>/...` are resolved against. Defaults to
/// [Directory.current] at the time the test boots. Pass this when the test
/// isolate's cwd is not the server package root (e.g. running tests from a
/// workspace parent directory) so config and migrations are still loaded
/// from the right place.
@_ist.isTestGroup
void withServerpod(
  String testGroupName,
  _ist.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  _is.ServerpodConfig Function(_is.ServerpodConfig)? configOverride,
  _is.DatabaseInterceptor? databaseInterceptor,
  bool? enableSessionLogging,
  _is.ExperimentalFeatures? experimentalFeatures,
  _ist.RollbackDatabase? rollbackDatabase,
  String? runMode,
  _is.RuntimeParametersListBuilder? runtimeParametersBuilder,
  _idi.Directory? serverDirectory,
  _is.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
  _ist.TestServerOutputMode? testServerOutputMode,
}) {
  _ist.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    _ist.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      testServerOutputMode: testServerOutputMode,
      serverDirectory: serverDirectory,
      experimentalFeatures: experimentalFeatures,
      configOverride: configOverride,
      runtimeParametersBuilder: runtimeParametersBuilder,
      databaseInterceptor: databaseInterceptor,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
    maybeTestServerOutputMode: testServerOutputMode,
  )(testClosure);
}

class TestEndpoints {
  late final futureCalls = _FutureCalls();

  late final _CommerceEndpoint commerce;

  late final _GroupCommerceEndpoint groupCommerce;

  late final _IAPEndpoint iAP;

  late final _PolarEndpoint polar;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    commerce = _CommerceEndpoint(endpoints, serializationManager);
    groupCommerce = _GroupCommerceEndpoint(endpoints, serializationManager);
    iAP = _IAPEndpoint(endpoints, serializationManager);
    polar = _PolarEndpoint(endpoints, serializationManager);
  }
}

class _FutureCalls {
  late final privacyScrub = _PrivacyScrubFutureCall();
}

class _CommerceEndpoint {
  _CommerceEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<List<_i2efidd8.AccountEntitlement>> getEntitlements(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getEntitlements',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getEntitlements',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i2efidd8.AccountEntitlement>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<double> getEntitlementBalance(
    _ist.TestSessionBuilder sessionBuilder,
    String tag,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'getEntitlementBalance',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'getEntitlementBalance',
          parameters: _ist.testObjectToJson({'tag': tag}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<double>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igd9vbiz.ConsumeResult> consumeEntitlement(
    _ist.TestSessionBuilder sessionBuilder,
    String tag,
    double quantity,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'commerce',
            method: 'consumeEntitlement',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'commerce',
          methodName: 'consumeEntitlement',
          parameters: _ist.testObjectToJson({'tag': tag, 'quantity': quantity}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_igd9vbiz.ConsumeResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _GroupCommerceEndpoint {
  _GroupCommerceEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<List<_i9k1womh.GroupEntitlement>> getGroupEntitlements(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue shareGroupUuid,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'groupCommerce',
            method: 'getGroupEntitlements',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'groupCommerce',
          methodName: 'getGroupEntitlements',
          parameters: _ist.testObjectToJson({'shareGroupUuid': shareGroupUuid}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i9k1womh.GroupEntitlement>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<double> getGroupEntitlementBalance(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue shareGroupUuid,
    String tag,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'groupCommerce',
            method: 'getGroupEntitlementBalance',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'groupCommerce',
          methodName: 'getGroupEntitlementBalance',
          parameters: _ist.testObjectToJson({
            'shareGroupUuid': shareGroupUuid,
            'tag': tag,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<double>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_igd9vbiz.ConsumeResult> consumeGroupEntitlement(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue shareGroupUuid,
    String tag,
    double quantity,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'groupCommerce',
            method: 'consumeGroupEntitlement',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'groupCommerce',
          methodName: 'consumeGroupEntitlement',
          parameters: _ist.testObjectToJson({
            'shareGroupUuid': shareGroupUuid,
            'tag': tag,
            'quantity': quantity,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_igd9vbiz.ConsumeResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _IAPEndpoint {
  _IAPEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iwz4c2rd.IapValidationResponse> validateAppleTransaction(
    _ist.TestSessionBuilder sessionBuilder,
    String transactionId,
    String productId, {
    String? internalTransactionId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'validateAppleTransaction',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'validateAppleTransaction',
          parameters: _ist.testObjectToJson({
            'transactionId': transactionId,
            'productId': productId,
            'internalTransactionId': internalTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwz4c2rd.IapValidationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iwz4c2rd.IapValidationResponse> validateGooglePurchase(
    _ist.TestSessionBuilder sessionBuilder,
    String packageName,
    String productId,
    String purchaseToken, {
    String? internalTransactionId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'iAP',
            method: 'validateGooglePurchase',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'iAP',
          methodName: 'validateGooglePurchase',
          parameters: _ist.testObjectToJson({
            'packageName': packageName,
            'productId': productId,
            'purchaseToken': purchaseToken,
            'internalTransactionId': internalTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwz4c2rd.IapValidationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _PolarEndpoint {
  _PolarEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_iwz4c2rd.IapValidationResponse> redeemLicenseKey(
    _ist.TestSessionBuilder sessionBuilder,
    String licenseKey, {
    _is.UuidValue? shareGroupUuid,
    String? internalTransactionId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'polar',
            method: 'redeemLicenseKey',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'polar',
          methodName: 'redeemLicenseKey',
          parameters: _ist.testObjectToJson({
            'licenseKey': licenseKey,
            'shareGroupUuid': shareGroupUuid,
            'internalTransactionId': internalTransactionId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iwz4c2rd.IapValidationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _PrivacyScrubFutureCall {
  Future<void> scrub(
    _ist.TestSessionBuilder sessionBuilder,
    int retentionDays,
  ) async {
    var object = _ihs1px3z.PrivacyScrubFutureCallScrubModel(
      retentionDays: retentionDays,
    );
    var _localUniqueSession =
        (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild();
    try {
      await _ikqnf7jm.PrivacyScrubScrubFutureCall().invoke(
        _localUniqueSession,
        object,
      );
    } finally {
      await _localUniqueSession.close();
    }
  }
}
