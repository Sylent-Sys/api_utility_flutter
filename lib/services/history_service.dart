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
  }

  Future<void> removeFromHistory(String historyId) async {
    final currentHistory = await getHistory();
    
    currentHistory.removeWhere((h) => h.id == historyId);
    
    // Save to storage
    await _saveHistoryToFile(currentHistory);
    
    // Update cache
    _cachedHistory = currentHistory;
  }

  Future<void> clearHistory() async {
    try {
      final historyFile = File(_folderService.historyFilePath);
      if (await historyFile.exists()) {
        await historyFile.delete();
      }
      _cachedHistory = [];
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  /// Save history to file
  Future<void> _saveHistoryToFile(List<ProcessingHistory> history) async {
    try {
      final historyFile = File(_folderService.historyFilePath);
      final historyJson = json.encode(
        history.map((h) => h.toJson()).toList(),
      );
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
             h.outputPath.toLowerCase().contains(queryLower);
    }).toList();
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
