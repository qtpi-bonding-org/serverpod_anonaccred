import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../exception_factory.dart';
import '../generated/protocol.dart';

/// HTTP response from the Polar API, parsed to a uniform shape.
///
/// Non-2xx responses raise typed [PaymentException]s rather than
/// reaching the caller — the caller is always on the happy path here.
class PolarHttpResponse {
  PolarHttpResponse({required this.statusCode, required this.body});
  final int statusCode;
  final Map<String, dynamic> body;
}

/// Thin REST transport for Polar.sh.
///
/// What it does:
///   * Attaches `Authorization: Bearer <token>` and JSON headers
///   * Encodes/decodes JSON
///   * Maps network failures and non-2xx statuses to typed
///     [PaymentException]s via [AnonAccredExceptionFactory]
///   * 5xx / network / timeout → `polarApiUnavailable`
///   * 401 / 403 → `configurationMissing` (token problem, not user error)
///   * Other 4xx → `polarValidationFailed`
///
/// What it does **not** do:
///   * Know about license keys, benefits, orders, webhook payloads —
///     that all lives one layer up in [PolarClient].
///
/// Splitting transport from Polar-specific logic keeps the network
/// surface small and mockable, and leaves room for other Polar
/// endpoints (orders, customers, subscriptions) to share a single
/// network path. Other MoR rails that hit a REST API with bearer auth
/// could copy this class and customise only their MoR-layer wrappers.
class PolarHttpClient {
  PolarHttpClient({
    required this.baseUrl,
    required String bearerToken,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 10),
  })  : _bearerToken = bearerToken,
        _httpClient = httpClient ?? http.Client(),
        _timeout = timeout;

  /// Build from env vars: `POLAR_ACCESS_TOKEN`, `POLAR_ENVIRONMENT`
  /// (defaults to `production`; set `sandbox` for the sandbox API).
  factory PolarHttpClient.fromEnvironment({http.Client? httpClient}) {
    final token = Platform.environment['POLAR_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'POLAR_ACCESS_TOKEN is not configured',
        paymentRail: PaymentRail.polar.name,
      );
    }
    final envStr = Platform.environment['POLAR_ENVIRONMENT']?.toLowerCase();
    final base = envStr == 'sandbox'
        ? 'https://sandbox-api.polar.sh'
        : 'https://api.polar.sh';
    return PolarHttpClient(
      baseUrl: base,
      bearerToken: token,
      httpClient: httpClient,
    );
  }

  final String baseUrl;
  final String _bearerToken;
  final http.Client _httpClient;
  final Duration _timeout;

  Map<String, String> get _headers => {
        HttpHeaders.authorizationHeader: 'Bearer $_bearerToken',
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };

  Future<PolarHttpResponse> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await _httpClient
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
    } on TimeoutException catch (e) {
      throw _unavailable('Request timed out', path: path, details: '$e');
    } on SocketException catch (e) {
      throw _unavailable('Network error', path: path, details: '$e');
    } on http.ClientException catch (e) {
      throw _unavailable('HTTP client error', path: path, details: '$e');
    }
    return _parse(response, path);
  }

  Future<PolarHttpResponse> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await _httpClient.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException catch (e) {
      throw _unavailable('Request timed out', path: path, details: '$e');
    } on SocketException catch (e) {
      throw _unavailable('Network error', path: path, details: '$e');
    } on http.ClientException catch (e) {
      throw _unavailable('HTTP client error', path: path, details: '$e');
    }
    return _parse(response, path);
  }

  PolarHttpResponse _parse(http.Response response, String path) {
    if (response.statusCode >= 500) {
      throw _unavailable(
        'Polar API server error',
        path: path,
        statusCode: response.statusCode,
        details: response.body,
      );
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.configurationMissing,
        message: 'Polar rejected the API token (${response.statusCode})',
        paymentRail: PaymentRail.polar.name,
        details: {
          'path': path,
          'statusCode': response.statusCode.toString(),
        },
      );
    }
    if (response.statusCode >= 400) {
      throw _validationFailed(
        'Polar rejected the request',
        path: path,
        statusCode: response.statusCode,
        details: response.body,
      );
    }
    final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw _unavailable(
        'Polar response was not valid JSON',
        path: path,
        statusCode: response.statusCode,
        details: '$e | body=${response.body}',
      );
    }
    return PolarHttpResponse(statusCode: response.statusCode, body: parsed);
  }

  /// Closes the underlying HTTP client. Call on server shutdown to
  /// release the connection pool.
  void close() => _httpClient.close();

  PaymentException _unavailable(
    String message, {
    required String path,
    int? statusCode,
    String? details,
  }) =>
      AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarApiUnavailable,
        message: '$message: $path',
        paymentRail: PaymentRail.polar.name,
        details: {
          'path': path,
          'statusCode': ?statusCode?.toString(),
          'detail': ?details,
        },
      );

  PaymentException _validationFailed(
    String message, {
    required String path,
    required int statusCode,
    String? details,
  }) =>
      AnonAccredExceptionFactory.createPaymentException(
        code: AnonAccredErrorCodes.polarValidationFailed,
        message: '$message ($statusCode): $path',
        paymentRail: PaymentRail.polar.name,
        details: {
          'path': path,
          'statusCode': statusCode.toString(),
          'detail': ?details,
        },
      );
}
