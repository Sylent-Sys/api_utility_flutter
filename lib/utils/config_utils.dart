import '../models/config.dart';

/// Utility class for configuration-related operations
class ConfigUtils {
  /// Creates a default ApiConfig with sensible defaults
  static ApiConfig createDefaultConfig() {
    return ApiConfig(
      baseUrl: '',
      endpointPath: '',
      token: '',
      apiKey: '',
      username: '',
      password: '',
      timeoutSec: 30,
      batchSize: 10,
      rateLimitSecond: 1.0,
      maxRetries: 3,
      requestMethod: 'POST',
      authMethod: 'none',
      stringKeys: [],
    );
  }

  /// Creates a copy of config with updated values
  static ApiConfig updateConfig(
    ApiConfig config, {
    String? baseUrl,
    String? endpointPath,
    String? token,
    String? apiKey,
    String? username,
    String? password,
    int? timeoutSec,
    int? batchSize,
    double? rateLimitSecond,
    int? maxRetries,
    String? requestMethod,
    String? authMethod,
    List<String>? stringKeys,
  }) {
    return config.copyWith(
      baseUrl: baseUrl,
      endpointPath: endpointPath,
      token: token,
      apiKey: apiKey,
      username: username,
      password: password,
      timeoutSec: timeoutSec,
      batchSize: batchSize,
      rateLimitSecond: rateLimitSecond,
      maxRetries: maxRetries,
      requestMethod: requestMethod,
      authMethod: authMethod,
      stringKeys: stringKeys,
    );
  }

  /// Parses string keys from comma-separated string
  static List<String> parseStringKeys(String stringKeysText) {
    return stringKeysText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Converts string keys list to comma-separated string
  static String stringKeysToString(List<String> stringKeys) {
    return stringKeys.join(', ');
  }

  /// Gets available authentication methods
  static List<Map<String, String>> getAuthMethods() {
    return [
      {'value': 'bearer', 'label': 'Bearer Token'},
      {'value': 'api_key', 'label': 'API Key'},
      {'value': 'basic', 'label': 'Basic Auth'},
      {'value': 'none', 'label': 'None'},
    ];
  }

  /// Gets available request methods
  static List<Map<String, String>> getRequestMethods() {
    return [
      {'value': 'GET', 'label': 'GET'},
      {'value': 'POST', 'label': 'POST'},
      {'value': 'PUT', 'label': 'PUT'},
      {'value': 'DELETE', 'label': 'DELETE'},
      {'value': 'PATCH', 'label': 'PATCH'},
    ];
  }

  /// Gets default values for numeric fields
  static Map<String, dynamic> getDefaultNumericValues() {
    return {
      'timeoutSec': 30,
      'batchSize': 10,
      'rateLimitSecond': 1.0,
      'maxRetries': 3,
    };
  }

  /// Validates and sanitizes configuration values
  static ApiConfig sanitizeConfig(ApiConfig config) {
    return config.copyWith(
      baseUrl: config.baseUrl.trim(),
      endpointPath: config.endpointPath.trim(),
      token: config.token.trim(),
      apiKey: config.apiKey.trim(),
      username: config.username.trim(),
      password: config.password.trim(),
      stringKeys: config.stringKeys.map((key) => key.trim()).where((key) => key.isNotEmpty).toList(),
    );
  }

  /// Checks if two configurations are equal
  static bool areConfigsEqual(ApiConfig config1, ApiConfig config2) {
    return config1.baseUrl == config2.baseUrl &&
        config1.endpointPath == config2.endpointPath &&
        config1.token == config2.token &&
        config1.apiKey == config2.apiKey &&
        config1.username == config2.username &&
        config1.password == config2.password &&
        config1.timeoutSec == config2.timeoutSec &&
        config1.batchSize == config2.batchSize &&
        config1.rateLimitSecond == config2.rateLimitSecond &&
        config1.maxRetries == config2.maxRetries &&
        config1.requestMethod == config2.requestMethod &&
        config1.authMethod == config2.authMethod &&
        _listEquals(config1.stringKeys, config2.stringKeys);
  }

  /// Helper method to compare lists
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// Gets configuration summary for display
  static Map<String, String> getConfigSummary(ApiConfig config) {
    return {
      'Base URL': config.baseUrl.isEmpty ? 'Not set' : config.baseUrl,
      'Endpoint': config.endpointPath.isEmpty ? 'Not set' : config.endpointPath,
      'Method': config.requestMethod,
      'Auth': _getAuthMethodDisplayName(config.authMethod),
      'Timeout': '${config.timeoutSec}s',
      'Batch Size': config.batchSize.toString(),
      'Rate Limit': '${config.rateLimitSecond}s',
      'Max Retries': config.maxRetries.toString(),
    };
  }

  /// Gets display name for authentication method
  static String _getAuthMethodDisplayName(String authMethod) {
    switch (authMethod) {
      case 'bearer':
        return 'Bearer Token';
      case 'api_key':
        return 'API Key';
      case 'basic':
        return 'Basic Auth';
      case 'none':
        return 'None';
      default:
        return authMethod;
    }
  }
}
