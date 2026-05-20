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
import 'currency.dart' as _i2;
import 'payment_rail.dart' as _i3;
import 'order_status.dart' as _i4;

abstract class TransactionPayment implements _i1.SerializableModel {
  TransactionPayment._({
    this.id,
    required this.railProductId,
    required this.internalTransactionId,
    required this.priceCurrency,
    required this.price,
    required this.paymentRail,
    required this.paymentCurrency,
    required this.paymentAmount,
    this.paymentRef,
    required this.transactionTimestamp,
    this.clientReference,
    required this.status,
    this.railDataJson,
  });

  factory TransactionPayment({
    int? id,
    required int railProductId,
    required String internalTransactionId,
    required _i2.Currency priceCurrency,
    required double price,
    required _i3.PaymentRail paymentRail,
    required _i2.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _i4.OrderStatus status,
    String? railDataJson,
  }) = _TransactionPaymentImpl;

  factory TransactionPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionPayment(
      id: jsonSerialization['id'] as int?,
      railProductId: jsonSerialization['railProductId'] as int,
      internalTransactionId:
          jsonSerialization['internalTransactionId'] as String,
      priceCurrency: _i2.Currency.fromJson(
        (jsonSerialization['priceCurrency'] as String),
      ),
      price: (jsonSerialization['price'] as num).toDouble(),
      paymentRail: _i3.PaymentRail.fromJson(
        (jsonSerialization['paymentRail'] as String),
      ),
      paymentCurrency: _i2.Currency.fromJson(
        (jsonSerialization['paymentCurrency'] as String),
      ),
      paymentAmount: (jsonSerialization['paymentAmount'] as num).toDouble(),
      paymentRef: jsonSerialization['paymentRef'] as String?,
      transactionTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionTimestamp'],
      ),
      clientReference: jsonSerialization['clientReference'] as String?,
      status: _i4.OrderStatus.fromJson((jsonSerialization['status'] as String)),
      railDataJson: jsonSerialization['railDataJson'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int railProductId;

  String internalTransactionId;

  _i2.Currency priceCurrency;

  double price;

  _i3.PaymentRail paymentRail;

  _i2.Currency paymentCurrency;

  double paymentAmount;

  String? paymentRef;

  DateTime transactionTimestamp;

  String? clientReference;

  _i4.OrderStatus status;

  String? railDataJson;

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionPayment copyWith({
    int? id,
    int? railProductId,
    String? internalTransactionId,
    _i2.Currency? priceCurrency,
    double? price,
    _i3.PaymentRail? paymentRail,
    _i2.Currency? paymentCurrency,
    double? paymentAmount,
    String? paymentRef,
    DateTime? transactionTimestamp,
    String? clientReference,
    _i4.OrderStatus? status,
    String? railDataJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'anonaccred.TransactionPayment',
      if (id != null) 'id': id,
      'railProductId': railProductId,
      'internalTransactionId': internalTransactionId,
      'priceCurrency': priceCurrency.toJson(),
      'price': price,
      'paymentRail': paymentRail.toJson(),
      'paymentCurrency': paymentCurrency.toJson(),
      'paymentAmount': paymentAmount,
      if (paymentRef != null) 'paymentRef': paymentRef,
      'transactionTimestamp': transactionTimestamp.toJson(),
      if (clientReference != null) 'clientReference': clientReference,
      'status': status.toJson(),
      if (railDataJson != null) 'railDataJson': railDataJson,
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
    required int railProductId,
    required String internalTransactionId,
    required _i2.Currency priceCurrency,
    required double price,
    required _i3.PaymentRail paymentRail,
    required _i2.Currency paymentCurrency,
    required double paymentAmount,
    String? paymentRef,
    required DateTime transactionTimestamp,
    String? clientReference,
    required _i4.OrderStatus status,
    String? railDataJson,
  }) : super._(
         id: id,
         railProductId: railProductId,
         internalTransactionId: internalTransactionId,
         priceCurrency: priceCurrency,
         price: price,
         paymentRail: paymentRail,
         paymentCurrency: paymentCurrency,
         paymentAmount: paymentAmount,
         paymentRef: paymentRef,
         transactionTimestamp: transactionTimestamp,
         clientReference: clientReference,
         status: status,
         railDataJson: railDataJson,
       );

  /// Returns a shallow copy of this [TransactionPayment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionPayment copyWith({
    Object? id = _Undefined,
    int? railProductId,
    String? internalTransactionId,
    _i2.Currency? priceCurrency,
    double? price,
    _i3.PaymentRail? paymentRail,
    _i2.Currency? paymentCurrency,
    double? paymentAmount,
    Object? paymentRef = _Undefined,
    DateTime? transactionTimestamp,
    Object? clientReference = _Undefined,
    _i4.OrderStatus? status,
    Object? railDataJson = _Undefined,
  }) {
    return TransactionPayment(
      id: id is int? ? id : this.id,
      railProductId: railProductId ?? this.railProductId,
      internalTransactionId:
          internalTransactionId ?? this.internalTransactionId,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      price: price ?? this.price,
      paymentRail: paymentRail ?? this.paymentRail,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentRef: paymentRef is String? ? paymentRef : this.paymentRef,
      transactionTimestamp: transactionTimestamp ?? this.transactionTimestamp,
      clientReference: clientReference is String?
          ? clientReference
          : this.clientReference,
      status: status ?? this.status,
      railDataJson: railDataJson is String? ? railDataJson : this.railDataJson,
    );
  }
}
