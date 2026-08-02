import 'package:serverpod/serverpod.dart';

/// The one signature every protocol exception constructor is adapted to.
///
/// The four protocol exceptions are siblings with different constructors;
/// a single typedef is what lets one boundary serve all of them.
typedef ProtocolFailure<E extends SerializableException> = E Function({
  required String code,
  required String message,
  required String operation,
  required Map<String, String> details,
});

/// The error boundary for both servers.
///
/// [session] is positional and nullable rather than an optional named
/// parameter: callers must decide, and the eight session-less helpers say so
/// by passing null. An omittable parameter would let a call site that has a
/// session quietly skip observability.
Future<T> tryOperation<T, E extends SerializableException>(
  Session? session,
  String operation,
  Future<T> Function() body, {
  required ProtocolFailure<E> onFailure,
  required String code,
  Map<String, String> extraDetails = const {},
}) async {
  try {
    return await body();
  } on SerializableException {
    rethrow;
  } catch (e, stackTrace) {
    if (session != null) {
      session.serverpod.experimental.submitDiagnosticEvent(
        ExceptionEvent(e, stackTrace, message: operation),
        session: session,
      );
      session.log('$operation failed: $e\n$stackTrace', level: LogLevel.error);
    }
    Error.throwWithStackTrace(
      onFailure(
        code: code,
        message: '$operation failed: ${e.runtimeType}',
        operation: operation,
        details: {
          ...extraDetails,
          if (session != null) 'ref': session.sessionId.toString(),
        },
      ),
      stackTrace,
    );
  }
}