/// Shared call-log entry for payment rail mock clients.
class ApiCall {
  ApiCall(this.method, this.parameters);

  final String method;
  final Map<String, dynamic> parameters;

  @override
  String toString() => 'ApiCall{method: $method, parameters: $parameters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiCall &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          _mapsEqual(parameters, other.parameters);

  @override
  int get hashCode => method.hashCode ^ parameters.hashCode;

  static bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
