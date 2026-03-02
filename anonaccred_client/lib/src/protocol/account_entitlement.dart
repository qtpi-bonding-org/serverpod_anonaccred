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

abstract class AccountEntitlement implements _i1.SerializableModel {
  AccountEntitlement._({
    this.id,
    required this.accountId,
    required this.entitlementId,
    required this.balance,
  });

  factory AccountEntitlement({
    int? id,
    required int accountId,
    required int entitlementId,
    required double balance,
  }) = _AccountEntitlementImpl;

  factory AccountEntitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountEntitlement(
      id: jsonSerialization['id'] as int?,
      accountId: jsonSerialization['accountId'] as int,
      entitlementId: jsonSerialization['entitlementId'] as int,
      balance: (jsonSerialization['balance'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int accountId;

  int entitlementId;

  double balance;

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountEntitlement copyWith({
    int? id,
    int? accountId,
    int? entitlementId,
    double? balance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.AccountEntitlement',
      if (id != null) 'id': id,
      'accountId': accountId,
      'entitlementId': entitlementId,
      'balance': balance,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountEntitlementImpl extends AccountEntitlement {
  _AccountEntitlementImpl({
    int? id,
    required int accountId,
    required int entitlementId,
    required double balance,
  }) : super._(
         id: id,
         accountId: accountId,
         entitlementId: entitlementId,
         balance: balance,
       );

  /// Returns a shallow copy of this [AccountEntitlement]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountEntitlement copyWith({
    Object? id = _Undefined,
    int? accountId,
    int? entitlementId,
    double? balance,
  }) {
    return AccountEntitlement(
      id: id is int? ? id : this.id,
      accountId: accountId ?? this.accountId,
      entitlementId: entitlementId ?? this.entitlementId,
      balance: balance ?? this.balance,
    );
  }
}
