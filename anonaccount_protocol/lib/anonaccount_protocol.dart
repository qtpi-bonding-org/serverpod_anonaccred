/// Shared wire types and signed-payload builders.
///
/// Everything here is imported by BOTH anonaccount_server and
/// anonaccount_client. Nothing here may depend on `serverpod` (server-only)
/// or `serverpod_client` — only `serverpod_serialization`, which both sides
/// already have.
library;

export 'src/generated/protocol.dart';

// TODO(shared-protocol-package Task 4): export 'src/pow_methods.dart'; once
// the payload builders move here — deferred so Task 3 lands in a state
// where the whole tree analyzes and tests cleanly with only PublicKeyDuo
// moved.
