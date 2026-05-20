// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_pairing_qr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GeneratedPairingQr {
  String get qrPayloadJson => throw _privateConstructorUsedError;
  KeyDuo get deviceKey => throw _privateConstructorUsedError;
  String get signingPubkeyHex => throw _privateConstructorUsedError;

  /// Create a copy of GeneratedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneratedPairingQrCopyWith<GeneratedPairingQr> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratedPairingQrCopyWith<$Res> {
  factory $GeneratedPairingQrCopyWith(
    GeneratedPairingQr value,
    $Res Function(GeneratedPairingQr) then,
  ) = _$GeneratedPairingQrCopyWithImpl<$Res, GeneratedPairingQr>;
  @useResult
  $Res call({String qrPayloadJson, KeyDuo deviceKey, String signingPubkeyHex});
}

/// @nodoc
class _$GeneratedPairingQrCopyWithImpl<$Res, $Val extends GeneratedPairingQr>
    implements $GeneratedPairingQrCopyWith<$Res> {
  _$GeneratedPairingQrCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneratedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrPayloadJson = null,
    Object? deviceKey = null,
    Object? signingPubkeyHex = null,
  }) {
    return _then(
      _value.copyWith(
            qrPayloadJson: null == qrPayloadJson
                ? _value.qrPayloadJson
                : qrPayloadJson // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceKey: null == deviceKey
                ? _value.deviceKey
                : deviceKey // ignore: cast_nullable_to_non_nullable
                      as KeyDuo,
            signingPubkeyHex: null == signingPubkeyHex
                ? _value.signingPubkeyHex
                : signingPubkeyHex // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeneratedPairingQrImplCopyWith<$Res>
    implements $GeneratedPairingQrCopyWith<$Res> {
  factory _$$GeneratedPairingQrImplCopyWith(
    _$GeneratedPairingQrImpl value,
    $Res Function(_$GeneratedPairingQrImpl) then,
  ) = __$$GeneratedPairingQrImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String qrPayloadJson, KeyDuo deviceKey, String signingPubkeyHex});
}

/// @nodoc
class __$$GeneratedPairingQrImplCopyWithImpl<$Res>
    extends _$GeneratedPairingQrCopyWithImpl<$Res, _$GeneratedPairingQrImpl>
    implements _$$GeneratedPairingQrImplCopyWith<$Res> {
  __$$GeneratedPairingQrImplCopyWithImpl(
    _$GeneratedPairingQrImpl _value,
    $Res Function(_$GeneratedPairingQrImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeneratedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrPayloadJson = null,
    Object? deviceKey = null,
    Object? signingPubkeyHex = null,
  }) {
    return _then(
      _$GeneratedPairingQrImpl(
        qrPayloadJson: null == qrPayloadJson
            ? _value.qrPayloadJson
            : qrPayloadJson // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceKey: null == deviceKey
            ? _value.deviceKey
            : deviceKey // ignore: cast_nullable_to_non_nullable
                  as KeyDuo,
        signingPubkeyHex: null == signingPubkeyHex
            ? _value.signingPubkeyHex
            : signingPubkeyHex // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GeneratedPairingQrImpl implements _GeneratedPairingQr {
  const _$GeneratedPairingQrImpl({
    required this.qrPayloadJson,
    required this.deviceKey,
    required this.signingPubkeyHex,
  });

  @override
  final String qrPayloadJson;
  @override
  final KeyDuo deviceKey;
  @override
  final String signingPubkeyHex;

  @override
  String toString() {
    return 'GeneratedPairingQr(qrPayloadJson: $qrPayloadJson, deviceKey: $deviceKey, signingPubkeyHex: $signingPubkeyHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratedPairingQrImpl &&
            (identical(other.qrPayloadJson, qrPayloadJson) ||
                other.qrPayloadJson == qrPayloadJson) &&
            (identical(other.deviceKey, deviceKey) ||
                other.deviceKey == deviceKey) &&
            (identical(other.signingPubkeyHex, signingPubkeyHex) ||
                other.signingPubkeyHex == signingPubkeyHex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, qrPayloadJson, deviceKey, signingPubkeyHex);

  /// Create a copy of GeneratedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratedPairingQrImplCopyWith<_$GeneratedPairingQrImpl> get copyWith =>
      __$$GeneratedPairingQrImplCopyWithImpl<_$GeneratedPairingQrImpl>(
        this,
        _$identity,
      );
}

abstract class _GeneratedPairingQr implements GeneratedPairingQr {
  const factory _GeneratedPairingQr({
    required final String qrPayloadJson,
    required final KeyDuo deviceKey,
    required final String signingPubkeyHex,
  }) = _$GeneratedPairingQrImpl;

  @override
  String get qrPayloadJson;
  @override
  KeyDuo get deviceKey;
  @override
  String get signingPubkeyHex;

  /// Create a copy of GeneratedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratedPairingQrImplCopyWith<_$GeneratedPairingQrImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
