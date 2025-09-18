import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/config.dart';
import '../models/result.dart';
import '../models/tab.dart';
import '../services/processing_service.dart';
import '../services/config_service.dart';
import 'tab_manager.dart';

class TabAppProvider extends ChangeNotifier {
  final ProcessingService _processingService = ProcessingService.instance;
  final TabManager _tabManager = TabManager();
  final ConfigService _configService = ConfigService.instance;

  bool _isLoading = false;
  String? _error;
  ProcessingResult? _lastResult;
  bool _autoSaveTabs = true;
  Timer? _autoSaveDebounce;

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
      // Load auto-save preference from app settings
      try {
        final settingsJson = await _configService.loadAppSettings();
        if (settingsJson != null && settingsJson.containsKey('autoSaveTabs')) {
          _autoSaveTabs = settingsJson['autoSaveTabs'] == true;
        }
      } catch (_) {
        // ignore and keep default
      }

      await _tabManager.loadTabs();
      // Listen to tab manager changes for auto-save
      _tabManager.addListener(_onTabManagerChanged);
      _clearError();
    } catch (e) {
      _setError('Failed to initialize tabs: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _onTabManagerChanged() {
    if (_autoSaveTabs) {
      _scheduleAutoSave();
    }
  }

  // Live update for Auto Save Tabs
  void setAutoSaveTabs(bool enabled) {
    _autoSaveTabs = enabled;
    if (_autoSaveTabs) {
      _scheduleAutoSave();
    }
    notifyListeners();
  }

  void _scheduleAutoSave() {
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await _tabManager.saveTabs();
      } catch (e) {
        debugPrint('Auto-save tabs failed: $e');
      }
    });
  }

  // Tab management methods
  void addNewTab() {
    _tabManager.addNewTab();
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
  }

  void closeTab(String tabId) {
    _tabManager.closeTab(tabId);
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
  }

  void switchToTab(String tabId) {
    _tabManager.switchToTab(tabId);
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
  }

  void updateTabTitle(String tabId, String title) {
    _tabManager.updateTabTitle(tabId, title);
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
  }

  void duplicateTab(String tabId) {
    _tabManager.duplicateTab(tabId);
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
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
    if (_autoSaveTabs) _scheduleAutoSave();
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
    _tabManager.removeListener(_onTabManagerChanged);
    _autoSaveDebounce?.cancel();
    super.dispose();
  }
}
