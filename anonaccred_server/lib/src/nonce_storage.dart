import 'dart:convert';

import 'package:serverpod/serverpod.dart';

class DeviceNonceList {

  DeviceNonceList({required this.nonces});

  factory DeviceNonceList.fromJson(Map<String, dynamic> json) => DeviceNonceList(
      nonces: (json['nonces'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );

  factory DeviceNonceList.empty() => DeviceNonceList(nonces: []);
  final List<String> nonces;

  DeviceNonceList copyWith({List<String>? nonces}) => DeviceNonceList(nonces: nonces ?? this.nonces);

  Map<String, dynamic> toJson() => {'__className__': 'DeviceNonceList', 'nonces': nonces};

  String toJsonString() => jsonEncode(toJson());

  static DeviceNonceList fromJsonString(String jsonStr) => DeviceNonceList.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
}

class DeviceNonceStorage {

  DeviceNonceStorage(this._session);
  static const String _keyPrefix = 'anonaccred:nonces:';
  static const int _maxNoncesPerDevice = 10;
  static const Duration _nonceTTL = Duration(minutes: 5);

  final Session _session;

  String _getKey(String devicePublicKey) => '$_keyPrefix$devicePublicKey';

  Future<String> generateAndStoreNonce(String devicePublicKey) async {
    final nonce = _generateNonce();
    final key = _getKey(devicePublicKey);

    final existingNonces = await _getNonces(key);
    final nonces = [nonce, ...existingNonces];

    if (nonces.length > _maxNoncesPerDevice) {
      nonces.removeRange(_maxNoncesPerDevice, nonces.length);
    }

    await _cache.put(
      key,
      DeviceNonceList(nonces: nonces).toJsonString(),
      lifetime: _nonceTTL,
    );

    return nonce;
  }

  Future<bool> verifyAndRemoveNonce(
    String devicePublicKey,
    String nonce,
  ) async {
    final key = _getKey(devicePublicKey);
    final nonces = await _getNonces(key);

    final index = nonces.indexOf(nonce);
    if (index == -1) {
      return false;
    }

    nonces.removeAt(index);

    if (nonces.isEmpty) {
      await _cache.invalidateKey(key);
    } else {
      await _cache.put(
        key,
        DeviceNonceList(nonces: nonces).toJsonString(),
        lifetime: _nonceTTL,
      );
    }

    return true;
  }

  dynamic get _cache => _session.caches.global;

  Future<List<String>> _getNonces(String key) async {
    final jsonData = await _cache.get<String>(key);
    if (jsonData == null) return [];
    final jsonStr = jsonData.toString();
    if (jsonStr.isEmpty) return [];
    return DeviceNonceList.fromJsonString(jsonStr).nonces;
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
