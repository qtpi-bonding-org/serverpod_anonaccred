// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovered_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecoveredMembership {

 String get groupId; UuidValue get memberId; bool get recovered; bool? get ownerKeyRecovered;
/// Create a copy of RecoveredMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveredMembershipCopyWith<RecoveredMembership> get copyWith => _$RecoveredMembershipCopyWithImpl<RecoveredMembership>(this as RecoveredMembership, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveredMembership&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recovered, recovered) || other.recovered == recovered)&&(identical(other.ownerKeyRecovered, ownerKeyRecovered) || other.ownerKeyRecovered == ownerKeyRecovered));
}


@override
int get hashCode => Object.hash(runtimeType,groupId,memberId,recovered,ownerKeyRecovered);

@override
String toString() {
  return 'RecoveredMembership(groupId: $groupId, memberId: $memberId, recovered: $recovered, ownerKeyRecovered: $ownerKeyRecovered)';
}


}

/// @nodoc
abstract mixin class $RecoveredMembershipCopyWith<$Res>  {
  factory $RecoveredMembershipCopyWith(RecoveredMembership value, $Res Function(RecoveredMembership) _then) = _$RecoveredMembershipCopyWithImpl;
@useResult
$Res call({
 String groupId, UuidValue memberId, bool recovered, bool? ownerKeyRecovered
});




}
/// @nodoc
class _$RecoveredMembershipCopyWithImpl<$Res>
    implements $RecoveredMembershipCopyWith<$Res> {
  _$RecoveredMembershipCopyWithImpl(this._self, this._then);

  final RecoveredMembership _self;
  final $Res Function(RecoveredMembership) _then;

/// Create a copy of RecoveredMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? memberId = null,Object? recovered = null,Object? ownerKeyRecovered = freezed,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as UuidValue,recovered: null == recovered ? _self.recovered : recovered // ignore: cast_nullable_to_non_nullable
as bool,ownerKeyRecovered: freezed == ownerKeyRecovered ? _self.ownerKeyRecovered : ownerKeyRecovered // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveredMembership].
extension RecoveredMembershipPatterns on RecoveredMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveredMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveredMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveredMembership value)  $default,){
final _that = this;
switch (_that) {
case _RecoveredMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveredMembership value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveredMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  UuidValue memberId,  bool recovered,  bool? ownerKeyRecovered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveredMembership() when $default != null:
return $default(_that.groupId,_that.memberId,_that.recovered,_that.ownerKeyRecovered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  UuidValue memberId,  bool recovered,  bool? ownerKeyRecovered)  $default,) {final _that = this;
switch (_that) {
case _RecoveredMembership():
return $default(_that.groupId,_that.memberId,_that.recovered,_that.ownerKeyRecovered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  UuidValue memberId,  bool recovered,  bool? ownerKeyRecovered)?  $default,) {final _that = this;
switch (_that) {
case _RecoveredMembership() when $default != null:
return $default(_that.groupId,_that.memberId,_that.recovered,_that.ownerKeyRecovered);case _:
  return null;

}
}

}

/// @nodoc


class _RecoveredMembership implements RecoveredMembership {
  const _RecoveredMembership({required this.groupId, required this.memberId, required this.recovered, required this.ownerKeyRecovered});
  

@override final  String groupId;
@override final  UuidValue memberId;
@override final  bool recovered;
@override final  bool? ownerKeyRecovered;

/// Create a copy of RecoveredMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveredMembershipCopyWith<_RecoveredMembership> get copyWith => __$RecoveredMembershipCopyWithImpl<_RecoveredMembership>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveredMembership&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recovered, recovered) || other.recovered == recovered)&&(identical(other.ownerKeyRecovered, ownerKeyRecovered) || other.ownerKeyRecovered == ownerKeyRecovered));
}


@override
int get hashCode => Object.hash(runtimeType,groupId,memberId,recovered,ownerKeyRecovered);

@override
String toString() {
  return 'RecoveredMembership(groupId: $groupId, memberId: $memberId, recovered: $recovered, ownerKeyRecovered: $ownerKeyRecovered)';
}


}

/// @nodoc
abstract mixin class _$RecoveredMembershipCopyWith<$Res> implements $RecoveredMembershipCopyWith<$Res> {
  factory _$RecoveredMembershipCopyWith(_RecoveredMembership value, $Res Function(_RecoveredMembership) _then) = __$RecoveredMembershipCopyWithImpl;
@override @useResult
$Res call({
 String groupId, UuidValue memberId, bool recovered, bool? ownerKeyRecovered
});




}
/// @nodoc
class __$RecoveredMembershipCopyWithImpl<$Res>
    implements _$RecoveredMembershipCopyWith<$Res> {
  __$RecoveredMembershipCopyWithImpl(this._self, this._then);

  final _RecoveredMembership _self;
  final $Res Function(_RecoveredMembership) _then;

/// Create a copy of RecoveredMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? memberId = null,Object? recovered = null,Object? ownerKeyRecovered = freezed,}) {
  return _then(_RecoveredMembership(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as UuidValue,recovered: null == recovered ? _self.recovered : recovered // ignore: cast_nullable_to_non_nullable
as bool,ownerKeyRecovered: freezed == ownerKeyRecovered ? _self.ownerKeyRecovered : ownerKeyRecovered // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
