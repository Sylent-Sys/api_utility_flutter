import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/processing_history.dart';
import 'folder_structure_service.dart';

class HistoryService {
  static const int _maxHistoryItems = 50; // Limit to prevent storage bloat

  static HistoryService? _instance;
  static HistoryService get instance => _instance ??= HistoryService._();

  HistoryService._();

  final FolderStructureService _folderService = FolderStructureService.instance;
  List<ProcessingHistory>? _cachedHistory;
  final StreamController<List<ProcessingHistory>> _historyController = 
      StreamController<List<ProcessingHistory>>.broadcast();

  /// Stream of history changes
  Stream<List<ProcessingHistory>> get historyStream => _historyController.stream;

  Future<List<ProcessingHistory>> getHistory() async {
    if (_cachedHistory != null) return _cachedHistory!;

    try {
      final historyFile = File(_folderService.historyFilePath);

      if (await historyFile.exists()) {
        final historyJson = await historyFile.readAsString();
        final historyList = json.decode(historyJson) as List;
        _cachedHistory = historyList
            .map((item) => ProcessingHistory.fromJson(item))
            .toList();
        // Sort by timestamp (newest first)
        _cachedHistory!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return _cachedHistory!;
      }
    } catch (e) {
      // If parsing fails, return empty list
    }

    _cachedHistory = [];
    return _cachedHistory!;
  }

  Future<void> addToHistory(ProcessingHistory history) async {
    final currentHistory = await getHistory();

    // Add new history to the beginning
    currentHistory.insert(0, history);

    // Limit the number of history items
    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
    }

    // Save to storage
    await _saveHistoryToFile(currentHistory);

    // Update cache
    _cachedHistory = currentHistory;
    
    // Notify listeners
    _historyController.add(List.from(currentHistory));
  }

  Future<void> removeFromHistory(String historyId) async {
    final currentHistory = await getHistory();

    currentHistory.removeWhere((h) => h.id == historyId);

    // Save to storage
    await _saveHistoryToFile(currentHistory);

    // Update cache
    _cachedHistory = currentHistory;
    
    // Notify listeners
    _historyController.add(List.from(currentHistory));
  }

  Future<void> clearHistory() async {
    try {
      final historyFile = File(_folderService.historyFilePath);
      if (await historyFile.exists()) {
        await historyFile.delete();
      }
      _cachedHistory = [];
      
      // Notify listeners
      _historyController.add([]);
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  /// Save history to file
  Future<void> _saveHistoryToFile(List<ProcessingHistory> history) async {
    try {
      final historyFile = File(_folderService.historyFilePath);
      final historyJson = json.encode(history.map((h) => h.toJson()).toList());
      await historyFile.writeAsString(historyJson);
    } catch (e) {
      throw Exception('Failed to save history: $e');
    }
  }

  Future<ProcessingHistory?> getHistoryById(String id) async {
    final history = await getHistory();
    try {
      return history.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProcessingHistory>> searchHistory(String query) async {
    final history = await getHistory();
    final queryLower = query.toLowerCase();

    return history.where((h) {
      return h.inputFileName.toLowerCase().contains(queryLower) ||
          h.configName.toLowerCase().contains(queryLower) ||
          h.outputPath.toLowerCase().contains(queryLower) ||
          h.tabName.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Get history for a specific tab
  Future<List<ProcessingHistory>> getHistoryByTab(String tabId) async {
    final history = await getHistory();
    return history.where((h) => h.tabId == tabId).toList();
  }

  /// Refresh history from storage and notify listeners
  Future<void> refreshHistory() async {
    _cachedHistory = null; // Clear cache to force reload
    final history = await getHistory();
    _historyController.add(List.from(history));
  }

  /// Dispose the stream controller
  void dispose() {
    _historyController.close();
  }

  // Get history grouped by tab
  Future<Map<String, List<ProcessingHistory>>> getHistoryByTabs() async {
    final history = await getHistory();
    final Map<String, List<ProcessingHistory>> groupedHistory = {};
    
    for (final h in history) {
      if (!groupedHistory.containsKey(h.tabId)) {
        groupedHistory[h.tabId] = [];
      }
      groupedHistory[h.tabId]!.add(h);
    }
    
    // Sort each tab's history by timestamp (newest first)
    for (final tabId in groupedHistory.keys) {
      groupedHistory[tabId]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    
    return groupedHistory;
  }

  // Get all unique tab names from history (including deleted tabs)
  Future<List<String>> getAllTabNames() async {
    final history = await getHistory();
    final Set<String> tabNames = {};
    
    for (final h in history) {
      tabNames.add(h.tabName);
    }
    
    return tabNames.toList()..sort();
  }

  Future<List<ProcessingHistory>> getHistoryByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final history = await getHistory();

    return history.where((h) {
      return h.timestamp.isAfter(startDate) && h.timestamp.isBefore(endDate);
    }).toList();
  }

  Future<Map<String, int>> getHistoryStats() async {
    final history = await getHistory();

    int totalProcessings = history.length;
    int totalRows = history.fold(0, (sum, h) => sum + h.totalRows);
    int totalSuccess = history.fold(0, (sum, h) => sum + h.successCount);
    int totalErrors = history.fold(0, (sum, h) => sum + h.errorCount);
    int testModeCount = history.where((h) => h.isTestMode).length;

    return {
      'totalProcessings': totalProcessings,
      'totalRows': totalRows,
      'totalSuccess': totalSuccess,
      'totalErrors': totalErrors,
      'testModeCount': testModeCount,
    };
  }
}
