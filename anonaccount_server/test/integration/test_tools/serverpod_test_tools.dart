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
import 'package:anonaccount_protocol/anonaccount_protocol.dart' as _ijl9ntd6;
import 'package:anonaccount_server/src/generated/account_creation_response.dart'
    as _idtq5ix2;
import 'package:anonaccount_server/src/generated/account_device.dart'
    as _i048gg9e;
import 'package:anonaccount_server/src/generated/authentication_result.dart'
    as _iukljpl3;
import 'package:anonaccount_server/src/generated/device_pairing_event.dart'
    as _icarjbbg;
import 'package:anonaccount_server/src/generated/encrypted_data_key_response.dart'
    as _ipivzus8;
import 'package:anonaccount_server/src/generated/grant_member_device_result.dart'
    as _ihq1l2p9;
import 'package:anonaccount_server/src/generated/group_member.dart'
    as _idon4w26;
import 'package:anonaccount_server/src/generated/group_member_role.dart'
    as _ieyt77v6;
import 'package:anonaccount_server/src/generated/group_member_view.dart'
    as _i7ifz6hk;
import 'package:anonaccount_server/src/generated/group_membership_view.dart'
    as _ivankdcm;
import 'package:anonaccount_server/src/generated/member_device_grant.dart'
    as _ij4d8jf2;
import 'package:anonaccount_server/src/generated/public_challenge_response.dart'
    as _itksq16k;
import 'package:anonaccount_server/src/generated/share_group.dart' as _is96bcon;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_test/serverpod_test.dart' as _ist;
import 'package:anonaccount_server/src/generated/protocol.dart';
import 'package:anonaccount_server/src/generated/endpoints.dart';
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
  late final _AccountEndpoint account;

  late final _DataKeyEndpoint dataKey;

  late final _DeviceEndpoint device;

  late final _DeviceManagementEndpoint deviceManagement;

  late final _EntrypointEndpoint entrypoint;

  late final _GroupEndpoint group;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    account = _AccountEndpoint(endpoints, serializationManager);
    dataKey = _DataKeyEndpoint(endpoints, serializationManager);
    device = _DeviceEndpoint(endpoints, serializationManager);
    deviceManagement = _DeviceManagementEndpoint(
      endpoints,
      serializationManager,
    );
    entrypoint = _EntrypointEndpoint(endpoints, serializationManager);
    group = _GroupEndpoint(endpoints, serializationManager);
  }
}

class _AccountEndpoint {
  _AccountEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_idtq5ix2.AccountCreationResponse> createAccount(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String publicKeyHex,
    required _ijl9ntd6.PublicKeyDuo ultimateKeys,
    required String encryptedDataKey,
    required _ijl9ntd6.PublicKeyDuo deviceKeys,
    required String deviceKeyAttestation,
    required String deviceEncryptedDataKey,
    required String deviceLabel,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'createAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'createAccount',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'publicKeyHex': publicKeyHex,
            'ultimateKeys': ultimateKeys,
            'encryptedDataKey': encryptedDataKey,
            'deviceKeys': deviceKeys,
            'deviceKeyAttestation': deviceKeyAttestation,
            'deviceEncryptedDataKey': deviceEncryptedDataKey,
            'deviceLabel': deviceLabel,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idtq5ix2.AccountCreationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifySignedPow(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'verifySignedPow',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'verifySignedPow',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'payload': payload,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'account',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'account',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _DataKeyEndpoint {
  _DataKeyEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ipivzus8.EncryptedDataKeyResponse> retrieveEncryptedDataKey(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String deviceSigningPublicKeyHex,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'dataKey',
            method: 'retrieveEncryptedDataKey',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'dataKey',
          methodName: 'retrieveEncryptedDataKey',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'deviceSigningPublicKeyHex': deviceSigningPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ipivzus8.EncryptedDataKeyResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ipivzus8.EncryptedDataKeyResponse> recoverEncryptedDataKey(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String ultimateSigningPublicKeyHex,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'dataKey',
            method: 'recoverEncryptedDataKey',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'dataKey',
          methodName: 'recoverEncryptedDataKey',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ipivzus8.EncryptedDataKeyResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'dataKey',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'dataKey',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifySignedPow(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'dataKey',
            method: 'verifySignedPow',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'dataKey',
          methodName: 'verifySignedPow',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'payload': payload,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'dataKey',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'dataKey',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _DeviceEndpoint {
  _DeviceEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i048gg9e.AccountDevice> registerDevice(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String deviceKeyAttestation,
    required String ultimateSigningPublicKeyHex,
    required _ijl9ntd6.PublicKeyDuo deviceKeys,
    required String encryptedDataKey,
    required String label,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'registerDevice',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'registerDevice',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'deviceKeyAttestation': deviceKeyAttestation,
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
            'deviceKeys': deviceKeys,
            'encryptedDataKey': encryptedDataKey,
            'label': label,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i048gg9e.AccountDevice>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iukljpl3.AuthenticationResult> signIn(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String devicePublicKeyHex,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'signIn',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'signIn',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'devicePublicKeyHex': devicePublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iukljpl3.AuthenticationResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Stream<_icarjbbg.DevicePairingEvent> monitorRegistration(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String signingKeyHex,
  }) {
    var _localTestStreamManager =
        _ist.TestStreamManager<_icarjbbg.DevicePairingEvent>();
    _ist.callStreamFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'monitorRegistration',
          );
      var _localCallContext = await _endpointDispatch
          .getMethodStreamCallContext(
            createSessionCallback: (_) => _localUniqueSession,
            endpointPath: 'device',
            methodName: 'monitorRegistration',
            arguments: {
              'challenge': challenge,
              'proofOfWork': proofOfWork,
              'signature': signature,
              'signingKeyHex': signingKeyHex,
            },
            requestedInputStreams: [],
            serializationManager: _serializationManager,
          );
      await _localTestStreamManager.callStreamMethod(
        _localCallContext,
        _localUniqueSession,
        {},
      );
    }, _localTestStreamManager.outputStreamController);
    return _localTestStreamManager.outputStreamController.stream;
  }

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifySignedPow(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'verifySignedPow',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'verifySignedPow',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'payload': payload,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'device',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'device',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _DeviceManagementEndpoint {
  _DeviceManagementEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<bool> revokeDevice(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required _is.UuidValue deviceId,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'revokeDevice',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'revokeDevice',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'deviceId': deviceId,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i048gg9e.AccountDevice>> listDevices(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'listDevices',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'listDevices',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i048gg9e.AccountDevice>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i048gg9e.AccountDevice> registerDeviceForAccount(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String publicKeyHex,
    required String signature,
    required _ijl9ntd6.PublicKeyDuo newDeviceKeys,
    required String pairingAttestation,
    required String newDeviceEncryptedDataKey,
    required String label,
    required String ultimateEncryptionPublicKeyHex,
    required String ultimateSigningPublicKeyHex,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'registerDeviceForAccount',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'registerDeviceForAccount',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'newDeviceKeys': newDeviceKeys,
            'pairingAttestation': pairingAttestation,
            'newDeviceEncryptedDataKey': newDeviceEncryptedDataKey,
            'label': label,
            'ultimateEncryptionPublicKeyHex': ultimateEncryptionPublicKeyHex,
            'ultimateSigningPublicKeyHex': ultimateSigningPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i048gg9e.AccountDevice>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifySignedPow(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'verifySignedPow',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'verifySignedPow',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'payload': payload,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'deviceManagement',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'deviceManagement',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _EntrypointEndpoint {
  _EntrypointEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entrypoint',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entrypoint',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'entrypoint',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'entrypoint',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _GroupEndpoint {
  _GroupEndpoint(this._endpointDispatch, this._serializationManager);

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_is96bcon.ShareGroup> createGroup(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _ijl9ntd6.PublicKeyDuo groupUltimateKeys,
    required String groupEncryptedDataKey,
    required _ijl9ntd6.PublicKeyDuo creatorMemberKeys,
    required String creatorMemberEncryptedDataKey,
    required String groupUltimateAttestation,
    required String creatorEncryptedMemberKey,
    required String creatorEncryptedMemberKeyAttestation,
    required String creatorEncryptedUltimateKey,
    required String creatorEncryptedUltimateKeyAttestation,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'createGroup',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'createGroup',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'groupUltimateKeys': groupUltimateKeys,
            'groupEncryptedDataKey': groupEncryptedDataKey,
            'creatorMemberKeys': creatorMemberKeys,
            'creatorMemberEncryptedDataKey': creatorMemberEncryptedDataKey,
            'groupUltimateAttestation': groupUltimateAttestation,
            'creatorEncryptedMemberKey': creatorEncryptedMemberKey,
            'creatorEncryptedMemberKeyAttestation':
                creatorEncryptedMemberKeyAttestation,
            'creatorEncryptedUltimateKey': creatorEncryptedUltimateKey,
            'creatorEncryptedUltimateKeyAttestation':
                creatorEncryptedUltimateKeyAttestation,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_is96bcon.ShareGroup>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_ivankdcm.GroupMembershipView>> listMyGroups(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'listMyGroups',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'listMyGroups',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_ivankdcm.GroupMembershipView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_idon4w26.GroupMember> addGroupMember(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue groupId,
    required _is.UuidValue newMemberAccountId,
    required _ieyt77v6.GroupMemberRole role,
    required _ijl9ntd6.PublicKeyDuo memberKeys,
    required String encryptedDataKey,
    required String encryptedMemberKey,
    required String encryptedMemberKeyAttestation,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'addGroupMember',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'addGroupMember',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'groupId': groupId,
            'newMemberAccountId': newMemberAccountId,
            'role': role,
            'memberKeys': memberKeys,
            'encryptedDataKey': encryptedDataKey,
            'encryptedMemberKey': encryptedMemberKey,
            'encryptedMemberKeyAttestation': encryptedMemberKeyAttestation,
            'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
            'groupUltimateSignature': groupUltimateSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idon4w26.GroupMember>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> removeGroupMember(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue memberId,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'removeGroupMember',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'removeGroupMember',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'memberId': memberId,
            'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
            'groupUltimateSignature': groupUltimateSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_idon4w26.GroupMember> changeGroupMemberRole(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue memberId,
    required _ieyt77v6.GroupMemberRole newRole,
    String? callerMemberSigningPublicKeyHex,
    String? memberAuthSignature,
    String? groupUltimateSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'changeGroupMemberRole',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'changeGroupMemberRole',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'memberId': memberId,
            'newRole': newRole,
            'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
            'groupUltimateSignature': groupUltimateSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idon4w26.GroupMember>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Stream<_i7ifz6hk.GroupMemberView> monitorGroupMembership(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue groupId,
    required String memberSigningKeyHex,
    required String memberAuthSignature,
  }) {
    var _localTestStreamManager =
        _ist.TestStreamManager<_i7ifz6hk.GroupMemberView>();
    _ist.callStreamFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'monitorGroupMembership',
          );
      var _localCallContext = await _endpointDispatch
          .getMethodStreamCallContext(
            createSessionCallback: (_) => _localUniqueSession,
            endpointPath: 'group',
            methodName: 'monitorGroupMembership',
            arguments: {
              'challenge': challenge,
              'proofOfWork': proofOfWork,
              'signature': signature,
              'callerDeviceSigningPublicKeyHex':
                  callerDeviceSigningPublicKeyHex,
              'groupId': groupId,
              'memberSigningKeyHex': memberSigningKeyHex,
              'memberAuthSignature': memberAuthSignature,
            },
            requestedInputStreams: [],
            serializationManager: _serializationManager,
          );
      await _localTestStreamManager.callStreamMethod(
        _localCallContext,
        _localUniqueSession,
        {},
      );
    }, _localTestStreamManager.outputStreamController);
    return _localTestStreamManager.outputStreamController.stream;
  }

  _ida.Future<_is96bcon.ShareGroup> getGroup(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'getGroup',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'getGroup',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'groupId': groupId,
            'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_is96bcon.ShareGroup>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i7ifz6hk.GroupMemberView>> listGroupMembers(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue groupId,
    required String callerMemberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'listGroupMembers',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'listGroupMembers',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'groupId': groupId,
            'callerMemberSigningPublicKeyHex': callerMemberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i7ifz6hk.GroupMemberView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<bool> leaveGroup(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required _is.UuidValue memberId,
    required String memberSigningPublicKeyHex,
    required String memberAuthSignature,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'leaveGroup',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'leaveGroup',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'memberId': memberId,
            'memberSigningPublicKeyHex': memberSigningPublicKeyHex,
            'memberAuthSignature': memberAuthSignature,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ihq1l2p9.GrantMemberDeviceResult> grantMemberDevice(
    _ist.TestSessionBuilder sessionBuilder, {
    required String challenge,
    required String proofOfWork,
    required String signature,
    required String callerDeviceSigningPublicKeyHex,
    required List<_ij4d8jf2.MemberDeviceGrant> grants,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'grantMemberDevice',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'grantMemberDevice',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'signature': signature,
            'callerDeviceSigningPublicKeyHex': callerDeviceSigningPublicKeyHex,
            'grants': grants,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ihq1l2p9.GrantMemberDeviceResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_itksq16k.PublicChallengeResponse> getChallenge(
    _ist.TestSessionBuilder sessionBuilder,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'getChallenge',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'getChallenge',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_itksq16k.PublicChallengeResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifySignedPow(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
    String publicKeyHex,
    String signature,
    String payload,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'verifySignedPow',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'verifySignedPow',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
            'publicKeyHex': publicKeyHex,
            'signature': signature,
            'payload': payload,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<void> verifyHashcash(
    _ist.TestSessionBuilder sessionBuilder,
    String challenge,
    String proofOfWork,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'group',
            method: 'verifyHashcash',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'group',
          methodName: 'verifyHashcash',
          parameters: _ist.testObjectToJson({
            'challenge': challenge,
            'proofOfWork': proofOfWork,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}
