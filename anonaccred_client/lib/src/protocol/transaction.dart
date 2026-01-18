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
import 'order_status.dart' as _i2;
import 'enums.dart' as _i3;
import 'payment_rail.dart' as _i4;

abstract class TransactionPayment implements _i1.SerializableModel {
  TransactionPayment._({
    this.id,
    required this.externalId,
    required this.accountId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    this.transactionTimestamp,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) : status = status ?? _i2.OrderStatus.pending,
       timestamp = timestamp ?? DateTime.now();

  factory TransactionPayment({
    int? id,
    required String externalId,
    required int accountId,
    required _i3.Currency priceCurrency,
    required double price,
    required _i4.PaymentRail paymentRail,
    required _i3.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) = _TransactionPaymentImpl;

  factory TransactionPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPayment(
      id: jsonSerialization['id'] as int?,
      externalId: jsonSerialization['externalId'] as String,
      accountId: jsonSerialization['accountId'] as int,
      priceCurrency: _i3.Currency.fromJson(
        (jsonSerialization['priceCurrency'] as String),
      ),
      price: (jsonSerialization['price'] as num).toDouble(),
      paymentRail: _i4.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentCurrency: _i3.Currency.fromJson(
        (jsonSerialization['paymentCurrency'] as String),
      ),
      paymentAmount: (jsonSerialization['paymentAmount'] as num).toDouble(),
      paymentRef: jsonSerialization['paymentRef'] as String?,
      transactionTimestamp: jsonSerialization['transactionTimestamp'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['transactionTimestamp'],
            ),
      status: _i2.OrderStatus.fromJson((jsonSerialization['status'] as String)),
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String externalId;

  int accountId;

  _i3.Currency priceCurrency;

  double price;

  _i4.PaymentRail paymentRail;

  _i3.Currency paymentCurrency;

  double paymentAmount;

  String? paymentRef;

  DateTime? transactionTimestamp;

  _i2.OrderStatus status;

  DateTime timestamp;

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionPayment copyWith({
    int? id,
    String? externalId,
    int? accountId,
    _i3.Currency? priceCurrency,
    double? price,
    _i4.PaymentRail? paymentRail,
    _i3.Currency? paymentCurrency,
    double? paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'externalId': externalId,
      'accountId': accountId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      if (transactionTimestamp != null)
        'transactionTimestamp': transactionTimestamp?.toJson(),
      'status': status.toJson(),
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionPaymentImpl extends TransactionPayment {
  _TransactionPaymentImpl({
    int? id,
    required String externalId,
    required int accountId,
    required _i3.Currency priceCurrency,
    required double price,
    required _i4.PaymentRail paymentRail,
    required _i3.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) : super._(
         id: id,
         externalId: externalId,
         accountId: accountId,
         priceCurrency: priceCurrency,
         price: price,
         paymentRail: paymentRail,
         paymentCurrency: paymentCurrency,
         paymentAmount: paymentAmount,
         paymentRef: paymentRef,
         transactionTimestamp: transactionTimestamp,
         status: status,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionPayment copyWith({
    Object? id = _Undefined,
    String? externalId,
    int? accountId,
    _i3.Currency? priceCurrency,
    double? price,
    _i4.PaymentRail? paymentRail,
    _i3.Currency? paymentCurrency,
    double? paymentAmount,
    Object? paymentRef = _Undefined,
    Object? transactionTimestamp = _Undefined,
    _i2.OrderStatus? status,
    DateTime? timestamp,
  }) {
    return TransactionPayment(
      id: id is int? ? id : this.id,
      externalId: externalId ?? this.externalId,
      accountId: accountId ?? this.accountId,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      price: price ?? this.price,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentRef: paymentRef is String? ? paymentRef : this.paymentRef,
      transactionTimestamp: transactionTimestamp is DateTime?
          ? transactionTimestamp
          : this.transactionTimestamp,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
