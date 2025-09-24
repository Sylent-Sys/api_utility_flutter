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

  // Tab-specific processing states
  final Map<String, bool> _tabLoadingStates = {};
  final Map<String, String?> _tabErrorStates = {};
  final Map<String, ProcessingResult?> _tabResultStates = {};
  final Map<String, bool> _tabProcessingStates = {};
  bool _autoSaveTabs = true;
  Timer? _autoSaveDebounce;

  // Getters
  TabManager get tabManager => _tabManager;
  bool get isLoading => _getCurrentTabLoadingState();
  String? get error => _getCurrentTabErrorState();
  ProcessingResult? get lastResult => _getCurrentTabResultState();
  bool get isProcessing => _getCurrentTabProcessingState();

  // Current tab getters
  TabData? get currentTab => _tabManager.activeTab;
  ApiConfig get currentConfig => currentTab?.config ?? const ApiConfig();
  String? get currentSelectedFilePath => currentTab?.selectedFilePath;

  // Helper methods for tab-specific states
  bool _getCurrentTabLoadingState() {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return false;
    return _tabLoadingStates[currentTabId] ?? false;
  }

  String? _getCurrentTabErrorState() {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return null;
    return _tabErrorStates[currentTabId];
  }

  ProcessingResult? _getCurrentTabResultState() {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return null;
    return _tabResultStates[currentTabId];
  }

  bool _getCurrentTabProcessingState() {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return false;
    return _tabProcessingStates[currentTabId] ?? false;
  }

  void _setCurrentTabLoadingState(bool loading) {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return;
    _tabLoadingStates[currentTabId] = loading;
    notifyListeners();
  }

  void _setCurrentTabErrorState(String? error) {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return;
    _tabErrorStates[currentTabId] = error;
    notifyListeners();
  }

  void _setCurrentTabResultState(ProcessingResult? result) {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return;
    _tabResultStates[currentTabId] = result;
    notifyListeners();
  }

  void _setCurrentTabProcessingState(bool processing) {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) return;
    _tabProcessingStates[currentTabId] = processing;
    notifyListeners();
  }

  // Streams - use tab-specific streams for better isolation
  Stream<ProcessingProgress> get progressStream {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) {
      return _processingService.progressStream; // Fallback to global stream
    }
    return _processingService.getTabProgressStream(currentTabId);
  }
  
  Stream<List<ApiResult>> get resultsStream {
    final currentTabId = currentTab?.id;
    if (currentTabId == null) {
      return _processingService.resultsStream; // Fallback to global stream
    }
    return _processingService.getTabResultsStream(currentTabId);
  }

  TabAppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setCurrentTabLoadingState(true);
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
      _setCurrentTabErrorState(null);
    } catch (e) {
      _setCurrentTabErrorState('Failed to initialize tabs: $e');
    } finally {
      _setCurrentTabLoadingState(false);
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
    // Clean up tab-specific states when closing a tab
    _tabLoadingStates.remove(tabId);
    _tabErrorStates.remove(tabId);
    _tabResultStates.remove(tabId);
    _tabProcessingStates.remove(tabId);
    
    _tabManager.closeTab(tabId);
    notifyListeners();
    if (_autoSaveTabs) _scheduleAutoSave();
  }

  void switchToTab(String tabId) {
    _tabManager.switchToTab(tabId);
    // Don't clear global processing state - let it continue in background
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

    _setCurrentTabLoadingState(true);
    try {
      _tabManager.updateTabConfig(currentTab!.id, config);
      await _tabManager.saveTabs();
      _setCurrentTabErrorState(null);
      notifyListeners();
    } catch (e) {
      _setCurrentTabErrorState('Failed to save configuration: $e');
    } finally {
      _setCurrentTabLoadingState(false);
    }
  }

  Future<void> resetCurrentTabConfig() async {
    if (currentTab == null) return;

    _setCurrentTabLoadingState(true);
    try {
      _tabManager.updateTabConfig(currentTab!.id, const ApiConfig());
      await _tabManager.saveTabs();
      _setCurrentTabErrorState(null);
      notifyListeners();
    } catch (e) {
      _setCurrentTabErrorState('Failed to reset configuration: $e');
    } finally {
      _setCurrentTabLoadingState(false);
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

    _setCurrentTabLoadingState(true);
    _setCurrentTabProcessingState(true);
    _setCurrentTabErrorState(null);
    _setCurrentTabResultState(null); // Clear previous result when starting new processing

    try {
      final result = await _processingService.processData(
        config: currentConfig,
        inputFilePath: currentTab!.selectedFilePath!,
        testRows: testRows,
        tabId: currentTab!.id,
        tabName: currentTab!.title,
        tabCreatedAt: currentTab!.createdAt,
      );

      _setCurrentTabResultState(result);
      return result;
    } catch (e) {
      _setCurrentTabErrorState('Processing failed: $e');
      rethrow;
    } finally {
      _setCurrentTabLoadingState(false);
      _setCurrentTabProcessingState(false);
    }
  }

  void cancelProcessing() {
    final currentTabId = currentTab?.id;
    if (currentTabId != null) {
      _processingService.cancelProcessing(currentTabId);
    } else {
      _processingService.cancelProcessing(); // Cancel all
    }
    _setCurrentTabProcessingState(false);
  }

  // Error handling
  void clearError() {
    _setCurrentTabErrorState(null);
  }

  @override
  void dispose() {
    _processingService.dispose();
    _tabManager.removeListener(_onTabManagerChanged);
    _autoSaveDebounce?.cancel();
    super.dispose();
  }
}
