import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/config.dart';
import '../models/result.dart';
import '../models/processing_history.dart';
import 'api_service.dart';
import 'file_service.dart';
import 'history_service.dart';

class ProcessingService {
  static ProcessingService? _instance;
  static ProcessingService get instance => _instance ??= ProcessingService._();

  ProcessingService._();

  final ApiService _apiService = ApiService.instance;
  final FileService _fileService = FileService.instance;
  final HistoryService _historyService = HistoryService.instance;
  final Uuid _uuid = const Uuid();

  // Support for multiple concurrent processing sessions
  final Map<String, StreamController<ProcessingProgress>> _progressControllers = {};
  final Map<String, StreamController<List<ApiResult>>> _resultsControllers = {};
  final Map<String, bool> _processingStates = {};
  final Map<String, bool> _cancelledStates = {};

  // Global streams for backward compatibility
  StreamController<ProcessingProgress>? _globalProgressController;
  StreamController<List<ApiResult>>? _globalResultsController;

  Stream<ProcessingProgress> get progressStream {
    _globalProgressController ??= StreamController<ProcessingProgress>.broadcast();
    return _globalProgressController!.stream;
  }

  Stream<List<ApiResult>> get resultsStream {
    _globalResultsController ??= StreamController<List<ApiResult>>.broadcast();
    return _globalResultsController!.stream;
  }

  bool get isProcessing => _processingStates.values.any((processing) => processing);

  // New methods for tab-specific processing
  bool isTabProcessing(String tabId) => _processingStates[tabId] ?? false;
  
  Stream<ProcessingProgress> getTabProgressStream(String tabId) {
    _progressControllers[tabId] ??= StreamController<ProcessingProgress>.broadcast();
    return _progressControllers[tabId]!.stream;
  }

  Stream<List<ApiResult>> getTabResultsStream(String tabId) {
    _resultsControllers[tabId] ??= StreamController<List<ApiResult>>.broadcast();
    return _resultsControllers[tabId]!.stream;
  }

  Future<ProcessingResult> processData({
    required ApiConfig config,
    required String inputFilePath,
    int? testRows,
    String? tabId,
    String? tabName,
    DateTime? tabCreatedAt,
  }) async {
    // Use tabId as session identifier, fallback to 'default' for backward compatibility
    final sessionId = tabId ?? 'default';
    
    if (_processingStates[sessionId] == true) {
      throw Exception('Processing is already in progress for this tab');
    }

    _processingStates[sessionId] = true;
    _cancelledStates[sessionId] = false;

    try {
      // Initialize session-specific controllers
      _progressControllers[sessionId] ??= StreamController<ProcessingProgress>.broadcast();
      _resultsControllers[sessionId] ??= StreamController<List<ApiResult>>.broadcast();
      
      // Also initialize global controllers for backward compatibility
      _globalProgressController ??= StreamController<ProcessingProgress>.broadcast();
      _globalResultsController ??= StreamController<List<ApiResult>>.broadcast();

      // Read input data
      _updateProgress(sessionId, 0, 'Reading input file...', 0, 0);
      final data = await _fileService.readDataFile(
        inputFilePath,
        testRows: testRows,
      );

      if (data.isEmpty) {
        throw Exception('No data found in input file');
      }

      final totalRows = data.length;
      final results = <ApiResult>[];
      int processedRows = 0;
      int successCount = 0;
      int errorCount = 0;

      _updateProgress(
        sessionId,
        10,
        'Starting API processing...',
        processedRows,
        totalRows,
      );

      // Process data in batches
      final batchSize = config.batchSize > 0 ? config.batchSize : 10;
      final batches = _createBatches(data, batchSize);

      for (int batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        if (_cancelledStates[sessionId] == true) {
          throw Exception('Processing cancelled by user');
        }

        final batch = batches[batchIndex];
        _updateProgress(
          sessionId,
          10 + (batchIndex * 80 / batches.length),
          'Processing batch ${batchIndex + 1}/${batches.length}...',
          processedRows,
          totalRows,
        );

        // Process batch concurrently
        final batchResults = await _processBatch(config, batch);
        results.addAll(batchResults);

        // Update counters
        for (final result in batchResults) {
          if (result.isSuccess) {
            successCount++;
          } else {
            errorCount++;
          }
        }

        processedRows += batch.length;
        _resultsControllers[sessionId]!.add(List.from(results));
        _globalResultsController?.add(List.from(results));
      }

      _updateProgress(sessionId, 95, 'Saving results...', processedRows, totalRows);

      // Save results
      final outputPath = await _fileService.saveResults(
        results.map((r) => r.toJson()).toList(),
        config.outputPattern,
      );

      // Save to history with tab information
      final timestamp = DateTime.now();
      final history = ProcessingHistory(
        id: tabId != null && tabName != null 
            ? ProcessingHistory.generateTabHistoryId(tabName, tabId, timestamp)
            : _uuid.v4(),
        timestamp: timestamp,
        inputFileName: _fileService.getFileName(inputFilePath),
        inputFilePath: inputFilePath,
        outputPath: outputPath,
        totalRows: totalRows,
        successCount: successCount,
        errorCount: errorCount,
        configName: '${config.baseUrl}${config.endpointPath}',
        results: results,
        isTestMode: testRows != null,
        testRows: testRows,
        tabId: tabId ?? '',
        tabName: tabName ?? 'Unknown Tab',
        tabCreatedAt: tabCreatedAt ?? DateTime.now(),
      );

      await _historyService.addToHistory(history);

      _updateProgress(sessionId, 100, 'Processing completed!', processedRows, totalRows);

      return ProcessingResult(
        success: true,
        totalRows: totalRows,
        successCount: successCount,
        errorCount: errorCount,
        results: results,
        outputPath: outputPath,
      );
    } catch (e) {
      _updateProgress(sessionId, 0, 'Error: $e', 0, 0);
      return ProcessingResult(
        success: false,
        error: e.toString(),
        totalRows: 0,
        successCount: 0,
        errorCount: 0,
        results: [],
      );
    } finally {
      _processingStates[sessionId] = false;
    }
  }

  List<List<Map<String, dynamic>>> _createBatches(
    List<Map<String, dynamic>> data,
    int batchSize,
  ) {
    final batches = <List<Map<String, dynamic>>>[];

    for (int i = 0; i < data.length; i += batchSize) {
      final end = (i + batchSize < data.length) ? i + batchSize : data.length;
      batches.add(data.sublist(i, end));
    }

    return batches;
  }

  Future<List<ApiResult>> _processBatch(
    ApiConfig config,
    List<Map<String, dynamic>> batch,
  ) async {
    final futures = batch.map((row) => _apiService.callApi(config, row));
    return await Future.wait(futures);
  }

  void _updateProgress(
    String sessionId,
    double percentage,
    String message,
    int processed,
    int total,
  ) {
    final progress = ProcessingProgress(
      percentage: percentage,
      message: message,
      processedRows: processed,
      totalRows: total,
    );
    
    // Update session-specific progress
    _progressControllers[sessionId]?.add(progress);
    
    // Also update global progress for backward compatibility
    _globalProgressController?.add(progress);
  }

  void cancelProcessing([String? tabId]) {
    if (tabId != null) {
      _cancelledStates[tabId] = true;
    } else {
      // Cancel all processing sessions
      for (final key in _cancelledStates.keys) {
        _cancelledStates[key] = true;
      }
    }
  }

  void clearProcessingState([String? tabId]) {
    if (tabId != null) {
      _processingStates[tabId] = false;
      _cancelledStates[tabId] = false;
      // Clear any pending progress/results for this tab
      _progressControllers[tabId]?.add(ProcessingProgress(
        percentage: 0,
        message: '',
        processedRows: 0,
        totalRows: 0,
      ));
    } else {
      // Clear all processing states
      _processingStates.clear();
      _cancelledStates.clear();
      // Clear global progress
      _globalProgressController?.add(ProcessingProgress(
        percentage: 0,
        message: '',
        processedRows: 0,
        totalRows: 0,
      ));
    }
  }

  void dispose() {
    // Close all session-specific controllers
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    for (final controller in _resultsControllers.values) {
      controller.close();
    }
    
    // Close global controllers
    _globalProgressController?.close();
    _globalResultsController?.close();
    
    // Clear all maps
    _progressControllers.clear();
    _resultsControllers.clear();
    _processingStates.clear();
    _cancelledStates.clear();
    
    _globalProgressController = null;
    _globalResultsController = null;
  }
}

class ProcessingProgress {
  final double percentage;
  final String message;
  final int processedRows;
  final int totalRows;

  const ProcessingProgress({
    required this.percentage,
    required this.message,
    required this.processedRows,
    required this.totalRows,
  });

  double get progressRatio => totalRows > 0 ? processedRows / totalRows : 0.0;
}

class ProcessingResult {
  final bool success;
  final String? error;
  final int totalRows;
  final int successCount;
  final int errorCount;
  final List<ApiResult> results;
  final String? outputPath;

  const ProcessingResult({
    required this.success,
    this.error,
    required this.totalRows,
    required this.successCount,
    required this.errorCount,
    required this.results,
    this.outputPath,
  });

  double get successRate => totalRows > 0 ? successCount / totalRows : 0.0;
  double get errorRate => totalRows > 0 ? errorCount / totalRows : 0.0;
}
