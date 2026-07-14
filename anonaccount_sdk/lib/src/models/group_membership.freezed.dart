// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupMembership _$GroupMembershipFromJson(Map<String, dynamic> json) {
  return _GroupMembership.fromJson(json);
}

/// @nodoc
mixin _$GroupMembership {
  String get groupId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
  UuidValue get memberId => throw _privateConstructorUsedError; // NEW — the GroupMember row id, needed by leaveGroup/removeGroupMember
  @_GroupMemberRoleConverter()
  GroupMemberRole get role => throw _privateConstructorUsedError;
  String get encryptedDataKey => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  bool get isRevoked => throw _privateConstructorUsedError;

  /// Serializes this GroupMembership to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupMembershipCopyWith<GroupMembership> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMembershipCopyWith<$Res> {
  factory $GroupMembershipCopyWith(
    GroupMembership value,
    $Res Function(GroupMembership) then,
  ) = _$GroupMembershipCopyWithImpl<$Res, GroupMembership>;
  @useResult
  $Res call({
    String groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    UuidValue memberId,
    @_GroupMemberRoleConverter() GroupMemberRole role,
    String encryptedDataKey,
    DateTime joinedAt,
    bool isRevoked,
  });
}

/// @nodoc
class _$GroupMembershipCopyWithImpl<$Res, $Val extends GroupMembership>
    implements $GroupMembershipCopyWith<$Res> {
  _$GroupMembershipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? memberId = null,
    Object? role = null,
    Object? encryptedDataKey = null,
    Object? joinedAt = null,
    Object? isRevoked = null,
  }) {
    return _then(
      _value.copyWith(
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as UuidValue,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as GroupMemberRole,
            encryptedDataKey: null == encryptedDataKey
                ? _value.encryptedDataKey
                : encryptedDataKey // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRevoked: null == isRevoked
                ? _value.isRevoked
                : isRevoked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupMembershipImplCopyWith<$Res>
    implements $GroupMembershipCopyWith<$Res> {
  factory _$$GroupMembershipImplCopyWith(
    _$GroupMembershipImpl value,
    $Res Function(_$GroupMembershipImpl) then,
  ) = __$$GroupMembershipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    UuidValue memberId,
    @_GroupMemberRoleConverter() GroupMemberRole role,
    String encryptedDataKey,
    DateTime joinedAt,
    bool isRevoked,
  });
}

/// @nodoc
class __$$GroupMembershipImplCopyWithImpl<$Res>
    extends _$GroupMembershipCopyWithImpl<$Res, _$GroupMembershipImpl>
    implements _$$GroupMembershipImplCopyWith<$Res> {
  __$$GroupMembershipImplCopyWithImpl(
    _$GroupMembershipImpl _value,
    $Res Function(_$GroupMembershipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? memberId = null,
    Object? role = null,
    Object? encryptedDataKey = null,
    Object? joinedAt = null,
    Object? isRevoked = null,
  }) {
    return _then(
      _$GroupMembershipImpl(
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as UuidValue,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as GroupMemberRole,
        encryptedDataKey: null == encryptedDataKey
            ? _value.encryptedDataKey
            : encryptedDataKey // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRevoked: null == isRevoked
            ? _value.isRevoked
            : isRevoked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMembershipImpl implements _GroupMembership {
  const _$GroupMembershipImpl({
    required this.groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    required this.memberId,
    @_GroupMemberRoleConverter() required this.role,
    required this.encryptedDataKey,
    required this.joinedAt,
    required this.isRevoked,
  });

  factory _$GroupMembershipImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMembershipImplFromJson(json);

  @override
  final String groupId;
  @override
  @JsonKey(fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
  final UuidValue memberId;
  // NEW — the GroupMember row id, needed by leaveGroup/removeGroupMember
  @override
  @_GroupMemberRoleConverter()
  final GroupMemberRole role;
  @override
  final String encryptedDataKey;
  @override
  final DateTime joinedAt;
  @override
  final bool isRevoked;

  @override
  String toString() {
    return 'GroupMembership(groupId: $groupId, memberId: $memberId, role: $role, encryptedDataKey: $encryptedDataKey, joinedAt: $joinedAt, isRevoked: $isRevoked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMembershipImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.encryptedDataKey, encryptedDataKey) ||
                other.encryptedDataKey == encryptedDataKey) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isRevoked, isRevoked) ||
                other.isRevoked == isRevoked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    groupId,
    memberId,
    role,
    encryptedDataKey,
    joinedAt,
    isRevoked,
  );

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMembershipImplCopyWith<_$GroupMembershipImpl> get copyWith =>
      __$$GroupMembershipImplCopyWithImpl<_$GroupMembershipImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMembershipImplToJson(this);
  }
}

abstract class _GroupMembership implements GroupMembership {
  const factory _GroupMembership({
    required final String groupId,
    @JsonKey(
      fromJson: UuidValueJsonExtension.fromJson,
      toJson: _uuidValueToJson,
    )
    required final UuidValue memberId,
    @_GroupMemberRoleConverter() required final GroupMemberRole role,
    required final String encryptedDataKey,
    required final DateTime joinedAt,
    required final bool isRevoked,
  }) = _$GroupMembershipImpl;

  factory _GroupMembership.fromJson(Map<String, dynamic> json) =
      _$GroupMembershipImpl.fromJson;

  @override
  String get groupId;
  @override
  @JsonKey(fromJson: UuidValueJsonExtension.fromJson, toJson: _uuidValueToJson)
  UuidValue get memberId; // NEW — the GroupMember row id, needed by leaveGroup/removeGroupMember
  @override
  @_GroupMemberRoleConverter()
  GroupMemberRole get role;
  @override
  String get encryptedDataKey;
  @override
  DateTime get joinedAt;
  @override
  bool get isRevoked;

  /// Create a copy of GroupMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupMembershipImplCopyWith<_$GroupMembershipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
