// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_pairing_qr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratedPairingQr {

 String get qrPayloadJson; String get signingPubkeyHex;
/// Create a copy of GeneratedPairingQr
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedPairingQrCopyWith<GeneratedPairingQr> get copyWith => _$GeneratedPairingQrCopyWithImpl<GeneratedPairingQr>(this as GeneratedPairingQr, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedPairingQr&&(identical(other.qrPayloadJson, qrPayloadJson) || other.qrPayloadJson == qrPayloadJson)&&(identical(other.signingPubkeyHex, signingPubkeyHex) || other.signingPubkeyHex == signingPubkeyHex));
}


@override
int get hashCode => Object.hash(runtimeType,qrPayloadJson,signingPubkeyHex);

@override
String toString() {
  return 'GeneratedPairingQr(qrPayloadJson: $qrPayloadJson, signingPubkeyHex: $signingPubkeyHex)';
}


}

/// @nodoc
abstract mixin class $GeneratedPairingQrCopyWith<$Res>  {
  factory $GeneratedPairingQrCopyWith(GeneratedPairingQr value, $Res Function(GeneratedPairingQr) _then) = _$GeneratedPairingQrCopyWithImpl;
@useResult
$Res call({
 String qrPayloadJson, String signingPubkeyHex
});




}
/// @nodoc
class _$GeneratedPairingQrCopyWithImpl<$Res>
    implements $GeneratedPairingQrCopyWith<$Res> {
  _$GeneratedPairingQrCopyWithImpl(this._self, this._then);

  final GeneratedPairingQr _self;
  final $Res Function(GeneratedPairingQr) _then;

/// Create a copy of GeneratedPairingQr
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qrPayloadJson = null,Object? signingPubkeyHex = null,}) {
  return _then(_self.copyWith(
qrPayloadJson: null == qrPayloadJson ? _self.qrPayloadJson : qrPayloadJson // ignore: cast_nullable_to_non_nullable
as String,signingPubkeyHex: null == signingPubkeyHex ? _self.signingPubkeyHex : signingPubkeyHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedPairingQr].
extension GeneratedPairingQrPatterns on GeneratedPairingQr {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedPairingQr value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedPairingQr() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedPairingQr value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedPairingQr():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedPairingQr value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedPairingQr() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String qrPayloadJson,  String signingPubkeyHex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedPairingQr() when $default != null:
return $default(_that.qrPayloadJson,_that.signingPubkeyHex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String qrPayloadJson,  String signingPubkeyHex)  $default,) {final _that = this;
switch (_that) {
case _GeneratedPairingQr():
return $default(_that.qrPayloadJson,_that.signingPubkeyHex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String qrPayloadJson,  String signingPubkeyHex)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedPairingQr() when $default != null:
return $default(_that.qrPayloadJson,_that.signingPubkeyHex);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedPairingQr implements GeneratedPairingQr {
  const _GeneratedPairingQr({required this.qrPayloadJson, required this.signingPubkeyHex});
  

@override final  String qrPayloadJson;
@override final  String signingPubkeyHex;

/// Create a copy of GeneratedPairingQr
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedPairingQrCopyWith<_GeneratedPairingQr> get copyWith => __$GeneratedPairingQrCopyWithImpl<_GeneratedPairingQr>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedPairingQr&&(identical(other.qrPayloadJson, qrPayloadJson) || other.qrPayloadJson == qrPayloadJson)&&(identical(other.signingPubkeyHex, signingPubkeyHex) || other.signingPubkeyHex == signingPubkeyHex));
}


@override
int get hashCode => Object.hash(runtimeType,qrPayloadJson,signingPubkeyHex);

@override
String toString() {
  return 'GeneratedPairingQr(qrPayloadJson: $qrPayloadJson, signingPubkeyHex: $signingPubkeyHex)';
}


}

/// @nodoc
abstract mixin class _$GeneratedPairingQrCopyWith<$Res> implements $GeneratedPairingQrCopyWith<$Res> {
  factory _$GeneratedPairingQrCopyWith(_GeneratedPairingQr value, $Res Function(_GeneratedPairingQr) _then) = __$GeneratedPairingQrCopyWithImpl;
@override @useResult
$Res call({
 String qrPayloadJson, String signingPubkeyHex
});




}
/// @nodoc
class __$GeneratedPairingQrCopyWithImpl<$Res>
    implements _$GeneratedPairingQrCopyWith<$Res> {
  __$GeneratedPairingQrCopyWithImpl(this._self, this._then);

  final _GeneratedPairingQr _self;
  final $Res Function(_GeneratedPairingQr) _then;

/// Create a copy of GeneratedPairingQr
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qrPayloadJson = null,Object? signingPubkeyHex = null,}) {
  return _then(_GeneratedPairingQr(
qrPayloadJson: null == qrPayloadJson ? _self.qrPayloadJson : qrPayloadJson // ignore: cast_nullable_to_non_nullable
as String,signingPubkeyHex: null == signingPubkeyHex ? _self.signingPubkeyHex : signingPubkeyHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
