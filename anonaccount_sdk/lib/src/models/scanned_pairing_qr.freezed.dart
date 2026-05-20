// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanned_pairing_qr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScannedPairingQr _$ScannedPairingQrFromJson(Map<String, dynamic> json) {
  return _ScannedPairingQr.fromJson(json);
}

/// @nodoc
mixin _$ScannedPairingQr {
  String get theirSigningPubkeyHex => throw _privateConstructorUsedError;
  String get theirEncryptionPubkeyJwk => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this ScannedPairingQr to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScannedPairingQrCopyWith<ScannedPairingQr> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScannedPairingQrCopyWith<$Res> {
  factory $ScannedPairingQrCopyWith(
    ScannedPairingQr value,
    $Res Function(ScannedPairingQr) then,
  ) = _$ScannedPairingQrCopyWithImpl<$Res, ScannedPairingQr>;
  @useResult
  $Res call({
    String theirSigningPubkeyHex,
    String theirEncryptionPubkeyJwk,
    String label,
  });
}

/// @nodoc
class _$ScannedPairingQrCopyWithImpl<$Res, $Val extends ScannedPairingQr>
    implements $ScannedPairingQrCopyWith<$Res> {
  _$ScannedPairingQrCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theirSigningPubkeyHex = null,
    Object? theirEncryptionPubkeyJwk = null,
    Object? label = null,
  }) {
    return _then(
      _value.copyWith(
            theirSigningPubkeyHex: null == theirSigningPubkeyHex
                ? _value.theirSigningPubkeyHex
                : theirSigningPubkeyHex // ignore: cast_nullable_to_non_nullable
                      as String,
            theirEncryptionPubkeyJwk: null == theirEncryptionPubkeyJwk
                ? _value.theirEncryptionPubkeyJwk
                : theirEncryptionPubkeyJwk // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScannedPairingQrImplCopyWith<$Res>
    implements $ScannedPairingQrCopyWith<$Res> {
  factory _$$ScannedPairingQrImplCopyWith(
    _$ScannedPairingQrImpl value,
    $Res Function(_$ScannedPairingQrImpl) then,
  ) = __$$ScannedPairingQrImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String theirSigningPubkeyHex,
    String theirEncryptionPubkeyJwk,
    String label,
  });
}

/// @nodoc
class __$$ScannedPairingQrImplCopyWithImpl<$Res>
    extends _$ScannedPairingQrCopyWithImpl<$Res, _$ScannedPairingQrImpl>
    implements _$$ScannedPairingQrImplCopyWith<$Res> {
  __$$ScannedPairingQrImplCopyWithImpl(
    _$ScannedPairingQrImpl _value,
    $Res Function(_$ScannedPairingQrImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theirSigningPubkeyHex = null,
    Object? theirEncryptionPubkeyJwk = null,
    Object? label = null,
  }) {
    return _then(
      _$ScannedPairingQrImpl(
        theirSigningPubkeyHex: null == theirSigningPubkeyHex
            ? _value.theirSigningPubkeyHex
            : theirSigningPubkeyHex // ignore: cast_nullable_to_non_nullable
                  as String,
        theirEncryptionPubkeyJwk: null == theirEncryptionPubkeyJwk
            ? _value.theirEncryptionPubkeyJwk
            : theirEncryptionPubkeyJwk // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScannedPairingQrImpl extends _ScannedPairingQr {
  const _$ScannedPairingQrImpl({
    required this.theirSigningPubkeyHex,
    required this.theirEncryptionPubkeyJwk,
    required this.label,
  }) : super._();

  factory _$ScannedPairingQrImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScannedPairingQrImplFromJson(json);

  @override
  final String theirSigningPubkeyHex;
  @override
  final String theirEncryptionPubkeyJwk;
  @override
  final String label;

  @override
  String toString() {
    return 'ScannedPairingQr(theirSigningPubkeyHex: $theirSigningPubkeyHex, theirEncryptionPubkeyJwk: $theirEncryptionPubkeyJwk, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScannedPairingQrImpl &&
            (identical(other.theirSigningPubkeyHex, theirSigningPubkeyHex) ||
                other.theirSigningPubkeyHex == theirSigningPubkeyHex) &&
            (identical(
                  other.theirEncryptionPubkeyJwk,
                  theirEncryptionPubkeyJwk,
                ) ||
                other.theirEncryptionPubkeyJwk == theirEncryptionPubkeyJwk) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    theirSigningPubkeyHex,
    theirEncryptionPubkeyJwk,
    label,
  );

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannedPairingQrImplCopyWith<_$ScannedPairingQrImpl> get copyWith =>
      __$$ScannedPairingQrImplCopyWithImpl<_$ScannedPairingQrImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScannedPairingQrImplToJson(this);
  }
}

abstract class _ScannedPairingQr extends ScannedPairingQr {
  const factory _ScannedPairingQr({
    required final String theirSigningPubkeyHex,
    required final String theirEncryptionPubkeyJwk,
    required final String label,
  }) = _$ScannedPairingQrImpl;
  const _ScannedPairingQr._() : super._();

  factory _ScannedPairingQr.fromJson(Map<String, dynamic> json) =
      _$ScannedPairingQrImpl.fromJson;

  @override
  String get theirSigningPubkeyHex;
  @override
  String get theirEncryptionPubkeyJwk;
  @override
  String get label;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScannedPairingQrImplCopyWith<_$ScannedPairingQrImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
