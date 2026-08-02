// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupMembership {
  String get groupId;
  @JsonKey(fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
  UuidValue get memberId;
  @_GroupMemberRoleConverter()
  GroupMemberRole get role;
  String get memberSigningPublicKeyHex;
  String get memberEncryptedDataKey;
  String? get deviceEncryptedDataKey;
  DateTime get joinedAt;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupMembershipCopyWith<GroupMembership> get copyWith =>
      _$GroupMembershipCopyWithImpl<GroupMembership>(
          this as GroupMembership, _$identity);

  /// Serializes this GroupMembership to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupMembership &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.memberSigningPublicKeyHex,
                    memberSigningPublicKeyHex) ||
                other.memberSigningPublicKeyHex == memberSigningPublicKeyHex) &&
            (identical(other.memberEncryptedDataKey, memberEncryptedDataKey) ||
                other.memberEncryptedDataKey == memberEncryptedDataKey) &&
            (identical(other.deviceEncryptedDataKey, deviceEncryptedDataKey) ||
                other.deviceEncryptedDataKey == deviceEncryptedDataKey) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      groupId,
      memberId,
      role,
      memberSigningPublicKeyHex,
      memberEncryptedDataKey,
      deviceEncryptedDataKey,
      joinedAt);

  @override
  String toString() {
    return 'GroupMembership(groupId: $groupId, memberId: $memberId, role: $role, memberSigningPublicKeyHex: $memberSigningPublicKeyHex, memberEncryptedDataKey: $memberEncryptedDataKey, deviceEncryptedDataKey: $deviceEncryptedDataKey, joinedAt: $joinedAt)';
  }
}

/// @nodoc
abstract mixin class $GroupMembershipCopyWith<$Res> {
  factory $GroupMembershipCopyWith(
          GroupMembership value, $Res Function(GroupMembership) _then) =
      _$GroupMembershipCopyWithImpl;
  @useResult
  $Res call(
      {String groupId,
      @JsonKey(
          fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
      UuidValue memberId,
      @_GroupMemberRoleConverter() GroupMemberRole role,
      String memberSigningPublicKeyHex,
      String memberEncryptedDataKey,
      String? deviceEncryptedDataKey,
      DateTime joinedAt});
}

/// @nodoc
class _$GroupMembershipCopyWithImpl<$Res>
    implements $GroupMembershipCopyWith<$Res> {
  _$GroupMembershipCopyWithImpl(this._self, this._then);

  final GroupMembership _self;
  final $Res Function(GroupMembership) _then;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? memberId = null,
    Object? role = null,
    Object? memberSigningPublicKeyHex = null,
    Object? memberEncryptedDataKey = null,
    Object? deviceEncryptedDataKey = freezed,
    Object? joinedAt = null,
  }) {
    return _then(_self.copyWith(
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _self.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as UuidValue,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as GroupMemberRole,
      memberSigningPublicKeyHex: null == memberSigningPublicKeyHex
          ? _self.memberSigningPublicKeyHex
          : memberSigningPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      memberEncryptedDataKey: null == memberEncryptedDataKey
          ? _self.memberEncryptedDataKey
          : memberEncryptedDataKey // ignore: cast_nullable_to_non_nullable
              as String,
      deviceEncryptedDataKey: freezed == deviceEncryptedDataKey
          ? _self.deviceEncryptedDataKey
          : deviceEncryptedDataKey // ignore: cast_nullable_to_non_nullable
              as String?,
      joinedAt: null == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupMembership].
extension GroupMembershipPatterns on GroupMembership {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GroupMembership value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMembership() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GroupMembership value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembership():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GroupMembership value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembership() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String groupId,
            @JsonKey(
                fromJson: UuidValueJsonExtension.fromJson,
                toJson: _uuidValueToJson)
            UuidValue memberId,
            @_GroupMemberRoleConverter() GroupMemberRole role,
            String memberSigningPublicKeyHex,
            String memberEncryptedDataKey,
            String? deviceEncryptedDataKey,
            DateTime joinedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMembership() when $default != null:
        return $default(
            _that.groupId,
            _that.memberId,
            _that.role,
            _that.memberSigningPublicKeyHex,
            _that.memberEncryptedDataKey,
            _that.deviceEncryptedDataKey,
            _that.joinedAt);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String groupId,
            @JsonKey(
                fromJson: UuidValueJsonExtension.fromJson,
                toJson: _uuidValueToJson)
            UuidValue memberId,
            @_GroupMemberRoleConverter() GroupMemberRole role,
            String memberSigningPublicKeyHex,
            String memberEncryptedDataKey,
            String? deviceEncryptedDataKey,
            DateTime joinedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembership():
        return $default(
            _that.groupId,
            _that.memberId,
            _that.role,
            _that.memberSigningPublicKeyHex,
            _that.memberEncryptedDataKey,
            _that.deviceEncryptedDataKey,
            _that.joinedAt);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String groupId,
            @JsonKey(
                fromJson: UuidValueJsonExtension.fromJson,
                toJson: _uuidValueToJson)
            UuidValue memberId,
            @_GroupMemberRoleConverter() GroupMemberRole role,
            String memberSigningPublicKeyHex,
            String memberEncryptedDataKey,
            String? deviceEncryptedDataKey,
            DateTime joinedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMembership() when $default != null:
        return $default(
            _that.groupId,
            _that.memberId,
            _that.role,
            _that.memberSigningPublicKeyHex,
            _that.memberEncryptedDataKey,
            _that.deviceEncryptedDataKey,
            _that.joinedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GroupMembership implements GroupMembership {
  const _GroupMembership(
      {required this.groupId,
      @JsonKey(
          fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
      required this.memberId,
      @_GroupMemberRoleConverter() required this.role,
      required this.memberSigningPublicKeyHex,
      required this.memberEncryptedDataKey,
      required this.deviceEncryptedDataKey,
      required this.joinedAt});
  factory _GroupMembership.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipFromJson(json);

  @override
  final String groupId;
  @override
  @JsonKey(fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
  final UuidValue memberId;
  @override
  @_GroupMemberRoleConverter()
  final GroupMemberRole role;
  @override
  final String memberSigningPublicKeyHex;
  @override
  final String memberEncryptedDataKey;
  @override
  final String? deviceEncryptedDataKey;
  @override
  final DateTime joinedAt;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupMembershipCopyWith<_GroupMembership> get copyWith =>
      __$GroupMembershipCopyWithImpl<_GroupMembership>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupMembershipToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupMembership &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.memberSigningPublicKeyHex,
                    memberSigningPublicKeyHex) ||
                other.memberSigningPublicKeyHex == memberSigningPublicKeyHex) &&
            (identical(other.memberEncryptedDataKey, memberEncryptedDataKey) ||
                other.memberEncryptedDataKey == memberEncryptedDataKey) &&
            (identical(other.deviceEncryptedDataKey, deviceEncryptedDataKey) ||
                other.deviceEncryptedDataKey == deviceEncryptedDataKey) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      groupId,
      memberId,
      role,
      memberSigningPublicKeyHex,
      memberEncryptedDataKey,
      deviceEncryptedDataKey,
      joinedAt);

  @override
  String toString() {
    return 'GroupMembership(groupId: $groupId, memberId: $memberId, role: $role, memberSigningPublicKeyHex: $memberSigningPublicKeyHex, memberEncryptedDataKey: $memberEncryptedDataKey, deviceEncryptedDataKey: $deviceEncryptedDataKey, joinedAt: $joinedAt)';
  }
}

/// @nodoc
abstract mixin class _$GroupMembershipCopyWith<$Res>
    implements $GroupMembershipCopyWith<$Res> {
  factory _$GroupMembershipCopyWith(
          _GroupMembership value, $Res Function(_GroupMembership) _then) =
      __$GroupMembershipCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String groupId,
      @JsonKey(
          fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
      UuidValue memberId,
      @_GroupMemberRoleConverter() GroupMemberRole role,
      String memberSigningPublicKeyHex,
      String memberEncryptedDataKey,
      String? deviceEncryptedDataKey,
      DateTime joinedAt});
}

/// @nodoc
class __$GroupMembershipCopyWithImpl<$Res>
    implements _$GroupMembershipCopyWith<$Res> {
  __$GroupMembershipCopyWithImpl(this._self, this._then);

  final _GroupMembership _self;
  final $Res Function(_GroupMembership) _then;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? groupId = null,
    Object? memberId = null,
    Object? role = null,
    Object? memberSigningPublicKeyHex = null,
    Object? memberEncryptedDataKey = null,
    Object? deviceEncryptedDataKey = freezed,
    Object? joinedAt = null,
  }) {
    return _then(_GroupMembership(
      groupId: null == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _self.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as UuidValue,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as GroupMemberRole,
      memberSigningPublicKeyHex: null == memberSigningPublicKeyHex
          ? _self.memberSigningPublicKeyHex
          : memberSigningPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      memberEncryptedDataKey: null == memberEncryptedDataKey
          ? _self.memberEncryptedDataKey
          : memberEncryptedDataKey // ignore: cast_nullable_to_non_nullable
              as String,
      deviceEncryptedDataKey: freezed == deviceEncryptedDataKey
          ? _self.deviceEncryptedDataKey
          : deviceEncryptedDataKey // ignore: cast_nullable_to_non_nullable
              as String?,
      joinedAt: null == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
