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

abstract class AccountInventory implements _i1.SerializableModel {
  AccountInventory._({
    this.id,
    required this.accountId,
    required this.consumableType,
    required this.quantity,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory AccountInventory({
    int? id,
    required int accountId,
    required String consumableType,
    required double quantity,
    DateTime? lastUpdated,
  }) = _AccountInventoryImpl;

  factory AccountInventory.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountInventory(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      consumableType: jsonSerialization['consumableType'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      lastUpdated: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdated'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int accountId;

  String consumableType;

  double quantity;

  DateTime lastUpdated;

  /// Returns a shallow copy of this [AccountInventory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountInventory copyWith({
    int? id,
    int? accountId,
    String? consumableType,
    double? quantity,
    DateTime? lastUpdated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountInventory',
      if (id != null) 'id': id,
      'accountId': accountId,
      'consumableType': consumableType,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountInventoryImpl extends AccountInventory {
  _AccountInventoryImpl({
    int? id,
    required int accountId,
    required String consumableType,
    required double quantity,
    DateTime? lastUpdated,
  }) : super._(
         id: id,
         accountId: accountId,
         consumableType: consumableType,
         quantity: quantity,
         lastUpdated: lastUpdated,
       );

  /// Returns a shallow copy of this [AccountInventory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountInventory copyWith({
    Object? id = _Undefined,
    int? accountId,
    String? consumableType,
    double? quantity,
    DateTime? lastUpdated,
  }) {
    return AccountInventory(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      consumableType: consumableType ?? this.consumableType,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
