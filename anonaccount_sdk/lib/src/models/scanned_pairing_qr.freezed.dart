// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanned_pairing_qr.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScannedPairingQr {
  String get theirSigningPubkeyHex;
  String get theirEncryptionPubkeyHex;
  String get label;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScannedPairingQrCopyWith<ScannedPairingQr> get copyWith =>
      _$ScannedPairingQrCopyWithImpl<ScannedPairingQr>(
          this as ScannedPairingQr, _$identity);

  /// Serializes this ScannedPairingQr to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScannedPairingQr &&
            (identical(other.theirSigningPubkeyHex, theirSigningPubkeyHex) ||
                other.theirSigningPubkeyHex == theirSigningPubkeyHex) &&
            (identical(
                    other.theirEncryptionPubkeyHex, theirEncryptionPubkeyHex) ||
                other.theirEncryptionPubkeyHex == theirEncryptionPubkeyHex) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, theirSigningPubkeyHex, theirEncryptionPubkeyHex, label);

  @override
  String toString() {
    return 'ScannedPairingQr(theirSigningPubkeyHex: $theirSigningPubkeyHex, theirEncryptionPubkeyHex: $theirEncryptionPubkeyHex, label: $label)';
  }
}

/// @nodoc
abstract mixin class $ScannedPairingQrCopyWith<$Res> {
  factory $ScannedPairingQrCopyWith(
          ScannedPairingQr value, $Res Function(ScannedPairingQr) _then) =
      _$ScannedPairingQrCopyWithImpl;
  @useResult
  $Res call(
      {String theirSigningPubkeyHex,
      String theirEncryptionPubkeyHex,
      String label});
}

/// @nodoc
class _$ScannedPairingQrCopyWithImpl<$Res>
    implements $ScannedPairingQrCopyWith<$Res> {
  _$ScannedPairingQrCopyWithImpl(this._self, this._then);

  final ScannedPairingQr _self;
  final $Res Function(ScannedPairingQr) _then;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theirSigningPubkeyHex = null,
    Object? theirEncryptionPubkeyHex = null,
    Object? label = null,
  }) {
    return _then(_self.copyWith(
      theirSigningPubkeyHex: null == theirSigningPubkeyHex
          ? _self.theirSigningPubkeyHex
          : theirSigningPubkeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      theirEncryptionPubkeyHex: null == theirEncryptionPubkeyHex
          ? _self.theirEncryptionPubkeyHex
          : theirEncryptionPubkeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScannedPairingQr].
extension ScannedPairingQrPatterns on ScannedPairingQr {
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
    TResult Function(_ScannedPairingQr value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr() when $default != null:
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
    TResult Function(_ScannedPairingQr value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr():
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
    TResult? Function(_ScannedPairingQr value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr() when $default != null:
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
    TResult Function(String theirSigningPubkeyHex,
            String theirEncryptionPubkeyHex, String label)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr() when $default != null:
        return $default(_that.theirSigningPubkeyHex,
            _that.theirEncryptionPubkeyHex, _that.label);
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
    TResult Function(String theirSigningPubkeyHex,
            String theirEncryptionPubkeyHex, String label)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr():
        return $default(_that.theirSigningPubkeyHex,
            _that.theirEncryptionPubkeyHex, _that.label);
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
    TResult? Function(String theirSigningPubkeyHex,
            String theirEncryptionPubkeyHex, String label)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScannedPairingQr() when $default != null:
        return $default(_that.theirSigningPubkeyHex,
            _that.theirEncryptionPubkeyHex, _that.label);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ScannedPairingQr extends ScannedPairingQr {
  const _ScannedPairingQr(
      {required this.theirSigningPubkeyHex,
      required this.theirEncryptionPubkeyHex,
      required this.label})
      : super._();
  factory _ScannedPairingQr.fromJson(Map<String, dynamic> json) =>
      _$ScannedPairingQrFromJson(json);

  @override
  final String theirSigningPubkeyHex;
  @override
  final String theirEncryptionPubkeyHex;
  @override
  final String label;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScannedPairingQrCopyWith<_ScannedPairingQr> get copyWith =>
      __$ScannedPairingQrCopyWithImpl<_ScannedPairingQr>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ScannedPairingQrToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScannedPairingQr &&
            (identical(other.theirSigningPubkeyHex, theirSigningPubkeyHex) ||
                other.theirSigningPubkeyHex == theirSigningPubkeyHex) &&
            (identical(
                    other.theirEncryptionPubkeyHex, theirEncryptionPubkeyHex) ||
                other.theirEncryptionPubkeyHex == theirEncryptionPubkeyHex) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, theirSigningPubkeyHex, theirEncryptionPubkeyHex, label);

  @override
  String toString() {
    return 'ScannedPairingQr(theirSigningPubkeyHex: $theirSigningPubkeyHex, theirEncryptionPubkeyHex: $theirEncryptionPubkeyHex, label: $label)';
  }
}

/// @nodoc
abstract mixin class _$ScannedPairingQrCopyWith<$Res>
    implements $ScannedPairingQrCopyWith<$Res> {
  factory _$ScannedPairingQrCopyWith(
          _ScannedPairingQr value, $Res Function(_ScannedPairingQr) _then) =
      __$ScannedPairingQrCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String theirSigningPubkeyHex,
      String theirEncryptionPubkeyHex,
      String label});
}

/// @nodoc
class __$ScannedPairingQrCopyWithImpl<$Res>
    implements _$ScannedPairingQrCopyWith<$Res> {
  __$ScannedPairingQrCopyWithImpl(this._self, this._then);

  final _ScannedPairingQr _self;
  final $Res Function(_ScannedPairingQr) _then;

  /// Create a copy of ScannedPairingQr
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? theirSigningPubkeyHex = null,
    Object? theirEncryptionPubkeyHex = null,
    Object? label = null,
  }) {
    return _then(_ScannedPairingQr(
      theirSigningPubkeyHex: null == theirSigningPubkeyHex
          ? _self.theirSigningPubkeyHex
          : theirSigningPubkeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      theirEncryptionPubkeyHex: null == theirEncryptionPubkeyHex
          ? _self.theirEncryptionPubkeyHex
          : theirEncryptionPubkeyHex // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
