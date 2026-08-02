// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistrationPayload {
  String get devicePublicKeyHex;
  String get deviceEncryptionPublicKeyHex;
  String get ultimatePublicKeyHex;
  String get ultimateEncryptionPublicKeyHex;
  String get recoveryBlob;
  String get deviceBlob;
  String get deviceKeyAttestation;
  DateTime get createdAt;
  int get version;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RegistrationPayloadCopyWith<RegistrationPayload> get copyWith =>
      _$RegistrationPayloadCopyWithImpl<RegistrationPayload>(
          this as RegistrationPayload, _$identity);

  /// Serializes this RegistrationPayload to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RegistrationPayload &&
            (identical(other.devicePublicKeyHex, devicePublicKeyHex) ||
                other.devicePublicKeyHex == devicePublicKeyHex) &&
            (identical(other.deviceEncryptionPublicKeyHex,
                    deviceEncryptionPublicKeyHex) ||
                other.deviceEncryptionPublicKeyHex ==
                    deviceEncryptionPublicKeyHex) &&
            (identical(other.ultimatePublicKeyHex, ultimatePublicKeyHex) ||
                other.ultimatePublicKeyHex == ultimatePublicKeyHex) &&
            (identical(other.ultimateEncryptionPublicKeyHex,
                    ultimateEncryptionPublicKeyHex) ||
                other.ultimateEncryptionPublicKeyHex ==
                    ultimateEncryptionPublicKeyHex) &&
            (identical(other.recoveryBlob, recoveryBlob) ||
                other.recoveryBlob == recoveryBlob) &&
            (identical(other.deviceBlob, deviceBlob) ||
                other.deviceBlob == deviceBlob) &&
            (identical(other.deviceKeyAttestation, deviceKeyAttestation) ||
                other.deviceKeyAttestation == deviceKeyAttestation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      devicePublicKeyHex,
      deviceEncryptionPublicKeyHex,
      ultimatePublicKeyHex,
      ultimateEncryptionPublicKeyHex,
      recoveryBlob,
      deviceBlob,
      deviceKeyAttestation,
      createdAt,
      version);

  @override
  String toString() {
    return 'RegistrationPayload(devicePublicKeyHex: $devicePublicKeyHex, deviceEncryptionPublicKeyHex: $deviceEncryptionPublicKeyHex, ultimatePublicKeyHex: $ultimatePublicKeyHex, ultimateEncryptionPublicKeyHex: $ultimateEncryptionPublicKeyHex, recoveryBlob: $recoveryBlob, deviceBlob: $deviceBlob, deviceKeyAttestation: $deviceKeyAttestation, createdAt: $createdAt, version: $version)';
  }
}

/// @nodoc
abstract mixin class $RegistrationPayloadCopyWith<$Res> {
  factory $RegistrationPayloadCopyWith(
          RegistrationPayload value, $Res Function(RegistrationPayload) _then) =
      _$RegistrationPayloadCopyWithImpl;
  @useResult
  $Res call(
      {String devicePublicKeyHex,
      String deviceEncryptionPublicKeyHex,
      String ultimatePublicKeyHex,
      String ultimateEncryptionPublicKeyHex,
      String recoveryBlob,
      String deviceBlob,
      String deviceKeyAttestation,
      DateTime createdAt,
      int version});
}

/// @nodoc
class _$RegistrationPayloadCopyWithImpl<$Res>
    implements $RegistrationPayloadCopyWith<$Res> {
  _$RegistrationPayloadCopyWithImpl(this._self, this._then);

  final RegistrationPayload _self;
  final $Res Function(RegistrationPayload) _then;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devicePublicKeyHex = null,
    Object? deviceEncryptionPublicKeyHex = null,
    Object? ultimatePublicKeyHex = null,
    Object? ultimateEncryptionPublicKeyHex = null,
    Object? recoveryBlob = null,
    Object? deviceBlob = null,
    Object? deviceKeyAttestation = null,
    Object? createdAt = null,
    Object? version = null,
  }) {
    return _then(_self.copyWith(
      devicePublicKeyHex: null == devicePublicKeyHex
          ? _self.devicePublicKeyHex
          : devicePublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      deviceEncryptionPublicKeyHex: null == deviceEncryptionPublicKeyHex
          ? _self.deviceEncryptionPublicKeyHex
          : deviceEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      ultimatePublicKeyHex: null == ultimatePublicKeyHex
          ? _self.ultimatePublicKeyHex
          : ultimatePublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      ultimateEncryptionPublicKeyHex: null == ultimateEncryptionPublicKeyHex
          ? _self.ultimateEncryptionPublicKeyHex
          : ultimateEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      recoveryBlob: null == recoveryBlob
          ? _self.recoveryBlob
          : recoveryBlob // ignore: cast_nullable_to_non_nullable
              as String,
      deviceBlob: null == deviceBlob
          ? _self.deviceBlob
          : deviceBlob // ignore: cast_nullable_to_non_nullable
              as String,
      deviceKeyAttestation: null == deviceKeyAttestation
          ? _self.deviceKeyAttestation
          : deviceKeyAttestation // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [RegistrationPayload].
extension RegistrationPayloadPatterns on RegistrationPayload {
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
    TResult Function(_RegistrationPayload value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload() when $default != null:
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
    TResult Function(_RegistrationPayload value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload():
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
    TResult? Function(_RegistrationPayload value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload() when $default != null:
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
            String devicePublicKeyHex,
            String deviceEncryptionPublicKeyHex,
            String ultimatePublicKeyHex,
            String ultimateEncryptionPublicKeyHex,
            String recoveryBlob,
            String deviceBlob,
            String deviceKeyAttestation,
            DateTime createdAt,
            int version)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload() when $default != null:
        return $default(
            _that.devicePublicKeyHex,
            _that.deviceEncryptionPublicKeyHex,
            _that.ultimatePublicKeyHex,
            _that.ultimateEncryptionPublicKeyHex,
            _that.recoveryBlob,
            _that.deviceBlob,
            _that.deviceKeyAttestation,
            _that.createdAt,
            _that.version);
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
            String devicePublicKeyHex,
            String deviceEncryptionPublicKeyHex,
            String ultimatePublicKeyHex,
            String ultimateEncryptionPublicKeyHex,
            String recoveryBlob,
            String deviceBlob,
            String deviceKeyAttestation,
            DateTime createdAt,
            int version)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload():
        return $default(
            _that.devicePublicKeyHex,
            _that.deviceEncryptionPublicKeyHex,
            _that.ultimatePublicKeyHex,
            _that.ultimateEncryptionPublicKeyHex,
            _that.recoveryBlob,
            _that.deviceBlob,
            _that.deviceKeyAttestation,
            _that.createdAt,
            _that.version);
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
            String devicePublicKeyHex,
            String deviceEncryptionPublicKeyHex,
            String ultimatePublicKeyHex,
            String ultimateEncryptionPublicKeyHex,
            String recoveryBlob,
            String deviceBlob,
            String deviceKeyAttestation,
            DateTime createdAt,
            int version)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistrationPayload() when $default != null:
        return $default(
            _that.devicePublicKeyHex,
            _that.deviceEncryptionPublicKeyHex,
            _that.ultimatePublicKeyHex,
            _that.ultimateEncryptionPublicKeyHex,
            _that.recoveryBlob,
            _that.deviceBlob,
            _that.deviceKeyAttestation,
            _that.createdAt,
            _that.version);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RegistrationPayload extends RegistrationPayload {
  const _RegistrationPayload(
      {required this.devicePublicKeyHex,
      required this.deviceEncryptionPublicKeyHex,
      required this.ultimatePublicKeyHex,
      required this.ultimateEncryptionPublicKeyHex,
      required this.recoveryBlob,
      required this.deviceBlob,
      required this.deviceKeyAttestation,
      required this.createdAt,
      this.version = 1})
      : super._();
  factory _RegistrationPayload.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPayloadFromJson(json);

  @override
  final String devicePublicKeyHex;
  @override
  final String deviceEncryptionPublicKeyHex;
  @override
  final String ultimatePublicKeyHex;
  @override
  final String ultimateEncryptionPublicKeyHex;
  @override
  final String recoveryBlob;
  @override
  final String deviceBlob;
  @override
  final String deviceKeyAttestation;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int version;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RegistrationPayloadCopyWith<_RegistrationPayload> get copyWith =>
      __$RegistrationPayloadCopyWithImpl<_RegistrationPayload>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RegistrationPayloadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RegistrationPayload &&
            (identical(other.devicePublicKeyHex, devicePublicKeyHex) ||
                other.devicePublicKeyHex == devicePublicKeyHex) &&
            (identical(other.deviceEncryptionPublicKeyHex,
                    deviceEncryptionPublicKeyHex) ||
                other.deviceEncryptionPublicKeyHex ==
                    deviceEncryptionPublicKeyHex) &&
            (identical(other.ultimatePublicKeyHex, ultimatePublicKeyHex) ||
                other.ultimatePublicKeyHex == ultimatePublicKeyHex) &&
            (identical(other.ultimateEncryptionPublicKeyHex,
                    ultimateEncryptionPublicKeyHex) ||
                other.ultimateEncryptionPublicKeyHex ==
                    ultimateEncryptionPublicKeyHex) &&
            (identical(other.recoveryBlob, recoveryBlob) ||
                other.recoveryBlob == recoveryBlob) &&
            (identical(other.deviceBlob, deviceBlob) ||
                other.deviceBlob == deviceBlob) &&
            (identical(other.deviceKeyAttestation, deviceKeyAttestation) ||
                other.deviceKeyAttestation == deviceKeyAttestation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      devicePublicKeyHex,
      deviceEncryptionPublicKeyHex,
      ultimatePublicKeyHex,
      ultimateEncryptionPublicKeyHex,
      recoveryBlob,
      deviceBlob,
      deviceKeyAttestation,
      createdAt,
      version);

  @override
  String toString() {
    return 'RegistrationPayload(devicePublicKeyHex: $devicePublicKeyHex, deviceEncryptionPublicKeyHex: $deviceEncryptionPublicKeyHex, ultimatePublicKeyHex: $ultimatePublicKeyHex, ultimateEncryptionPublicKeyHex: $ultimateEncryptionPublicKeyHex, recoveryBlob: $recoveryBlob, deviceBlob: $deviceBlob, deviceKeyAttestation: $deviceKeyAttestation, createdAt: $createdAt, version: $version)';
  }
}

/// @nodoc
abstract mixin class _$RegistrationPayloadCopyWith<$Res>
    implements $RegistrationPayloadCopyWith<$Res> {
  factory _$RegistrationPayloadCopyWith(_RegistrationPayload value,
          $Res Function(_RegistrationPayload) _then) =
      __$RegistrationPayloadCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String devicePublicKeyHex,
      String deviceEncryptionPublicKeyHex,
      String ultimatePublicKeyHex,
      String ultimateEncryptionPublicKeyHex,
      String recoveryBlob,
      String deviceBlob,
      String deviceKeyAttestation,
      DateTime createdAt,
      int version});
}

/// @nodoc
class __$RegistrationPayloadCopyWithImpl<$Res>
    implements _$RegistrationPayloadCopyWith<$Res> {
  __$RegistrationPayloadCopyWithImpl(this._self, this._then);

  final _RegistrationPayload _self;
  final $Res Function(_RegistrationPayload) _then;

  /// Create a copy of RegistrationPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? devicePublicKeyHex = null,
    Object? deviceEncryptionPublicKeyHex = null,
    Object? ultimatePublicKeyHex = null,
    Object? ultimateEncryptionPublicKeyHex = null,
    Object? recoveryBlob = null,
    Object? deviceBlob = null,
    Object? deviceKeyAttestation = null,
    Object? createdAt = null,
    Object? version = null,
  }) {
    return _then(_RegistrationPayload(
      devicePublicKeyHex: null == devicePublicKeyHex
          ? _self.devicePublicKeyHex
          : devicePublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      deviceEncryptionPublicKeyHex: null == deviceEncryptionPublicKeyHex
          ? _self.deviceEncryptionPublicKeyHex
          : deviceEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      ultimatePublicKeyHex: null == ultimatePublicKeyHex
          ? _self.ultimatePublicKeyHex
          : ultimatePublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      ultimateEncryptionPublicKeyHex: null == ultimateEncryptionPublicKeyHex
          ? _self.ultimateEncryptionPublicKeyHex
          : ultimateEncryptionPublicKeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      recoveryBlob: null == recoveryBlob
          ? _self.recoveryBlob
          : recoveryBlob // ignore: cast_nullable_to_non_nullable
              as String,
      deviceBlob: null == deviceBlob
          ? _self.deviceBlob
          : deviceBlob // ignore: cast_nullable_to_non_nullable
              as String,
      deviceKeyAttestation: null == deviceKeyAttestation
          ? _self.deviceKeyAttestation
          : deviceKeyAttestation // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
