import 'package:serverpod/serverpod.dart';

class DeviceNonceList implements SerializableModel {
  final List<String> nonces;

  DeviceNonceList({required this.nonces});

  @override
  Map<String, dynamic> toJson() => {'nonces': nonces};

  factory DeviceNonceList.fromJson(Map<String, dynamic> json) =>
      DeviceNonceList(
        nonces: (json['nonces'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      );

  factory DeviceNonceList.empty() => DeviceNonceList(nonces: []);

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();
}

class DeviceNonceStorage {
  static const String _keyPrefix = 'anonaccred:nonces:';
  static const int _maxNoncesPerDevice = 10;
  static const Duration _nonceTTL = Duration(minutes: 5);

  final Session _session;

  DeviceNonceStorage(this._session);

  String _getKey(String devicePublicKey) => '$_keyPrefix$devicePublicKey';

  Future<String> generateAndStoreNonce(String devicePublicKey) async {
    final nonce = _generateNonce();
    final key = _getKey(devicePublicKey);

    final existing = await _session.caches.global.get<DeviceNonceList>(key);
    List<String> nonces = existing?.nonces ?? [];

    nonces = [nonce, ...nonces];

    if (nonces.length > _maxNoncesPerDevice) {
      nonces = nonces.take(_maxNoncesPerDevice).toList();
    }

    await _session.caches.global.put(
      key,
      DeviceNonceList(nonces: nonces),
      lifetime: _nonceTTL,
    );

    return nonce;
  }

  Future<bool> verifyAndRemoveNonce(
    String devicePublicKey,
    String nonce,
  ) async {
    final key = _getKey(devicePublicKey);
    final stored = await _session.caches.global.get<DeviceNonceList>(key);

    if (stored == null) return false;

    List<String> nonces = List<String>.from(stored.nonces);
    final index = nonces.indexOf(nonce);
    if (index == -1) return false;

    nonces.removeAt(index);

    if (nonces.isEmpty) {
      await _session.caches.global.invalidateKey(key);
    } else {
      await _session.caches.global.put(
        key,
        DeviceNonceList(nonces: nonces),
        lifetime: _nonceTTL,
      );
    }

    return true;
  }

  String _generateNonce() {
    final random = DateTime.now().microsecondsSinceEpoch;
    final hex = random.toRadixString(16).padLeft(16, '0');
    final randomPart = List.generate(
      16,
      (_) => (random * 7 + 13) % 256,
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$hex$randomPart';
  }
}
