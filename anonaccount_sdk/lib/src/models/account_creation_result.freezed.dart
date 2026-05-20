// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_creation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AccountCreationResult {
  AccountKeys get keys => throw _privateConstructorUsedError;
  RegistrationPayload get payload => throw _privateConstructorUsedError;

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountCreationResultCopyWith<AccountCreationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCreationResultCopyWith<$Res> {
  factory $AccountCreationResultCopyWith(
    AccountCreationResult value,
    $Res Function(AccountCreationResult) then,
  ) = _$AccountCreationResultCopyWithImpl<$Res, AccountCreationResult>;
  @useResult
  $Res call({AccountKeys keys, RegistrationPayload payload});

  $AccountKeysCopyWith<$Res> get keys;
  $RegistrationPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class _$AccountCreationResultCopyWithImpl<
  $Res,
  $Val extends AccountCreationResult
>
    implements $AccountCreationResultCopyWith<$Res> {
  _$AccountCreationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? keys = null, Object? payload = null}) {
    return _then(
      _value.copyWith(
            keys: null == keys
                ? _value.keys
                : keys // ignore: cast_nullable_to_non_nullable
                      as AccountKeys,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as RegistrationPayload,
          )
          as $Val,
    );
  }

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountKeysCopyWith<$Res> get keys {
    return $AccountKeysCopyWith<$Res>(_value.keys, (value) {
      return _then(_value.copyWith(keys: value) as $Val);
    });
  }

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RegistrationPayloadCopyWith<$Res> get payload {
    return $RegistrationPayloadCopyWith<$Res>(_value.payload, (value) {
      return _then(_value.copyWith(payload: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AccountCreationResultImplCopyWith<$Res>
    implements $AccountCreationResultCopyWith<$Res> {
  factory _$$AccountCreationResultImplCopyWith(
    _$AccountCreationResultImpl value,
    $Res Function(_$AccountCreationResultImpl) then,
  ) = __$$AccountCreationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AccountKeys keys, RegistrationPayload payload});

  @override
  $AccountKeysCopyWith<$Res> get keys;
  @override
  $RegistrationPayloadCopyWith<$Res> get payload;
}

/// @nodoc
class __$$AccountCreationResultImplCopyWithImpl<$Res>
    extends
        _$AccountCreationResultCopyWithImpl<$Res, _$AccountCreationResultImpl>
    implements _$$AccountCreationResultImplCopyWith<$Res> {
  __$$AccountCreationResultImplCopyWithImpl(
    _$AccountCreationResultImpl _value,
    $Res Function(_$AccountCreationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? keys = null, Object? payload = null}) {
    return _then(
      _$AccountCreationResultImpl(
        keys: null == keys
            ? _value.keys
            : keys // ignore: cast_nullable_to_non_nullable
                  as AccountKeys,
        payload: null == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as RegistrationPayload,
      ),
    );
  }
}

/// @nodoc

class _$AccountCreationResultImpl implements _AccountCreationResult {
  const _$AccountCreationResultImpl({
    required this.keys,
    required this.payload,
  });

  @override
  final AccountKeys keys;
  @override
  final RegistrationPayload payload;

  @override
  String toString() {
    return 'AccountCreationResult(keys: $keys, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountCreationResultImpl &&
            (identical(other.keys, keys) || other.keys == keys) &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @override
  int get hashCode => Object.hash(runtimeType, keys, payload);

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountCreationResultImplCopyWith<_$AccountCreationResultImpl>
  get copyWith =>
      __$$AccountCreationResultImplCopyWithImpl<_$AccountCreationResultImpl>(
        this,
        _$identity,
      );
}

abstract class _AccountCreationResult implements AccountCreationResult {
  const factory _AccountCreationResult({
    required final AccountKeys keys,
    required final RegistrationPayload payload,
  }) = _$AccountCreationResultImpl;

  @override
  AccountKeys get keys;
  @override
  RegistrationPayload get payload;

  /// Create a copy of AccountCreationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountCreationResultImplCopyWith<_$AccountCreationResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
