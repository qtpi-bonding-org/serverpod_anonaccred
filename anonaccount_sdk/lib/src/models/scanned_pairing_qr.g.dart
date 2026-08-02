// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_pairing_qr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScannedPairingQr _$ScannedPairingQrFromJson(Map<String, dynamic> json) =>
    _ScannedPairingQr(
      theirSigningPubkeyHex: json['theirSigningPubkeyHex'] as String,
      theirEncryptionPubkeyHex: json['theirEncryptionPubkeyHex'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$ScannedPairingQrToJson(_ScannedPairingQr instance) =>
    <String, dynamic>{
      'theirSigningPubkeyHex': instance.theirSigningPubkeyHex,
      'theirEncryptionPubkeyHex': instance.theirEncryptionPubkeyHex,
      'label': instance.label,
    };
