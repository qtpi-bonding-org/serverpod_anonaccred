/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'entitlement_type.dart' as _i2;

abstract class Entitlement implements _i1.SerializableModel {
  Entitlement._({
    this.id,
    required this.tag,
    required this.name,
    required this.type,
    required this.serverValidated,
  });

  factory Entitlement({
    int? id,
    required String tag,
    required String name,
    required _i2.EntitlementType type,
    required bool serverValidated,
  }) = _EntitlementImpl;

  factory Entitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return Entitlement(
      id: jsonSerialization['id'] as int?,
      tag: jsonSerialization['tag'] as String,
      name: jsonSerialization['name'] as String,
      type: _i2.EntitlementType.fromJson((jsonSerialization['type'] as String)),
      serverValidated: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['serverValidated'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String tag;

  String name;

  _i2.EntitlementType type;

  bool serverValidated;

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Entitlement copyWith({
    int? id,
    String? tag,
    String? name,
    _i2.EntitlementType? type,
    bool? serverValidated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.Entitlement',
      if (id != null) 'id': id,
      'tag': tag,
      'name': name,
      'type': type.toJson(),
      'serverValidated': serverValidated,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EntitlementImpl extends Entitlement {
  _EntitlementImpl({
    int? id,
    required String tag,
    required String name,
    required _i2.EntitlementType type,
    required bool serverValidated,
  }) : super._(
         id: id,
         tag: tag,
         name: name,
         type: type,
         serverValidated: serverValidated,
       );

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Entitlement copyWith({
    Object? id = _Undefined,
    String? tag,
    String? name,
    _i2.EntitlementType? type,
    bool? serverValidated,
  }) {
    return Entitlement(
      id: id is int? ? id : this.id,
      tag: tag ?? this.tag,
      name: name ?? this.name,
      type: type ?? this.type,
      serverValidated: serverValidated ?? this.serverValidated,
    );
  }
}
