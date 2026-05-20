// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_keys.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AccountKeys {
  KeyDuo get ultimateKey => throw _privateConstructorUsedError;
  KeyDuo get deviceKey => throw _privateConstructorUsedError;
  String get symmetricKeyJwk => throw _privateConstructorUsedError;

  /// Create a copy of AccountKeys
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountKeysCopyWith<AccountKeys> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountKeysCopyWith<$Res> {
  factory $AccountKeysCopyWith(
    AccountKeys value,
    $Res Function(AccountKeys) then,
  ) = _$AccountKeysCopyWithImpl<$Res, AccountKeys>;
  @useResult
  $Res call({KeyDuo ultimateKey, KeyDuo deviceKey, String symmetricKeyJwk});
}

/// @nodoc
class _$AccountKeysCopyWithImpl<$Res, $Val extends AccountKeys>
    implements $AccountKeysCopyWith<$Res> {
  _$AccountKeysCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountKeys
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ultimateKey = null,
    Object? deviceKey = null,
    Object? symmetricKeyJwk = null,
  }) {
    return _then(
      _value.copyWith(
            ultimateKey: null == ultimateKey
                ? _value.ultimateKey
                : ultimateKey // ignore: cast_nullable_to_non_nullable
                      as KeyDuo,
            deviceKey: null == deviceKey
                ? _value.deviceKey
                : deviceKey // ignore: cast_nullable_to_non_nullable
                      as KeyDuo,
            symmetricKeyJwk: null == symmetricKeyJwk
                ? _value.symmetricKeyJwk
                : symmetricKeyJwk // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountKeysImplCopyWith<$Res>
    implements $AccountKeysCopyWith<$Res> {
  factory _$$AccountKeysImplCopyWith(
    _$AccountKeysImpl value,
    $Res Function(_$AccountKeysImpl) then,
  ) = __$$AccountKeysImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({KeyDuo ultimateKey, KeyDuo deviceKey, String symmetricKeyJwk});
}

/// @nodoc
class __$$AccountKeysImplCopyWithImpl<$Res>
    extends _$AccountKeysCopyWithImpl<$Res, _$AccountKeysImpl>
    implements _$$AccountKeysImplCopyWith<$Res> {
  __$$AccountKeysImplCopyWithImpl(
    _$AccountKeysImpl _value,
    $Res Function(_$AccountKeysImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountKeys
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ultimateKey = null,
    Object? deviceKey = null,
    Object? symmetricKeyJwk = null,
  }) {
    return _then(
      _$AccountKeysImpl(
        ultimateKey: null == ultimateKey
            ? _value.ultimateKey
            : ultimateKey // ignore: cast_nullable_to_non_nullable
                  as KeyDuo,
        deviceKey: null == deviceKey
            ? _value.deviceKey
            : deviceKey // ignore: cast_nullable_to_non_nullable
                  as KeyDuo,
        symmetricKeyJwk: null == symmetricKeyJwk
            ? _value.symmetricKeyJwk
            : symmetricKeyJwk // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AccountKeysImpl implements _AccountKeys {
  const _$AccountKeysImpl({
    required this.ultimateKey,
    required this.deviceKey,
    required this.symmetricKeyJwk,
  });

  @override
  final KeyDuo ultimateKey;
  @override
  final KeyDuo deviceKey;
  @override
  final String symmetricKeyJwk;

  @override
  String toString() {
    return 'AccountKeys(ultimateKey: $ultimateKey, deviceKey: $deviceKey, symmetricKeyJwk: $symmetricKeyJwk)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountKeysImpl &&
            (identical(other.ultimateKey, ultimateKey) ||
                other.ultimateKey == ultimateKey) &&
            (identical(other.deviceKey, deviceKey) ||
                other.deviceKey == deviceKey) &&
            (identical(other.symmetricKeyJwk, symmetricKeyJwk) ||
                other.symmetricKeyJwk == symmetricKeyJwk));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, ultimateKey, deviceKey, symmetricKeyJwk);

  /// Create a copy of AccountKeys
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountKeysImplCopyWith<_$AccountKeysImpl> get copyWith =>
      __$$AccountKeysImplCopyWithImpl<_$AccountKeysImpl>(this, _$identity);
}

abstract class _AccountKeys implements AccountKeys {
  const factory _AccountKeys({
    required final KeyDuo ultimateKey,
    required final KeyDuo deviceKey,
    required final String symmetricKeyJwk,
  }) = _$AccountKeysImpl;

  @override
  KeyDuo get ultimateKey;
  @override
  KeyDuo get deviceKey;
  @override
  String get symmetricKeyJwk;

  /// Create a copy of AccountKeys
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountKeysImplCopyWith<_$AccountKeysImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
