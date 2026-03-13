import 'dart:math';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';

import 'generated/challenge_exists.dart';

/// Storage for authentication challenges with Redis-backed TTL expiration.
class DeviceChallengeStorage {
  DeviceChallengeStorage(this._session);
  static const String _keyPrefix = 'anonaccount:challenges:';
  static const Duration _challengeTTL = Duration(minutes: 5);

  final Session _session;

  String _getKey(String devicePublicKey, String challenge) =>
      '$_keyPrefix$devicePublicKey:$challenge';

  /// Generate and store a new challenge for a device.
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
  Future<bool> verifyAndConsume(
    String devicePublicKey,
    String challenge,
  ) async {
    final key = _getKey(devicePublicKey, challenge);
    final stored = await _session.caches.global.get<ChallengeExists>(key);
    if (stored == null) return false;
    await _session.caches.global.invalidateKey(key);
    return true;
  }

  /// Check if a challenge exists without consuming it.
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
