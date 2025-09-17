import 'package:flutter/foundation.dart';
import '../models/config.dart';
import '../models/result.dart';
import '../services/config_service.dart';
import '../services/processing_service.dart';

class AppProvider extends ChangeNotifier {
  final ConfigService _configService = ConfigService.instance;
  final ProcessingService _processingService = ProcessingService.instance;

  ApiConfig _config = const ApiConfig();
  bool _isLoading = false;
  String? _error;
  String? _selectedFilePath;
  ProcessingResult? _lastResult;

  // Getters
  ApiConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedFilePath => _selectedFilePath;
  ProcessingResult? get lastResult => _lastResult;
  bool get isProcessing => _processingService.isProcessing;

  // Streams
  Stream<ProcessingProgress> get progressStream =>
      _processingService.progressStream;
  Stream<List<ApiResult>> get resultsStream => _processingService.resultsStream;

  AppProvider() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    _setLoading(true);
    try {
      _config = await _configService.getConfig();
      _clearError();
    } catch (e) {
      _setError('Failed to load configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveConfig(ApiConfig newConfig) async {
    _setLoading(true);
    try {
      await _configService.saveConfig(newConfig);
      _config = newConfig;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to save configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetConfig() async {
    _setLoading(true);
    try {
      await _configService.resetToDefault();
      _config = const ApiConfig();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedFilePath(String? filePath) {
    _selectedFilePath = filePath;
    notifyListeners();
  }

  Future<ProcessingResult> processData({int? testRows}) async {
    if (_selectedFilePath == null) {
      throw Exception('No file selected');
    }

    if (!_config.isValid) {
      throw Exception('Configuration is invalid. Please check your settings.');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _processingService.processData(
        config: _config,
        inputFilePath: _selectedFilePath!,
        testRows: testRows,
      );

      _lastResult = result;
      return result;
    } catch (e) {
      _setError('Processing failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void cancelProcessing() {
    _processingService.cancelProcessing();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _processingService.dispose();
    super.dispose();
  }
}
