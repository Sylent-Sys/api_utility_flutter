import 'package:flutter/foundation.dart';
import '../services/config_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final ConfigService _configService = ConfigService.instance;
  
  // Tab settings
  bool _tabWrapEnabled = false;
  bool _showTabNumbers = true;
  bool _autoSaveTabs = true;
  bool _includeOutputInBackup = true;
  int _maxTabsPerRow = 5;
  double _tabHeight = 48.0;

  // Display settings
  String _themeMode = 'system'; // 'light', 'dark', 'system'
  String _fontSize = 'normal'; // 'small', 'normal', 'large'

  // Getters
  bool get tabWrapEnabled => _tabWrapEnabled;
  bool get showTabNumbers => _showTabNumbers;
  bool get autoSaveTabs => _autoSaveTabs;
  bool get includeOutputInBackup => _includeOutputInBackup;
  int get maxTabsPerRow => _maxTabsPerRow;
  double get tabHeight => _tabHeight;
  String get themeMode => _themeMode;
  String get fontSize => _fontSize;

  // Tab settings methods
  void setTabWrapEnabled(bool enabled) {
    _tabWrapEnabled = enabled;
    notifyListeners();
  }

  void setShowTabNumbers(bool show) {
    _showTabNumbers = show;
    notifyListeners();
  }

  void setAutoSaveTabs(bool autoSave) {
    _autoSaveTabs = autoSave;
    notifyListeners();
  }

  void setIncludeOutputInBackup(bool include) {
    _includeOutputInBackup = include;
    notifyListeners();
  }

  void setMaxTabsPerRow(int maxTabs) {
    _maxTabsPerRow = maxTabs;
    notifyListeners();
  }

  void setTabHeight(double height) {
    _tabHeight = height;
    notifyListeners();
  }

  // Display settings methods
  void setThemeMode(String mode) {
    if (['light', 'dark', 'system'].contains(mode)) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setFontSize(String size) {
    if (['small', 'normal', 'large'].contains(size)) {
      _fontSize = size;
      notifyListeners();
    }
  }

  // Reset to default settings
  void resetToDefaults() {
    _tabWrapEnabled = false;
    _showTabNumbers = true;
    _autoSaveTabs = true;
    _includeOutputInBackup = true;
    _maxTabsPerRow = 5;
    _tabHeight = 48.0;
    _themeMode = 'system';
    _fontSize = 'normal';
    notifyListeners();
  }

  // Settings to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'tabWrapEnabled': _tabWrapEnabled,
      'showTabNumbers': _showTabNumbers,
      'autoSaveTabs': _autoSaveTabs,
      'includeOutputInBackup': _includeOutputInBackup,
      'maxTabsPerRow': _maxTabsPerRow,
      'tabHeight': _tabHeight,
      'themeMode': _themeMode,
      'fontSize': _fontSize,
    };
  }

  // Load settings from JSON
  void fromJson(Map<String, dynamic> json) {
    _tabWrapEnabled = json['tabWrapEnabled'] ?? false;
    _showTabNumbers = json['showTabNumbers'] ?? true;
    _autoSaveTabs = json['autoSaveTabs'] ?? true;
    _includeOutputInBackup = json['includeOutputInBackup'] ?? true;
    _maxTabsPerRow = json['maxTabsPerRow'] ?? 5;
    _tabHeight = (json['tabHeight'] ?? 48.0).toDouble();
    _themeMode = json['themeMode'] ?? 'system';
    _fontSize = json['fontSize'] ?? 'normal';
    notifyListeners();
  }

  // Persistence methods
  Future<void> load() async {
    try {
      final json = await _configService.loadAppSettings();
      if (json != null) {
        fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to load app settings: $e');
    }
  }

  Future<void> save() async {
    try {
      await _configService.saveAppSettings(toJson());
    } catch (e) {
      debugPrint('Failed to save app settings: $e');
      rethrow;
    }
  }
}
