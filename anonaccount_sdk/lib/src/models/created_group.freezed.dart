// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'created_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CreatedGroup {
  String get groupId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  AesGcmSecretKey get groupDataKey => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of CreatedGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatedGroupCopyWith<CreatedGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatedGroupCopyWith<$Res> {
  factory $CreatedGroupCopyWith(
    CreatedGroup value,
    $Res Function(CreatedGroup) then,
  ) = _$CreatedGroupCopyWithImpl<$Res, CreatedGroup>;
  @useResult
  $Res call({
    String groupId,
    String displayName,
    AesGcmSecretKey groupDataKey,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CreatedGroupCopyWithImpl<$Res, $Val extends CreatedGroup>
    implements $CreatedGroupCopyWith<$Res> {
  _$CreatedGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatedGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? displayName = null,
    Object? groupDataKey = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            groupDataKey: null == groupDataKey
                ? _value.groupDataKey
                : groupDataKey // ignore: cast_nullable_to_non_nullable
                      as AesGcmSecretKey,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreatedGroupImplCopyWith<$Res>
    implements $CreatedGroupCopyWith<$Res> {
  factory _$$CreatedGroupImplCopyWith(
    _$CreatedGroupImpl value,
    $Res Function(_$CreatedGroupImpl) then,
  ) = __$$CreatedGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String groupId,
    String displayName,
    AesGcmSecretKey groupDataKey,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CreatedGroupImplCopyWithImpl<$Res>
    extends _$CreatedGroupCopyWithImpl<$Res, _$CreatedGroupImpl>
    implements _$$CreatedGroupImplCopyWith<$Res> {
  __$$CreatedGroupImplCopyWithImpl(
    _$CreatedGroupImpl _value,
    $Res Function(_$CreatedGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreatedGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? displayName = null,
    Object? groupDataKey = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CreatedGroupImpl(
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        groupDataKey: null == groupDataKey
            ? _value.groupDataKey
            : groupDataKey // ignore: cast_nullable_to_non_nullable
                  as AesGcmSecretKey,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$CreatedGroupImpl implements _CreatedGroup {
  const _$CreatedGroupImpl({
    required this.groupId,
    required this.displayName,
    required this.groupDataKey,
    required this.createdAt,
  });

  @override
  final String groupId;
  @override
  final String displayName;
  @override
  final AesGcmSecretKey groupDataKey;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CreatedGroup(groupId: $groupId, displayName: $displayName, groupDataKey: $groupDataKey, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatedGroupImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.groupDataKey, groupDataKey) ||
                other.groupDataKey == groupDataKey) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, groupId, displayName, groupDataKey, createdAt);

  /// Create a copy of CreatedGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatedGroupImplCopyWith<_$CreatedGroupImpl> get copyWith =>
      __$$CreatedGroupImplCopyWithImpl<_$CreatedGroupImpl>(this, _$identity);
}

abstract class _CreatedGroup implements CreatedGroup {
  const factory _CreatedGroup({
    required final String groupId,
    required final String displayName,
    required final AesGcmSecretKey groupDataKey,
    required final DateTime createdAt,
  }) = _$CreatedGroupImpl;

  @override
  String get groupId;
  @override
  String get displayName;
  @override
  AesGcmSecretKey get groupDataKey;
  @override
  DateTime get createdAt;

  /// Create a copy of CreatedGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatedGroupImplCopyWith<_$CreatedGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
