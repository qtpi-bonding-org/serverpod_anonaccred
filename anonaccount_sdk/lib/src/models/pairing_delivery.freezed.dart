// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_delivery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PairingDelivery {

 String get encryptedDataKey; String get ultimateEncryptionPublicKeyHex; String get ultimateSigningPublicKeyHex;
/// Create a copy of PairingDelivery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingDeliveryCopyWith<PairingDelivery> get copyWith => _$PairingDeliveryCopyWithImpl<PairingDelivery>(this as PairingDelivery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingDelivery&&(identical(other.encryptedDataKey, encryptedDataKey) || other.encryptedDataKey == encryptedDataKey)&&(identical(other.ultimateEncryptionPublicKeyHex, ultimateEncryptionPublicKeyHex) || other.ultimateEncryptionPublicKeyHex == ultimateEncryptionPublicKeyHex)&&(identical(other.ultimateSigningPublicKeyHex, ultimateSigningPublicKeyHex) || other.ultimateSigningPublicKeyHex == ultimateSigningPublicKeyHex));
}


@override
int get hashCode => Object.hash(runtimeType,encryptedDataKey,ultimateEncryptionPublicKeyHex,ultimateSigningPublicKeyHex);

@override
String toString() {
  return 'PairingDelivery(encryptedDataKey: $encryptedDataKey, ultimateEncryptionPublicKeyHex: $ultimateEncryptionPublicKeyHex, ultimateSigningPublicKeyHex: $ultimateSigningPublicKeyHex)';
}


}

/// @nodoc
abstract mixin class $PairingDeliveryCopyWith<$Res>  {
  factory $PairingDeliveryCopyWith(PairingDelivery value, $Res Function(PairingDelivery) _then) = _$PairingDeliveryCopyWithImpl;
@useResult
$Res call({
 String encryptedDataKey, String ultimateEncryptionPublicKeyHex, String ultimateSigningPublicKeyHex
});




}
/// @nodoc
class _$PairingDeliveryCopyWithImpl<$Res>
    implements $PairingDeliveryCopyWith<$Res> {
  _$PairingDeliveryCopyWithImpl(this._self, this._then);

  final PairingDelivery _self;
  final $Res Function(PairingDelivery) _then;

/// Create a copy of PairingDelivery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encryptedDataKey = null,Object? ultimateEncryptionPublicKeyHex = null,Object? ultimateSigningPublicKeyHex = null,}) {
  return _then(_self.copyWith(
encryptedDataKey: null == encryptedDataKey ? _self.encryptedDataKey : encryptedDataKey // ignore: cast_nullable_to_non_nullable
as String,ultimateEncryptionPublicKeyHex: null == ultimateEncryptionPublicKeyHex ? _self.ultimateEncryptionPublicKeyHex : ultimateEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
as String,ultimateSigningPublicKeyHex: null == ultimateSigningPublicKeyHex ? _self.ultimateSigningPublicKeyHex : ultimateSigningPublicKeyHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingDelivery].
extension PairingDeliveryPatterns on PairingDelivery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingDelivery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingDelivery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingDelivery value)  $default,){
final _that = this;
switch (_that) {
case _PairingDelivery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingDelivery value)?  $default,){
final _that = this;
switch (_that) {
case _PairingDelivery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String encryptedDataKey,  String ultimateEncryptionPublicKeyHex,  String ultimateSigningPublicKeyHex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingDelivery() when $default != null:
return $default(_that.encryptedDataKey,_that.ultimateEncryptionPublicKeyHex,_that.ultimateSigningPublicKeyHex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String encryptedDataKey,  String ultimateEncryptionPublicKeyHex,  String ultimateSigningPublicKeyHex)  $default,) {final _that = this;
switch (_that) {
case _PairingDelivery():
return $default(_that.encryptedDataKey,_that.ultimateEncryptionPublicKeyHex,_that.ultimateSigningPublicKeyHex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String encryptedDataKey,  String ultimateEncryptionPublicKeyHex,  String ultimateSigningPublicKeyHex)?  $default,) {final _that = this;
switch (_that) {
case _PairingDelivery() when $default != null:
return $default(_that.encryptedDataKey,_that.ultimateEncryptionPublicKeyHex,_that.ultimateSigningPublicKeyHex);case _:
  return null;

}
}

}

/// @nodoc


class _PairingDelivery implements PairingDelivery {
  const _PairingDelivery({required this.encryptedDataKey, required this.ultimateEncryptionPublicKeyHex, required this.ultimateSigningPublicKeyHex});
  

@override final  String encryptedDataKey;
@override final  String ultimateEncryptionPublicKeyHex;
@override final  String ultimateSigningPublicKeyHex;

/// Create a copy of PairingDelivery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingDeliveryCopyWith<_PairingDelivery> get copyWith => __$PairingDeliveryCopyWithImpl<_PairingDelivery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingDelivery&&(identical(other.encryptedDataKey, encryptedDataKey) || other.encryptedDataKey == encryptedDataKey)&&(identical(other.ultimateEncryptionPublicKeyHex, ultimateEncryptionPublicKeyHex) || other.ultimateEncryptionPublicKeyHex == ultimateEncryptionPublicKeyHex)&&(identical(other.ultimateSigningPublicKeyHex, ultimateSigningPublicKeyHex) || other.ultimateSigningPublicKeyHex == ultimateSigningPublicKeyHex));
}


@override
int get hashCode => Object.hash(runtimeType,encryptedDataKey,ultimateEncryptionPublicKeyHex,ultimateSigningPublicKeyHex);

@override
String toString() {
  return 'PairingDelivery(encryptedDataKey: $encryptedDataKey, ultimateEncryptionPublicKeyHex: $ultimateEncryptionPublicKeyHex, ultimateSigningPublicKeyHex: $ultimateSigningPublicKeyHex)';
}


}

/// @nodoc
abstract mixin class _$PairingDeliveryCopyWith<$Res> implements $PairingDeliveryCopyWith<$Res> {
  factory _$PairingDeliveryCopyWith(_PairingDelivery value, $Res Function(_PairingDelivery) _then) = __$PairingDeliveryCopyWithImpl;
@override @useResult
$Res call({
 String encryptedDataKey, String ultimateEncryptionPublicKeyHex, String ultimateSigningPublicKeyHex
});




}
/// @nodoc
class __$PairingDeliveryCopyWithImpl<$Res>
    implements _$PairingDeliveryCopyWith<$Res> {
  __$PairingDeliveryCopyWithImpl(this._self, this._then);

  final _PairingDelivery _self;
  final $Res Function(_PairingDelivery) _then;

/// Create a copy of PairingDelivery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encryptedDataKey = null,Object? ultimateEncryptionPublicKeyHex = null,Object? ultimateSigningPublicKeyHex = null,}) {
  return _then(_PairingDelivery(
encryptedDataKey: null == encryptedDataKey ? _self.encryptedDataKey : encryptedDataKey // ignore: cast_nullable_to_non_nullable
as String,ultimateEncryptionPublicKeyHex: null == ultimateEncryptionPublicKeyHex ? _self.ultimateEncryptionPublicKeyHex : ultimateEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
as String,ultimateSigningPublicKeyHex: null == ultimateSigningPublicKeyHex ? _self.ultimateSigningPublicKeyHex : ultimateSigningPublicKeyHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
