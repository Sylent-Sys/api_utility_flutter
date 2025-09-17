import 'dart:convert';
import 'dart:io';
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

      if (await configFile.exists()) {
        final configJson = await configFile.readAsString();
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        _cachedConfig = ApiConfig.fromJson(configMap);
        return _cachedConfig!;
      }
    } catch (e) {
      // If parsing fails, return default config
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
}
