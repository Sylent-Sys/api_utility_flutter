import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import '../models/config.dart';
import '../models/result.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  Dio? _dio;
  Timer? _rateLimitTimer;

  void _setupDio(ApiConfig config) {
    _dio?.close();

    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: Duration(seconds: config.timeoutSec),
        receiveTimeout: Duration(seconds: config.timeoutSec),
        sendTimeout: Duration(seconds: config.timeoutSec),
        headers: _buildHeaders(config),
      ),
    );

    // Add interceptors for retry logic
    _dio!.interceptors.add(
      RetryInterceptor(
        dio: _dio!,
        logPrint: print,
        retries: config.maxRetries,
        retryDelays: _generateRetryDelays(config.maxRetries),
      ),
    );
  }

  Map<String, String> _buildHeaders(ApiConfig config) {
    final headers = <String, String>{};

    // Add authentication headers
    switch (config.authMethod.toLowerCase()) {
      case 'bearer':
        if (config.token.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${config.token}';
        }
        break;
      case 'api_key':
        if (config.apiKey.isNotEmpty) {
          headers['X-API-Key'] = config.apiKey;
        }
        break;
      case 'basic':
        if (config.username.isNotEmpty && config.password.isNotEmpty) {
          final credentials = '${config.username}:${config.password}';
          final encoded = base64Encode(utf8.encode(credentials));
          headers['Authorization'] = 'Basic $encoded';
        }
        break;
      case 'none':
        // No authentication
        break;
    }

    // Add custom headers
    headers.addAll(config.customHeaders);

    // Ensure Content-Type for POST requests
    if (config.requestMethod.toUpperCase() == 'POST' &&
        !headers.containsKey('Content-Type')) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  List<Duration> _generateRetryDelays(int maxRetries) {
    final delays = <Duration>[];
    for (int i = 0; i < maxRetries; i++) {
      final baseDelay = 300 * pow(2, i); // Exponential backoff
      final jitter = Random().nextInt(250); // Add jitter
      delays.add(Duration(milliseconds: (baseDelay + jitter).toInt()));
    }
    return delays;
  }

  Future<void> _applyRateLimit(double rateLimitSecond) async {
    if (rateLimitSecond > 0) {
      await Future.delayed(
        Duration(milliseconds: (rateLimitSecond * 1000).round()),
      );
    }
  }

  Map<String, dynamic> _stringifyFields(
    Map<String, dynamic> data,
    List<String> stringKeys,
  ) {
    final result = Map<String, dynamic>.from(data);

    for (final key in stringKeys) {
      if (result.containsKey(key)) {
        result[key] = result[key].toString();
      }
    }

    return result;
  }

  Future<ApiResult> callApi(
    ApiConfig config,
    Map<String, dynamic> rowData,
  ) async {
    try {
      _setupDio(config);

      // Apply rate limiting
      await _applyRateLimit(config.rateLimitSecond);

      // Stringify specified fields
      final processedData = _stringifyFields(rowData, config.stringKeys);

      Response response;

      if (config.requestMethod.toUpperCase() == 'POST') {
        response = await _dio!.post(config.endpointPath, data: processedData);
      } else {
        // GET request with query parameters
        response = await _dio!.get(
          config.endpointPath,
          queryParameters: processedData,
        );
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          try {
            responseData =
                json.decode(response.data as String) as Map<String, dynamic>;
          } catch (e) {
            responseData = {'raw': response.data as String};
          }
        } else {
          responseData = {'raw': response.data.toString()};
        }

        return ApiResult.success(responseData);
      } else {
        return ApiResult.error(
          dataGagal: processedData,
          pesanErrorSistem:
              'HTTP ${response.statusCode}: ${response.statusMessage}',
          pesanErrorAPI: response.data?.toString(),
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      String? apiErrorBody;

      if (e.response != null) {
        errorMessage =
            'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}';
        apiErrorBody = e.response!.data?.toString();
      } else {
        errorMessage = e.message ?? 'Network error';
      }

      return ApiResult.error(
        dataGagal: _stringifyFields(rowData, config.stringKeys),
        pesanErrorSistem: errorMessage,
        pesanErrorAPI: apiErrorBody,
      );
    } catch (e) {
      return ApiResult.error(
        dataGagal: _stringifyFields(rowData, config.stringKeys),
        pesanErrorSistem: 'Unexpected error: $e',
      );
    }
  }

  void dispose() {
    _dio?.close();
    _rateLimitTimer?.cancel();
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final attempt = err.requestOptions.extra['retry_attempt'] ?? 0;

      if (attempt < retries) {
        err.requestOptions.extra['retry_attempt'] = attempt + 1;

        logPrint?.call('Retrying request (attempt ${attempt + 1}/$retries)');

        if (attempt < retryDelays.length) {
          await Future.delayed(retryDelays[attempt]);
        }

        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          if (e is DioException) {
            err = e;
          } else {
            err = DioException(requestOptions: err.requestOptions, error: e);
          }
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors and 5xx status codes
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      return statusCode == 429 || (statusCode >= 500 && statusCode < 600);
    }

    return false;
  }
}
