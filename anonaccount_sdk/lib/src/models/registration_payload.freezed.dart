// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RegistrationPayload _$RegistrationPayloadFromJson(Map<String, dynamic> json) {
  return _RegistrationPayload.fromJson(json);
}

/// @nodoc
mixin _$RegistrationPayload {
  String get devicePublicKeyHex => throw _privateConstructorUsedError;
  String get ultimatePublicKeyHex => throw _privateConstructorUsedError;
  String get recoveryBlob => throw _privateConstructorUsedError;
  String get deviceBlob => throw _privateConstructorUsedError;
  String get signature => throw _privateConstructorUsedError;
  String get deviceKeyAttestation => throw _privateConstructorUsedError;
  String? get crossDeviceKeyAttestation => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;

  /// Serializes this RegistrationPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegistrationPayloadCopyWith<RegistrationPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegistrationPayloadCopyWith<$Res> {
  factory $RegistrationPayloadCopyWith(
    RegistrationPayload value,
    $Res Function(RegistrationPayload) then,
  ) = _$RegistrationPayloadCopyWithImpl<$Res, RegistrationPayload>;
  @useResult
  $Res call({
    String devicePublicKeyHex,
    String ultimatePublicKeyHex,
    String recoveryBlob,
    String deviceBlob,
    String signature,
    String deviceKeyAttestation,
    String? crossDeviceKeyAttestation,
    DateTime createdAt,
    int version,
  });
}

/// @nodoc
class _$RegistrationPayloadCopyWithImpl<$Res, $Val extends RegistrationPayload>
    implements $RegistrationPayloadCopyWith<$Res> {
  _$RegistrationPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devicePublicKeyHex = null,
    Object? ultimatePublicKeyHex = null,
    Object? recoveryBlob = null,
    Object? deviceBlob = null,
    Object? signature = null,
    Object? deviceKeyAttestation = null,
    Object? crossDeviceKeyAttestation = freezed,
    Object? createdAt = null,
    Object? version = null,
  }) {
    return _then(
      _value.copyWith(
            devicePublicKeyHex: null == devicePublicKeyHex
                ? _value.devicePublicKeyHex
                : devicePublicKeyHex // ignore: cast_nullable_to_non_nullable
                      as String,
            ultimatePublicKeyHex: null == ultimatePublicKeyHex
                ? _value.ultimatePublicKeyHex
                : ultimatePublicKeyHex // ignore: cast_nullable_to_non_nullable
                      as String,
            recoveryBlob: null == recoveryBlob
                ? _value.recoveryBlob
                : recoveryBlob // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceBlob: null == deviceBlob
                ? _value.deviceBlob
                : deviceBlob // ignore: cast_nullable_to_non_nullable
                      as String,
            signature: null == signature
                ? _value.signature
                : signature // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceKeyAttestation: null == deviceKeyAttestation
                ? _value.deviceKeyAttestation
                : deviceKeyAttestation // ignore: cast_nullable_to_non_nullable
                      as String,
            crossDeviceKeyAttestation: freezed == crossDeviceKeyAttestation
                ? _value.crossDeviceKeyAttestation
                : crossDeviceKeyAttestation // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegistrationPayloadImplCopyWith<$Res>
    implements $RegistrationPayloadCopyWith<$Res> {
  factory _$$RegistrationPayloadImplCopyWith(
    _$RegistrationPayloadImpl value,
    $Res Function(_$RegistrationPayloadImpl) then,
  ) = __$$RegistrationPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String devicePublicKeyHex,
    String ultimatePublicKeyHex,
    String recoveryBlob,
    String deviceBlob,
    String signature,
    String deviceKeyAttestation,
    String? crossDeviceKeyAttestation,
    DateTime createdAt,
    int version,
  });
}

/// @nodoc
class __$$RegistrationPayloadImplCopyWithImpl<$Res>
    extends _$RegistrationPayloadCopyWithImpl<$Res, _$RegistrationPayloadImpl>
    implements _$$RegistrationPayloadImplCopyWith<$Res> {
  __$$RegistrationPayloadImplCopyWithImpl(
    _$RegistrationPayloadImpl _value,
    $Res Function(_$RegistrationPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devicePublicKeyHex = null,
    Object? ultimatePublicKeyHex = null,
    Object? recoveryBlob = null,
    Object? deviceBlob = null,
    Object? signature = null,
    Object? deviceKeyAttestation = null,
    Object? crossDeviceKeyAttestation = freezed,
    Object? createdAt = null,
    Object? version = null,
  }) {
    return _then(
      _$RegistrationPayloadImpl(
        devicePublicKeyHex: null == devicePublicKeyHex
            ? _value.devicePublicKeyHex
            : devicePublicKeyHex // ignore: cast_nullable_to_non_nullable
                  as String,
        ultimatePublicKeyHex: null == ultimatePublicKeyHex
            ? _value.ultimatePublicKeyHex
            : ultimatePublicKeyHex // ignore: cast_nullable_to_non_nullable
                  as String,
        recoveryBlob: null == recoveryBlob
            ? _value.recoveryBlob
            : recoveryBlob // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceBlob: null == deviceBlob
            ? _value.deviceBlob
            : deviceBlob // ignore: cast_nullable_to_non_nullable
                  as String,
        signature: null == signature
            ? _value.signature
            : signature // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceKeyAttestation: null == deviceKeyAttestation
            ? _value.deviceKeyAttestation
            : deviceKeyAttestation // ignore: cast_nullable_to_non_nullable
                  as String,
        crossDeviceKeyAttestation: freezed == crossDeviceKeyAttestation
            ? _value.crossDeviceKeyAttestation
            : crossDeviceKeyAttestation // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegistrationPayloadImpl extends _RegistrationPayload {
  const _$RegistrationPayloadImpl({
    required this.devicePublicKeyHex,
    required this.ultimatePublicKeyHex,
    required this.recoveryBlob,
    required this.deviceBlob,
    required this.signature,
    required this.deviceKeyAttestation,
    this.crossDeviceKeyAttestation,
    required this.createdAt,
    this.version = 1,
  }) : super._();

  factory _$RegistrationPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegistrationPayloadImplFromJson(json);

  @override
  final String devicePublicKeyHex;
  @override
  final String ultimatePublicKeyHex;
  @override
  final String recoveryBlob;
  @override
  final String deviceBlob;
  @override
  final String signature;
  @override
  final String deviceKeyAttestation;
  @override
  final String? crossDeviceKeyAttestation;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int version;

  @override
  String toString() {
    return 'RegistrationPayload(devicePublicKeyHex: $devicePublicKeyHex, ultimatePublicKeyHex: $ultimatePublicKeyHex, recoveryBlob: $recoveryBlob, deviceBlob: $deviceBlob, signature: $signature, deviceKeyAttestation: $deviceKeyAttestation, crossDeviceKeyAttestation: $crossDeviceKeyAttestation, createdAt: $createdAt, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrationPayloadImpl &&
            (identical(other.devicePublicKeyHex, devicePublicKeyHex) ||
                other.devicePublicKeyHex == devicePublicKeyHex) &&
            (identical(other.ultimatePublicKeyHex, ultimatePublicKeyHex) ||
                other.ultimatePublicKeyHex == ultimatePublicKeyHex) &&
            (identical(other.recoveryBlob, recoveryBlob) ||
                other.recoveryBlob == recoveryBlob) &&
            (identical(other.deviceBlob, deviceBlob) ||
                other.deviceBlob == deviceBlob) &&
            (identical(other.signature, signature) ||
                other.signature == signature) &&
            (identical(other.deviceKeyAttestation, deviceKeyAttestation) ||
                other.deviceKeyAttestation == deviceKeyAttestation) &&
            (identical(
                  other.crossDeviceKeyAttestation,
                  crossDeviceKeyAttestation,
                ) ||
                other.crossDeviceKeyAttestation == crossDeviceKeyAttestation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    devicePublicKeyHex,
    ultimatePublicKeyHex,
    recoveryBlob,
    deviceBlob,
    signature,
    deviceKeyAttestation,
    crossDeviceKeyAttestation,
    createdAt,
    version,
  );

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrationPayloadImplCopyWith<_$RegistrationPayloadImpl> get copyWith =>
      __$$RegistrationPayloadImplCopyWithImpl<_$RegistrationPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegistrationPayloadImplToJson(this);
  }
}

abstract class _RegistrationPayload extends RegistrationPayload {
  const factory _RegistrationPayload({
    required final String devicePublicKeyHex,
    required final String ultimatePublicKeyHex,
    required final String recoveryBlob,
    required final String deviceBlob,
    required final String signature,
    required final String deviceKeyAttestation,
    final String? crossDeviceKeyAttestation,
    required final DateTime createdAt,
    final int version,
  }) = _$RegistrationPayloadImpl;
  const _RegistrationPayload._() : super._();

  factory _RegistrationPayload.fromJson(Map<String, dynamic> json) =
      _$RegistrationPayloadImpl.fromJson;

  @override
  String get devicePublicKeyHex;
  @override
  String get ultimatePublicKeyHex;
  @override
  String get recoveryBlob;
  @override
  String get deviceBlob;
  @override
  String get signature;
  @override
  String get deviceKeyAttestation;
  @override
  String? get crossDeviceKeyAttestation;
  @override
  DateTime get createdAt;
  @override
  int get version;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegistrationPayloadImplCopyWith<_$RegistrationPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
