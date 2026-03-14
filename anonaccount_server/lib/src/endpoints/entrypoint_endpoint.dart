import 'pow_endpoint.dart';

/// Single entrypoint for PoW challenge issuance.
///
/// Exposes only [getChallenge] — clients call `entrypoint.getChallenge()`
/// to get a challenge before calling any [SignedPowEndpoint] method.
class EntrypointEndpoint extends PowEndpoint {}
