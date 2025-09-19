import '../models/config.dart';

/// Utility class for form validation logic
class ValidationUtils {
  /// Validates if a URL is properly formatted
  static String? validateUrl(String? value, {String fieldName = 'URL'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    // Validate URL format
    final uri = Uri.tryParse(value);
    if (uri == null) {
      // Try adding http:// if no scheme
      final uriWithScheme = Uri.tryParse('http://$value');
      if (uriWithScheme == null || !uriWithScheme.hasAuthority) {
        return '$fieldName must be a valid URL';
      }
    } else if (!uri.hasScheme && !uri.hasAuthority) {
      return '$fieldName must be a valid URL';
    }
    
    return null;
  }

  /// Validates if a field is not empty
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates if a value is a positive integer
  static String? validatePositiveInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null || intValue <= 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }

  /// Validates if a value is a non-negative integer
  static String? validateNonNegativeInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0) {
      return '$fieldName must be a non-negative number';
    }
    
    return null;
  }

  /// Validates if a value is a non-negative double
  static String? validateNonNegativeDouble(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final doubleValue = double.tryParse(value);
    if (doubleValue == null || doubleValue < 0) {
      return '$fieldName must be a non-negative number';
    }
    
    return null;
  }

  /// Validates authentication fields based on auth method
  static String? validateAuthField(String? value, String authMethod, String fieldType) {
    if (authMethod == fieldType && (value == null || value.isEmpty)) {
      switch (fieldType) {
        case 'bearer':
          return 'Token is required for Bearer authentication';
        case 'api_key':
          return 'API Key is required for API Key authentication';
        case 'basic':
          return 'Username is required for Basic authentication';
        default:
          return 'Field is required';
      }
    }
    return null;
  }

  /// Validates password field for basic authentication
  static String? validatePassword(String? value, String authMethod) {
    if (authMethod == 'basic' && (value == null || value.isEmpty)) {
      return 'Password is required for Basic authentication';
    }
    return null;
  }

  /// Gets all validation errors for an ApiConfig
  static List<String> getConfigValidationErrors(ApiConfig config) {
    final errors = <String>[];
    
    // Base URL validation
    final baseUrlError = validateUrl(config.baseUrl, fieldName: 'Base URL');
    if (baseUrlError != null) {
      errors.add(baseUrlError);
    }
    
    // Endpoint Path validation
    final endpointError = validateRequired(config.endpointPath, fieldName: 'Endpoint Path');
    if (endpointError != null) {
      errors.add(endpointError);
    }
    
    // Authentication validation
    if (config.authMethod == 'bearer' && config.token.isEmpty) {
      errors.add('Bearer Token is required');
    }
    
    if (config.authMethod == 'api_key' && config.apiKey.isEmpty) {
      errors.add('API Key is required');
    }
    
    if (config.authMethod == 'basic') {
      if (config.username.isEmpty) {
        errors.add('Username is required for Basic Auth');
      }
      if (config.password.isEmpty) {
        errors.add('Password is required for Basic Auth');
      }
    }
    
    // Numeric field validation
    if (config.timeoutSec <= 0) {
      errors.add('Timeout must be greater than 0');
    }
    
    if (config.batchSize <= 0) {
      errors.add('Batch Size must be greater than 0');
    }
    
    if (config.rateLimitSecond < 0) {
      errors.add('Rate Limit cannot be negative');
    }
    
    if (config.maxRetries < 0) {
      errors.add('Max Retries cannot be negative');
    }
    
    return errors;
  }

  /// Checks if a configuration is valid
  static bool isConfigValid(ApiConfig config) {
    return getConfigValidationErrors(config).isEmpty;
  }
}
