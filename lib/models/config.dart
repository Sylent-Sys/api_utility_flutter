class ApiConfig {
  // Auth
  final String token;
  final String apiKey;
  final String username;
  final String password;

  // URL & Path
  final String baseUrl;
  final String endpointPath;

  // IO
  final String inputFile;
  final String outputDir;
  final List<String> stringKeys;

  // Output filename pattern
  final String outputPattern;

  // Controls
  final int timeoutSec;
  final int batchSize;
  final double rateLimitSecond;
  final int maxRetries;

  // Request
  final String requestMethod; // "GET" or "POST"
  final String authMethod; // "bearer", "api_key", "basic", "none"

  // Custom headers
  final Map<String, String> customHeaders;

  const ApiConfig({
    this.token = '',
    this.apiKey = '',
    this.username = '',
    this.password = '',
    this.baseUrl = 'http://YourBaseUrl',
    this.endpointPath = '/YourEndpointPath',
    this.inputFile = 'test.csv',
    this.outputDir = 'output',
    this.stringKeys = const ['id'],
    this.outputPattern = 'results_{date}',
    this.timeoutSec = 240,
    this.batchSize = 10,
    this.rateLimitSecond = 0.5,
    this.maxRetries = 3,
    this.requestMethod = 'GET',
    this.authMethod = 'bearer',
    this.customHeaders = const {'Content-Type': 'application/json'},
  });

  ApiConfig copyWith({
    String? token,
    String? apiKey,
    String? username,
    String? password,
    String? baseUrl,
    String? endpointPath,
    String? inputFile,
    String? outputDir,
    List<String>? stringKeys,
    String? outputPattern,
    int? timeoutSec,
    int? batchSize,
    double? rateLimitSecond,
    int? maxRetries,
    String? requestMethod,
    String? authMethod,
    Map<String, String>? customHeaders,
  }) {
    return ApiConfig(
      token: token ?? this.token,
      apiKey: apiKey ?? this.apiKey,
      username: username ?? this.username,
      password: password ?? this.password,
      baseUrl: baseUrl ?? this.baseUrl,
      endpointPath: endpointPath ?? this.endpointPath,
      inputFile: inputFile ?? this.inputFile,
      outputDir: outputDir ?? this.outputDir,
      stringKeys: stringKeys ?? this.stringKeys,
      outputPattern: outputPattern ?? this.outputPattern,
      timeoutSec: timeoutSec ?? this.timeoutSec,
      batchSize: batchSize ?? this.batchSize,
      rateLimitSecond: rateLimitSecond ?? this.rateLimitSecond,
      maxRetries: maxRetries ?? this.maxRetries,
      requestMethod: requestMethod ?? this.requestMethod,
      authMethod: authMethod ?? this.authMethod,
      customHeaders: customHeaders ?? this.customHeaders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'apiKey': apiKey,
      'username': username,
      'password': password,
      'baseUrl': baseUrl,
      'endpointPath': endpointPath,
      'inputFile': inputFile,
      'outputDir': outputDir,
      'stringKeys': stringKeys,
      'outputPattern': outputPattern,
      'timeoutSec': timeoutSec,
      'batchSize': batchSize,
      'rateLimitSecond': rateLimitSecond,
      'maxRetries': maxRetries,
      'requestMethod': requestMethod,
      'authMethod': authMethod,
      'customHeaders': customHeaders,
    };
  }

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      token: json['token'] ?? '',
      apiKey: json['apiKey'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      baseUrl: json['baseUrl'] ?? 'http://localhost:7071/api',
      endpointPath: json['endpointPath'] ?? '/FYP/Bengkel/AttendanceMonitoring/Create',
      inputFile: json['inputFile'] ?? 'test.csv',
      outputDir: json['outputDir'] ?? 'output',
      stringKeys: List<String>.from(json['stringKeys'] ?? ['id']),
      outputPattern: json['outputPattern'] ?? 'results_{date}',
      timeoutSec: json['timeoutSec'] ?? 240,
      batchSize: json['batchSize'] ?? 10,
      rateLimitSecond: (json['rateLimitSecond'] ?? 0.5).toDouble(),
      maxRetries: json['maxRetries'] ?? 3,
      requestMethod: json['requestMethod'] ?? 'GET',
      authMethod: json['authMethod'] ?? 'bearer',
      customHeaders: Map<String, String>.from(json['customHeaders'] ?? {'Content-Type': 'application/json'}),
    );
  }

  String get fullUrl => baseUrl.endsWith('/') 
      ? '$baseUrl${endpointPath.startsWith('/') ? endpointPath.substring(1) : endpointPath}'
      : '$baseUrl$endpointPath';

  bool get isValid {
    if (baseUrl.isEmpty) return false;
    if (endpointPath.isEmpty) return false;
    if (authMethod == 'bearer' && token.isEmpty) return false;
    if (authMethod == 'api_key' && apiKey.isEmpty) return false;
    if (authMethod == 'basic' && (username.isEmpty || password.isEmpty)) return false;
    return true;
  }
}
