import 'dart:convert';

/// Represents a decoded Apple transaction from a signed JWT.
///
/// This class contains the transaction information extracted from Apple's
/// signed transaction JWT tokens. These tokens are returned by the App Store
/// Server API and contain details about in-app purchases.
///
/// **Purpose:**
/// - Provides type-safe access to transaction data from Apple's JWT tokens
/// - Decodes and validates JWT claims from signed transaction responses
/// - Supports all required transaction fields for consumable IAP processing
///
/// **Key Fields:**
/// - [transactionId]: Unique identifier for this specific transaction
/// - [originalTransactionId]: Identifier for the original transaction (for subscriptions/renewals)
/// - [productId]: The SKU/product identifier purchased
/// - [bundleId]: iOS application bundle identifier
/// - [purchaseDate]: Timestamp when the purchase was made (milliseconds since epoch)
/// - [originalPurchaseDate]: Timestamp of the original purchase (milliseconds since epoch)
/// - [webOrderLineItemId]: Apple's order line item ID (optional)
/// - [quantity]: Number of items purchased
/// - [type]: Transaction type (e.g., "Consumable", "Non-Consumable")
/// - [appAccountToken]: Optional app-specific account token
///
/// **Usage Example:**
/// ```dart
/// // Decode a signed transaction JWT from Apple
/// final signedTransaction = 'eyJhbGciOiJFUzI1NiIsIng1YyI6...';
/// final transaction = DecodedTransaction.fromJWT(signedTransaction);
///
/// print('Transaction ID: ${transaction.transactionId}');
/// print('Product ID: ${transaction.productId}');
/// print('Quantity: ${transaction.quantity}');
/// ```
///
/// **JWT Structure:**
/// Apple's signed transaction JWTs contain claims that map to these fields.
/// The JWT is signed with Apple's private key and can be verified using
/// Apple's public certificates.
class DecodedTransaction {
  /// Unique identifier for this transaction.
  ///
  /// This is Apple's unique transaction ID and serves as the primary
  /// identifier for the transaction. Used as the idempotency key for
  /// delivery tracking.
  final String transactionId;

  /// Original transaction identifier.
  ///
  /// For subscriptions and renewals, this identifies the original purchase.
  /// For one-time purchases, this is typically the same as [transactionId].
  final String originalTransactionId;

  /// Product identifier (SKU) for the purchased item.
  ///
  /// This matches the product ID configured in App Store Connect and
  /// is used to map to internal consumable types.
  final String productId;

  /// iOS application bundle identifier.
  ///
  /// The bundle ID of the app where the purchase was made.
  /// Used to verify the transaction belongs to the correct app.
  final String bundleId;

  /// Purchase date in milliseconds since epoch.
  ///
  /// The timestamp when the transaction was completed.
  final int purchaseDate;

  /// Original purchase date in milliseconds since epoch.
  ///
  /// For subscriptions, this is the date of the original subscription.
  /// For one-time purchases, this is typically the same as [purchaseDate].
  final int originalPurchaseDate;

  /// Apple's web order line item ID (optional).
  ///
  /// A unique identifier for the order line item. May be null for some
  /// transaction types.
  final String? webOrderLineItemId;

  /// Number of items purchased.
  ///
  /// For consumables, this indicates how many units were purchased.
  /// Typically 1 for most transactions.
  final int quantity;

  /// Transaction type.
  ///
  /// Indicates the type of in-app purchase:
  /// - "Consumable": Items that can be purchased multiple times
  /// - "Non-Consumable": One-time purchases
  /// - "Auto-Renewable Subscription": Recurring subscriptions
  /// - "Non-Renewing Subscription": Time-limited subscriptions
  final String type;

  /// Optional app-specific account token.
  ///
  /// A UUID that associates the transaction with a user account in your app.
  /// This is set by the app when initiating the purchase and can be used
  /// to link the transaction to your internal user ID.
  final String? appAccountToken;

  /// Creates a new DecodedTransaction instance.
  ///
  /// All required fields must be provided. Optional fields ([webOrderLineItemId]
  /// and [appAccountToken]) can be null.
  DecodedTransaction({
    required this.transactionId,
    required this.originalTransactionId,
    required this.productId,
    required this.bundleId,
    required this.purchaseDate,
    required this.originalPurchaseDate,
    this.webOrderLineItemId,
    required this.quantity,
    required this.type,
    this.appAccountToken,
  });

  /// Creates a DecodedTransaction from a signed JWT string.
  ///
  /// This factory method decodes the JWT payload and extracts the transaction
  /// claims. Note that this method does NOT verify the JWT signature - signature
  /// verification should be done separately using Apple's public certificates.
  ///
  /// [signedJWT] - The signed JWT string from Apple's API response
  ///
  /// Returns a [DecodedTransaction] with all fields populated from the JWT claims.
  ///
  /// Throws:
  /// - [FormatException] if the JWT is malformed or missing required claims
  /// - [ArgumentError] if required claims are missing or have invalid types
  ///
  /// **Example:**
  /// ```dart
  /// final signedJWT = 'eyJhbGciOiJFUzI1NiIsIng1YyI6...';
  /// final transaction = DecodedTransaction.fromJWT(signedJWT);
  /// ```
  factory DecodedTransaction.fromJWT(String signedJWT) {
    // Split JWT into parts (header.payload.signature)
    final parts = signedJWT.split('.');
    if (parts.length != 3) {
      throw FormatException(
        'Invalid JWT format: expected 3 parts (header.payload.signature), got ${parts.length}',
      );
    }

    // Decode the payload (second part)
    final payload = parts[1];
    final normalizedPayload = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
    final claims = jsonDecode(decodedPayload) as Map<String, dynamic>;

    // Extract and validate required claims
    return DecodedTransaction.fromClaims(claims);
  }

  /// Creates a DecodedTransaction from JWT claims map.
  ///
  /// This factory method extracts transaction data from the decoded JWT claims.
  /// It validates that all required fields are present and have the correct types.
  ///
  /// [claims] - The decoded JWT claims as a Map
  ///
  /// Returns a [DecodedTransaction] with all fields populated from the claims.
  ///
  /// Throws:
  /// - [ArgumentError] if required claims are missing or have invalid types
  ///
  /// **Example:**
  /// ```dart
  /// final claims = {
  ///   'transactionId': '123456',
  ///   'originalTransactionId': '123456',
  ///   'productId': 'com.app.coins_100',
  ///   // ... other claims
  /// };
  /// final transaction = DecodedTransaction.fromClaims(claims);
  /// ```
  factory DecodedTransaction.fromClaims(Map<String, dynamic> claims) {
    // Helper function to get required claim
    T getRequiredClaim<T>(String key) {
      if (!claims.containsKey(key)) {
        throw ArgumentError('Missing required claim: $key');
      }
      final value = claims[key];
      if (value is! T) {
        throw ArgumentError(
          'Invalid type for claim $key: expected $T, got ${value.runtimeType}',
        );
      }
      return value;
    }

    // Helper function to get optional claim
    T? getOptionalClaim<T>(String key) {
      if (!claims.containsKey(key) || claims[key] == null) {
        return null;
      }
      final value = claims[key];
      if (value is! T) {
        throw ArgumentError(
          'Invalid type for claim $key: expected $T, got ${value.runtimeType}',
        );
      }
      return value;
    }

    return DecodedTransaction(
      transactionId: getRequiredClaim<String>('transactionId'),
      originalTransactionId: getRequiredClaim<String>('originalTransactionId'),
      productId: getRequiredClaim<String>('productId'),
      bundleId: getRequiredClaim<String>('bundleId'),
      purchaseDate: getRequiredClaim<int>('purchaseDate'),
      originalPurchaseDate: getRequiredClaim<int>('originalPurchaseDate'),
      webOrderLineItemId: getOptionalClaim<String>('webOrderLineItemId'),
      quantity: getRequiredClaim<int>('quantity'),
      type: getRequiredClaim<String>('type'),
      appAccountToken: getOptionalClaim<String>('appAccountToken'),
    );
  }

  @override
  String toString() {
    return 'DecodedTransaction{'
        'transactionId: $transactionId, '
        'originalTransactionId: $originalTransactionId, '
        'productId: $productId, '
        'bundleId: $bundleId, '
        'purchaseDate: $purchaseDate, '
        'originalPurchaseDate: $originalPurchaseDate, '
        'webOrderLineItemId: $webOrderLineItemId, '
        'quantity: $quantity, '
        'type: $type, '
        'appAccountToken: $appAccountToken'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodedTransaction &&
          runtimeType == other.runtimeType &&
          transactionId == other.transactionId &&
          originalTransactionId == other.originalTransactionId &&
          productId == other.productId &&
          bundleId == other.bundleId &&
          purchaseDate == other.purchaseDate &&
          originalPurchaseDate == other.originalPurchaseDate &&
          webOrderLineItemId == other.webOrderLineItemId &&
          quantity == other.quantity &&
          type == other.type &&
          appAccountToken == other.appAccountToken;

  @override
  int get hashCode =>
      transactionId.hashCode ^
      originalTransactionId.hashCode ^
      productId.hashCode ^
      bundleId.hashCode ^
      purchaseDate.hashCode ^
      originalPurchaseDate.hashCode ^
      (webOrderLineItemId?.hashCode ?? 0) ^
      quantity.hashCode ^
      type.hashCode ^
      (appAccountToken?.hashCode ?? 0);
}
