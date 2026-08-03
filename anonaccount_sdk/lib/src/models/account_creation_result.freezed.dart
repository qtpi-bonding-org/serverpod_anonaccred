// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_creation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountCreationResult {

 RegistrationPayload get payload;
/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCreationResultCopyWith<AccountCreationResult> get copyWith => _$AccountCreationResultCopyWithImpl<AccountCreationResult>(this as AccountCreationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountCreationResult&&(identical(other.payload, payload) || other.payload == payload));
}


@override
int get hashCode => Object.hash(runtimeType,payload);

@override
String toString() {
  return 'AccountCreationResult(payload: $payload)';
}


}

/// @nodoc
abstract mixin class $AccountCreationResultCopyWith<$Res>  {
  factory $AccountCreationResultCopyWith(AccountCreationResult value, $Res Function(AccountCreationResult) _then) = _$AccountCreationResultCopyWithImpl;
@useResult
$Res call({
 RegistrationPayload payload
});


$RegistrationPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class _$AccountCreationResultCopyWithImpl<$Res>
    implements $AccountCreationResultCopyWith<$Res> {
  _$AccountCreationResultCopyWithImpl(this._self, this._then);

  final AccountCreationResult _self;
  final $Res Function(AccountCreationResult) _then;

/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payload = null,}) {
  return _then(_self.copyWith(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as RegistrationPayload,
  ));
}
/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegistrationPayloadCopyWith<$Res> get payload {
  
  return $RegistrationPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountCreationResult].
extension AccountCreationResultPatterns on AccountCreationResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountCreationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountCreationResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountCreationResult value)  $default,){
final _that = this;
switch (_that) {
case _AccountCreationResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountCreationResult value)?  $default,){
final _that = this;
switch (_that) {
case _AccountCreationResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegistrationPayload payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountCreationResult() when $default != null:
return $default(_that.payload);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegistrationPayload payload)  $default,) {final _that = this;
switch (_that) {
case _AccountCreationResult():
return $default(_that.payload);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegistrationPayload payload)?  $default,) {final _that = this;
switch (_that) {
case _AccountCreationResult() when $default != null:
return $default(_that.payload);case _:
  return null;

}
}

}

/// @nodoc


class _AccountCreationResult implements AccountCreationResult {
  const _AccountCreationResult({required this.payload});
  

@override final  RegistrationPayload payload;

/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCreationResultCopyWith<_AccountCreationResult> get copyWith => __$AccountCreationResultCopyWithImpl<_AccountCreationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountCreationResult&&(identical(other.payload, payload) || other.payload == payload));
}


@override
int get hashCode => Object.hash(runtimeType,payload);

@override
String toString() {
  return 'AccountCreationResult(payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$AccountCreationResultCopyWith<$Res> implements $AccountCreationResultCopyWith<$Res> {
  factory _$AccountCreationResultCopyWith(_AccountCreationResult value, $Res Function(_AccountCreationResult) _then) = __$AccountCreationResultCopyWithImpl;
@override @useResult
$Res call({
 RegistrationPayload payload
});


@override $RegistrationPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class __$AccountCreationResultCopyWithImpl<$Res>
    implements _$AccountCreationResultCopyWith<$Res> {
  __$AccountCreationResultCopyWithImpl(this._self, this._then);

  final _AccountCreationResult _self;
  final $Res Function(_AccountCreationResult) _then;

/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payload = null,}) {
  return _then(_AccountCreationResult(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as RegistrationPayload,
  ));
}

/// Create a copy of AccountCreationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegistrationPayloadCopyWith<$Res> get payload {
  
  return $RegistrationPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}

// dart format on
