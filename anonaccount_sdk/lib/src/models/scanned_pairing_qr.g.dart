// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanned_pairing_qr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScannedPairingQrImpl _$$ScannedPairingQrImplFromJson(
  Map<String, dynamic> json,
) => _$ScannedPairingQrImpl(
  theirSigningPubkeyHex: json['theirSigningPubkeyHex'] as String,
  theirEncryptionPubkeyJwk: json['theirEncryptionPubkeyJwk'] as String,
  label: json['label'] as String,
);

Map<String, dynamic> _$$ScannedPairingQrImplToJson(
  _$ScannedPairingQrImpl instance,
) => <String, dynamic>{
  'theirSigningPubkeyHex': instance.theirSigningPubkeyHex,
  'theirEncryptionPubkeyJwk': instance.theirEncryptionPubkeyJwk,
  'label': instance.label,
};
