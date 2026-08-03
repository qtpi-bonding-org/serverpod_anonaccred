// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_keys.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountKeys {

 KeyDuo get ultimateKey; KeyDuo get deviceKey; String get symmetricKeyJwk;
/// Create a copy of AccountKeys
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountKeysCopyWith<AccountKeys> get copyWith => _$AccountKeysCopyWithImpl<AccountKeys>(this as AccountKeys, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountKeys&&(identical(other.ultimateKey, ultimateKey) || other.ultimateKey == ultimateKey)&&(identical(other.deviceKey, deviceKey) || other.deviceKey == deviceKey)&&(identical(other.symmetricKeyJwk, symmetricKeyJwk) || other.symmetricKeyJwk == symmetricKeyJwk));
}


@override
int get hashCode => Object.hash(runtimeType,ultimateKey,deviceKey,symmetricKeyJwk);



}

/// @nodoc
abstract mixin class $AccountKeysCopyWith<$Res>  {
  factory $AccountKeysCopyWith(AccountKeys value, $Res Function(AccountKeys) _then) = _$AccountKeysCopyWithImpl;
@useResult
$Res call({
 KeyDuo ultimateKey, KeyDuo deviceKey, String symmetricKeyJwk
});




}
/// @nodoc
class _$AccountKeysCopyWithImpl<$Res>
    implements $AccountKeysCopyWith<$Res> {
  _$AccountKeysCopyWithImpl(this._self, this._then);

  final AccountKeys _self;
  final $Res Function(AccountKeys) _then;

/// Create a copy of AccountKeys
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ultimateKey = null,Object? deviceKey = null,Object? symmetricKeyJwk = null,}) {
  return _then(_self.copyWith(
ultimateKey: null == ultimateKey ? _self.ultimateKey : ultimateKey // ignore: cast_nullable_to_non_nullable
as KeyDuo,deviceKey: null == deviceKey ? _self.deviceKey : deviceKey // ignore: cast_nullable_to_non_nullable
as KeyDuo,symmetricKeyJwk: null == symmetricKeyJwk ? _self.symmetricKeyJwk : symmetricKeyJwk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountKeys].
extension AccountKeysPatterns on AccountKeys {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountKeys value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountKeys() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountKeys value)  $default,){
final _that = this;
switch (_that) {
case _AccountKeys():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountKeys value)?  $default,){
final _that = this;
switch (_that) {
case _AccountKeys() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KeyDuo ultimateKey,  KeyDuo deviceKey,  String symmetricKeyJwk)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountKeys() when $default != null:
return $default(_that.ultimateKey,_that.deviceKey,_that.symmetricKeyJwk);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KeyDuo ultimateKey,  KeyDuo deviceKey,  String symmetricKeyJwk)  $default,) {final _that = this;
switch (_that) {
case _AccountKeys():
return $default(_that.ultimateKey,_that.deviceKey,_that.symmetricKeyJwk);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KeyDuo ultimateKey,  KeyDuo deviceKey,  String symmetricKeyJwk)?  $default,) {final _that = this;
switch (_that) {
case _AccountKeys() when $default != null:
return $default(_that.ultimateKey,_that.deviceKey,_that.symmetricKeyJwk);case _:
  return null;

}
}

}

/// @nodoc


class _AccountKeys extends AccountKeys {
  const _AccountKeys({required this.ultimateKey, required this.deviceKey, required this.symmetricKeyJwk}): super._();
  

@override final  KeyDuo ultimateKey;
@override final  KeyDuo deviceKey;
@override final  String symmetricKeyJwk;

/// Create a copy of AccountKeys
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountKeysCopyWith<_AccountKeys> get copyWith => __$AccountKeysCopyWithImpl<_AccountKeys>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountKeys&&(identical(other.ultimateKey, ultimateKey) || other.ultimateKey == ultimateKey)&&(identical(other.deviceKey, deviceKey) || other.deviceKey == deviceKey)&&(identical(other.symmetricKeyJwk, symmetricKeyJwk) || other.symmetricKeyJwk == symmetricKeyJwk));
}


@override
int get hashCode => Object.hash(runtimeType,ultimateKey,deviceKey,symmetricKeyJwk);



}

/// @nodoc
abstract mixin class _$AccountKeysCopyWith<$Res> implements $AccountKeysCopyWith<$Res> {
  factory _$AccountKeysCopyWith(_AccountKeys value, $Res Function(_AccountKeys) _then) = __$AccountKeysCopyWithImpl;
@override @useResult
$Res call({
 KeyDuo ultimateKey, KeyDuo deviceKey, String symmetricKeyJwk
});




}
/// @nodoc
class __$AccountKeysCopyWithImpl<$Res>
    implements _$AccountKeysCopyWith<$Res> {
  __$AccountKeysCopyWithImpl(this._self, this._then);

  final _AccountKeys _self;
  final $Res Function(_AccountKeys) _then;

/// Create a copy of AccountKeys
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ultimateKey = null,Object? deviceKey = null,Object? symmetricKeyJwk = null,}) {
  return _then(_AccountKeys(
ultimateKey: null == ultimateKey ? _self.ultimateKey : ultimateKey // ignore: cast_nullable_to_non_nullable
as KeyDuo,deviceKey: null == deviceKey ? _self.deviceKey : deviceKey // ignore: cast_nullable_to_non_nullable
as KeyDuo,symmetricKeyJwk: null == symmetricKeyJwk ? _self.symmetricKeyJwk : symmetricKeyJwk // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
