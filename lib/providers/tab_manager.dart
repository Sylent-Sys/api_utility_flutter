import 'package:flutter/foundation.dart';
import '../models/tab.dart';
import '../models/config.dart';
import '../services/config_service.dart';

class TabManager extends ChangeNotifier {
  final ConfigService _configService = ConfigService.instance;
  
  final List<TabData> _tabs = [];
  String? _activeTabId;
  int _tabCounter = 1;

  // Getters
  List<TabData> get tabs => List.unmodifiable(_tabs);
  String? get activeTabId => _activeTabId;
  TabData? get activeTab => _activeTabId != null 
      ? _tabs.firstWhere((tab) => tab.id == _activeTabId, orElse: () => _tabs.first)
      : null;
  bool get hasTabs => _tabs.isNotEmpty;

  TabManager() {
    _initializeDefaultTab();
  }

  void _initializeDefaultTab() {
    if (_tabs.isEmpty) {
      final defaultTab = TabData(
        id: 'tab_1',
        title: 'Tab 1',
        config: const ApiConfig(),
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );
      _tabs.add(defaultTab);
      _activeTabId = defaultTab.id;
      _tabCounter = 2;
      notifyListeners();
    }
  }

  String _generateTabId() {
    return 'tab_${_tabCounter++}';
  }

  String _generateTabTitle() {
    return 'Tab ${_tabs.length + 1}';
  }

  void addNewTab() {
    final newTab = TabData(
      id: _generateTabId(),
      title: _generateTabTitle(),
      config: const ApiConfig(),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    _tabs.add(newTab);
    _activeTabId = newTab.id;
    notifyListeners();
  }

  void closeTab(String tabId) {
    if (_tabs.length <= 1) {
      // Don't close the last tab
      return;
    }

    final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    _tabs.removeAt(tabIndex);

    // If we closed the active tab, switch to another tab
    if (_activeTabId == tabId) {
      if (tabIndex < _tabs.length) {
        // Switch to the tab at the same position
        _activeTabId = _tabs[tabIndex].id;
      } else {
        // Switch to the last tab
        _activeTabId = _tabs.last.id;
      }
    }

    notifyListeners();
  }

  void switchToTab(String tabId) {
    if (_tabs.any((tab) => tab.id == tabId)) {
      _activeTabId = tabId;
      notifyListeners();
    }
  }

  void updateTabConfig(String tabId, ApiConfig config) {
    final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    _tabs[tabIndex] = _tabs[tabIndex].copyWith(
      config: config,
      lastModified: DateTime.now(),
    );
    notifyListeners();
  }

  void updateTabFilePath(String tabId, String? filePath) {
    final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    _tabs[tabIndex] = _tabs[tabIndex].copyWith(
      selectedFilePath: filePath,
      lastModified: DateTime.now(),
    );
    notifyListeners();
  }

  void updateTabTitle(String tabId, String title) {
    final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    _tabs[tabIndex] = _tabs[tabIndex].copyWith(
      title: title,
      lastModified: DateTime.now(),
    );
    notifyListeners();
  }

  void duplicateTab(String tabId) {
    final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    final originalTab = _tabs[tabIndex];
    final duplicatedTab = TabData(
      id: _generateTabId(),
      title: '${originalTab.title} (Copy)',
      config: originalTab.config,
      selectedFilePath: originalTab.selectedFilePath,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    _tabs.insert(tabIndex + 1, duplicatedTab);
    _activeTabId = duplicatedTab.id;
    notifyListeners();
  }

  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, tab);
    notifyListeners();
  }

  // Persistence methods
  Future<void> saveTabs() async {
    try {
      final tabsJson = _tabs.map((tab) => tab.toJson()).toList();
      await _configService.saveTabs(tabsJson);
    } catch (e) {
      debugPrint('Failed to save tabs: $e');
    }
  }

  Future<void> loadTabs() async {
    try {
      final tabsJson = await _configService.loadTabs();
      if (tabsJson != null && tabsJson.isNotEmpty) {
        _tabs.clear();
        _tabs.addAll(tabsJson.map((json) => TabData.fromJson(json)));
        
        // Set active tab to the first one if none is set
        if (_activeTabId == null || !_tabs.any((tab) => tab.id == _activeTabId)) {
          _activeTabId = _tabs.isNotEmpty ? _tabs.first.id : null;
        }
        
        // Update counter to avoid ID conflicts
        _tabCounter = _tabs.length + 1;
        notifyListeners();
      } else {
        _initializeDefaultTab();
      }
    } catch (e) {
      debugPrint('Failed to load tabs: $e');
      _initializeDefaultTab();
    }
  }

  @override
  void dispose() {
    saveTabs();
    super.dispose();
  }
}
