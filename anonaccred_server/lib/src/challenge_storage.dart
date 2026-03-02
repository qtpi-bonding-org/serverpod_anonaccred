import 'dart:math';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';

/// Placeholder for challenge existence check (Redis stores true/false)
class ChallengeExists implements SerializableModel {
  ChallengeExists({required this.exists});

  factory ChallengeExists.fromJson(Map<String, dynamic> json) =>
      ChallengeExists(exists: json['exists'] as bool);

  factory ChallengeExists.empty() => ChallengeExists(exists: false);

  final bool exists;

  @override
  Map<String, dynamic> toJson() => {'exists': exists};

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();
}

/// Storage for authentication challenges with Redis-backed TTL expiration.
///
/// Follows the same pattern as DeviceNonceStorage for consistency.
/// Ensures challenges can only be used once and expire automatically.
class DeviceChallengeStorage {
  DeviceChallengeStorage(this._session);
  static const String _keyPrefix = 'anonaccred:challenges:';
  static const Duration _challengeTTL = Duration(minutes: 5);

  final Session _session;

  String _getKey(String devicePublicKey, String challenge) =>
      '$_keyPrefix$devicePublicKey:$challenge';

  /// Generate and store a new challenge for a device.
  ///
  /// Returns the generated challenge string.
  Future<String> generateAndStoreChallenge(String devicePublicKey) async {
    final challenge = _generateChallenge();
    final key = _getKey(devicePublicKey, challenge);

    await _session.caches.global.put(
      key,
      ChallengeExists(exists: true),
      lifetime: _challengeTTL,
    );

    return challenge;
  }

  /// Verify and consume a challenge (one-time use).
  ///
  /// Returns true if the challenge was valid and has been consumed.
  /// Returns false if the challenge is expired, already used, or doesn't exist.
  Future<bool> verifyAndConsume(
    String devicePublicKey,
    String challenge,
  ) async {
    final key = _getKey(devicePublicKey, challenge);

    // Check if challenge exists
    final stored = await _session.caches.global.get<ChallengeExists>(key);

    if (stored == null) return false;

    // Consume by invalidating the key
    await _session.caches.global.invalidateKey(key);
    return true;
  }

  /// Check if a challenge exists without consuming it.
  ///
  /// Returns true if the challenge is still valid.
  Future<bool> exists(String devicePublicKey, String challenge) async {
    final key = _getKey(devicePublicKey, challenge);
    final stored = await _session.caches.global.get<ChallengeExists>(key);
    return stored != null;
  }

  String _generateChallenge() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}