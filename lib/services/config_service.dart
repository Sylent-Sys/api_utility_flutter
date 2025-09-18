import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import '../models/config.dart';
import 'folder_structure_service.dart';

class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();

  ConfigService._();

  final FolderStructureService _folderService = FolderStructureService.instance;
  ApiConfig? _cachedConfig;

  Future<ApiConfig> getConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    try {
      final configFile = File(_folderService.configFilePath);
      debugPrint('[ConfigService] Looking for config at: ${configFile.path}');

      if (await configFile.exists()) {
        debugPrint('[ConfigService] Config file found. Reading...');
        final configJson = await configFile.readAsString();
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        _cachedConfig = ApiConfig.fromJson(configMap);
        debugPrint('[ConfigService] Config loaded successfully.');
        return _cachedConfig!;
      }
      debugPrint('[ConfigService] Config file not found. Using default config.');
    } catch (e) {
      // If parsing fails, return default config
      debugPrint('[ConfigService] Failed to parse config. Using default. Error: $e');
    }

    _cachedConfig = const ApiConfig();
    return _cachedConfig!;
  }

  Future<void> saveConfig(ApiConfig config) async {
    try {
      final configFile = File(_folderService.configFilePath);
      final configJson = json.encode(config.toJson());
      await configFile.writeAsString(configJson);
      _cachedConfig = config;
    } catch (e) {
      throw Exception('Failed to save configuration: $e');
    }
  }

  Future<void> clearConfig() async {
    try {
      final configFile = File(_folderService.configFilePath);
      if (await configFile.exists()) {
        await configFile.delete();
      }
      _cachedConfig = null;
    } catch (e) {
      throw Exception('Failed to clear configuration: $e');
    }
  }

  Future<void> resetToDefault() async {
    await saveConfig(const ApiConfig());
  }

  /// Get all saved configuration files
  Future<List<File>> getConfigFiles() async {
    return await _folderService.getConfigFiles();
  }

  /// Load configuration from specific file
  Future<ApiConfig> loadConfigFromFile(String filePath) async {
    try {
      final configFile = File(filePath);
      final configJson = await configFile.readAsString();
      final configMap = json.decode(configJson) as Map<String, dynamic>;
      return ApiConfig.fromJson(configMap);
    } catch (e) {
      throw Exception('Failed to load configuration from file: $e');
    }
  }

  /// Save configuration to specific file
  Future<void> saveConfigToFile(ApiConfig config, String filePath) async {
    try {
      final configFile = File(filePath);
      final configJson = json.encode(config.toJson());
      await configFile.writeAsString(configJson);
    } catch (e) {
      throw Exception('Failed to save configuration to file: $e');
    }
  }

  // Tab management methods
  Future<void> saveTabs(List<Map<String, dynamic>> tabsJson) async {
    try {
      final tabsFile = File(_folderService.tabsFilePath);
      final jsonString = jsonEncode(tabsJson);
      await tabsFile.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save tabs: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> loadTabs() async {
    try {
      final tabsFile = File(_folderService.tabsFilePath);
      
      if (!await tabsFile.exists()) {
        return null;
      }

      final jsonString = await tabsFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // App settings methods
  Future<void> saveAppSettings(Map<String, dynamic> settingsJson) async {
    try {
      final settingsFile = File(_folderService.settingsFilePath);
      final jsonString = jsonEncode(settingsJson);
      await settingsFile.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  Future<Map<String, dynamic>?> loadAppSettings() async {
    try {
      final settingsFile = File(_folderService.settingsFilePath);
      
      if (!await settingsFile.exists()) {
        return null;
      }

      final jsonString = await settingsFile.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Create a zip backup containing config, tabs, history, and app_settings
  Future<String> createBackup() async {
    try {
      final backupPath = _folderService.getBackupFilePath();
      final encoder = ZipFileEncoder();
      encoder.create(backupPath);

      // Add files if exist
      final paths = <String>[
        _folderService.configFilePath,
        _folderService.tabsFilePath,
        _folderService.historyFilePath,
        _folderService.settingsFilePath,
      ];

      for (final p in paths) {
        final f = File(p);
        if (await f.exists()) {
          encoder.addFile(f);
        }
      }

      // Include output directory based on setting
      bool includeOutput = true;
      try {
        final settings = await loadAppSettings();
        includeOutput = settings?['includeOutputInBackup'] ?? true;
      } catch (_) {}
      if (includeOutput) {
        final outputDir = _folderService.outputDirectory;
        if (await outputDir.exists()) {
          encoder.addDirectory(outputDir);
        }
      }

      encoder.close();
      return backupPath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore from a zip backup file
  Future<void> restoreBackup(String zipPath) async {
    try {
      final file = File(zipPath);
      if (!await file.exists()) {
        throw Exception('Backup file not found: $zipPath');
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final entry in archive) {
        final fileName = entry.name.split('/').last;
        late String targetPath;
        if (fileName == 'api_config.json') {
          targetPath = _folderService.configFilePath;
        } else if (fileName == 'tabs.json') {
          targetPath = _folderService.tabsFilePath;
        } else if (fileName == 'processing_history.json') {
          targetPath = _folderService.historyFilePath;
        } else if (fileName == 'app_settings.json') {
          targetPath = _folderService.settingsFilePath;
        } else {
          // For any other files (e.g., outputs), write relative to app directory
          targetPath = '${_folderService.appDirectory.path}/$fileName';
        }

        if (entry.isFile) {
          final data = entry.content as List<int>;
          final outFile = File(targetPath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(data, flush: true);
        } else {
          final dir = Directory(targetPath);
          await dir.create(recursive: true);
        }
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
