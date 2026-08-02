// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegistrationPayloadImpl _$$RegistrationPayloadImplFromJson(
        Map<String, dynamic> json) =>
    _$RegistrationPayloadImpl(
      devicePublicKeyHex: json['devicePublicKeyHex'] as String,
      deviceEncryptionPublicKeyHex:
          json['deviceEncryptionPublicKeyHex'] as String,
      ultimatePublicKeyHex: json['ultimatePublicKeyHex'] as String,
      ultimateEncryptionPublicKeyHex:
          json['ultimateEncryptionPublicKeyHex'] as String,
      recoveryBlob: json['recoveryBlob'] as String,
      deviceBlob: json['deviceBlob'] as String,
      deviceKeyAttestation: json['deviceKeyAttestation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$RegistrationPayloadImplToJson(
        _$RegistrationPayloadImpl instance) =>
    <String, dynamic>{
      'devicePublicKeyHex': instance.devicePublicKeyHex,
      'deviceEncryptionPublicKeyHex': instance.deviceEncryptionPublicKeyHex,
      'ultimatePublicKeyHex': instance.ultimatePublicKeyHex,
      'ultimateEncryptionPublicKeyHex': instance.ultimateEncryptionPublicKeyHex,
      'recoveryBlob': instance.recoveryBlob,
      'deviceBlob': instance.deviceBlob,
      'deviceKeyAttestation': instance.deviceKeyAttestation,
      'createdAt': instance.createdAt.toIso8601String(),
      'version': instance.version,
    };
