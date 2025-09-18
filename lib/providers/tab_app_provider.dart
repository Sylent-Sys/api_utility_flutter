import 'package:flutter/foundation.dart';
import '../models/config.dart';
import '../models/result.dart';
import '../models/tab.dart';
import '../services/processing_service.dart';
import 'tab_manager.dart';

class TabAppProvider extends ChangeNotifier {
  final ProcessingService _processingService = ProcessingService.instance;
  final TabManager _tabManager = TabManager();

  bool _isLoading = false;
  String? _error;
  ProcessingResult? _lastResult;

  // Getters
  TabManager get tabManager => _tabManager;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProcessingResult? get lastResult => _lastResult;
  bool get isProcessing => _processingService.isProcessing;

  // Current tab getters
  TabData? get currentTab => _tabManager.activeTab;
  ApiConfig get currentConfig => currentTab?.config ?? const ApiConfig();
  String? get currentSelectedFilePath => currentTab?.selectedFilePath;

  // Streams
  Stream<ProcessingProgress> get progressStream =>
      _processingService.progressStream;
  Stream<List<ApiResult>> get resultsStream => _processingService.resultsStream;

  TabAppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await _tabManager.loadTabs();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize tabs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Tab management methods
  void addNewTab() {
    _tabManager.addNewTab();
    notifyListeners();
  }

  void closeTab(String tabId) {
    _tabManager.closeTab(tabId);
    notifyListeners();
  }

  void switchToTab(String tabId) {
    _tabManager.switchToTab(tabId);
    notifyListeners();
  }

  void updateTabTitle(String tabId, String title) {
    _tabManager.updateTabTitle(tabId, title);
    notifyListeners();
  }

  void duplicateTab(String tabId) {
    _tabManager.duplicateTab(tabId);
    notifyListeners();
  }

  // Configuration methods
  Future<void> saveCurrentTabConfig(ApiConfig config) async {
    if (currentTab == null) return;

    _setLoading(true);
    try {
      _tabManager.updateTabConfig(currentTab!.id, config);
      await _tabManager.saveTabs();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to save configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetCurrentTabConfig() async {
    if (currentTab == null) return;

    _setLoading(true);
    try {
      _tabManager.updateTabConfig(currentTab!.id, const ApiConfig());
      await _tabManager.saveTabs();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset configuration: $e');
    } finally {
      _setLoading(false);
    }
  }

  // File selection methods
  void setCurrentTabFilePath(String? filePath) {
    if (currentTab == null) return;
    
    _tabManager.updateTabFilePath(currentTab!.id, filePath);
    notifyListeners();
  }

  // Processing methods
  Future<ProcessingResult> processCurrentTabData({int? testRows}) async {
    if (currentTab == null) {
      throw Exception('No active tab');
    }

    if (currentTab!.selectedFilePath == null) {
      throw Exception('No file selected');
    }

    if (!currentConfig.isValid) {
      throw Exception('Configuration is invalid. Please check your settings.');
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _processingService.processData(
        config: currentConfig,
        inputFilePath: currentTab!.selectedFilePath!,
        testRows: testRows,
        tabId: currentTab!.id,
        tabName: currentTab!.title,
        tabCreatedAt: currentTab!.createdAt,
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

  // Error handling
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
