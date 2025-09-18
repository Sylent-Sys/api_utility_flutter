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

  StreamController<ProcessingProgress>? _progressController;
  StreamController<List<ApiResult>>? _resultsController;

  bool _isProcessing = false;
  bool _isCancelled = false;

  Stream<ProcessingProgress> get progressStream {
    _progressController ??= StreamController<ProcessingProgress>.broadcast();
    return _progressController!.stream;
  }

  Stream<List<ApiResult>> get resultsStream {
    _resultsController ??= StreamController<List<ApiResult>>.broadcast();
    return _resultsController!.stream;
  }

  bool get isProcessing => _isProcessing;

  Future<ProcessingResult> processData({
    required ApiConfig config,
    required String inputFilePath,
    int? testRows,
    String? tabId,
    String? tabName,
    DateTime? tabCreatedAt,
  }) async {
    if (_isProcessing) {
      throw Exception('Processing is already in progress');
    }

    _isProcessing = true;
    _isCancelled = false;

    try {
      _progressController ??= StreamController<ProcessingProgress>.broadcast();
      _resultsController ??= StreamController<List<ApiResult>>.broadcast();

      // Read input data
      _updateProgress(0, 'Reading input file...', 0, 0);
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
        10,
        'Starting API processing...',
        processedRows,
        totalRows,
      );

      // Process data in batches
      final batchSize = config.batchSize > 0 ? config.batchSize : 10;
      final batches = _createBatches(data, batchSize);

      for (int batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        if (_isCancelled) {
          throw Exception('Processing cancelled by user');
        }

        final batch = batches[batchIndex];
        _updateProgress(
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
        _resultsController!.add(List.from(results));
      }

      _updateProgress(95, 'Saving results...', processedRows, totalRows);

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

      _updateProgress(100, 'Processing completed!', processedRows, totalRows);

      return ProcessingResult(
        success: true,
        totalRows: totalRows,
        successCount: successCount,
        errorCount: errorCount,
        results: results,
        outputPath: outputPath,
      );
    } catch (e) {
      _updateProgress(0, 'Error: $e', 0, 0);
      return ProcessingResult(
        success: false,
        error: e.toString(),
        totalRows: 0,
        successCount: 0,
        errorCount: 0,
        results: [],
      );
    } finally {
      _isProcessing = false;
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
    _progressController?.add(progress);
  }

  void cancelProcessing() {
    _isCancelled = true;
  }

  void dispose() {
    _progressController?.close();
    _resultsController?.close();
    _progressController = null;
    _resultsController = null;
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
