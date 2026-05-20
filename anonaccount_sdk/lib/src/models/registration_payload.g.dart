// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegistrationPayloadImpl _$$RegistrationPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$RegistrationPayloadImpl(
  devicePublicKeyHex: json['devicePublicKeyHex'] as String,
  ultimatePublicKeyHex: json['ultimatePublicKeyHex'] as String,
  recoveryBlob: json['recoveryBlob'] as String,
  deviceBlob: json['deviceBlob'] as String,
  signature: json['signature'] as String,
  deviceKeyAttestation: json['deviceKeyAttestation'] as String,
  crossDeviceKeyAttestation: json['crossDeviceKeyAttestation'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$$RegistrationPayloadImplToJson(
  _$RegistrationPayloadImpl instance,
) => <String, dynamic>{
  'devicePublicKeyHex': instance.devicePublicKeyHex,
  'ultimatePublicKeyHex': instance.ultimatePublicKeyHex,
  'recoveryBlob': instance.recoveryBlob,
  'deviceBlob': instance.deviceBlob,
  'signature': instance.signature,
  'deviceKeyAttestation': instance.deviceKeyAttestation,
  'crossDeviceKeyAttestation': instance.crossDeviceKeyAttestation,
  'createdAt': instance.createdAt.toIso8601String(),
  'version': instance.version,
};
