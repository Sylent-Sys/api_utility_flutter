import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FolderStructureService {
  static FolderStructureService? _instance;
  static FolderStructureService get instance =>
      _instance ??= FolderStructureService._();

  FolderStructureService._();

  Directory? _appDirectory;
  Directory? _configDirectory;
  Directory? _outputDirectory;
  Directory? _historyDirectory;
  Directory? _tempDirectory;
  Directory? _backupDirectory;

  /// Initialize all required directories
  Future<void> initialize() async {
    try {
      // Get application documents directory
      final documentsDir = await getApplicationDocumentsDirectory();

      // Create main app directory
      _appDirectory = Directory('${documentsDir.path}/API_Utility_Flutter');
      await _appDirectory!.create(recursive: true);

      // Create subdirectories
      _configDirectory = Directory('${_appDirectory!.path}/config');
      _outputDirectory = Directory('${_appDirectory!.path}/output');
      _historyDirectory = Directory('${_appDirectory!.path}/history');
      _tempDirectory = Directory('${_appDirectory!.path}/temp');
      _backupDirectory = Directory('${_appDirectory!.path}/backup');

      // Create all directories if they don't exist
      await _configDirectory!.create(recursive: true);
      await _outputDirectory!.create(recursive: true);
      await _historyDirectory!.create(recursive: true);
      await _tempDirectory!.create(recursive: true);
      await _backupDirectory!.create(recursive: true);

      debugPrint('[FolderStructure] documentsDir: ${documentsDir.path}');
      debugPrint('[FolderStructure] appDirectory: ${_appDirectory!.path}');
      debugPrint('[FolderStructure] configDirectory: ${_configDirectory!.path}');
      debugPrint('[FolderStructure] configFilePath: $configFilePath');

      // Create README file in main directory
      await _createReadmeFile();
    } catch (e) {
      throw Exception('Failed to initialize folder structure: $e');
    }
  }

  /// Get the main application directory
  Directory get appDirectory {
    if (_appDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _appDirectory!;
  }

  /// Get the configuration directory
  Directory get configDirectory {
    if (_configDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _configDirectory!;
  }

  /// Get the output directory
  Directory get outputDirectory {
    if (_outputDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _outputDirectory!;
  }

  /// Get the history directory
  Directory get historyDirectory {
    if (_historyDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _historyDirectory!;
  }

  /// Get the temp directory
  Directory get tempDirectory {
    if (_tempDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _tempDirectory!;
  }

  /// Get the backup directory
  Directory get backupDirectory {
    if (_backupDirectory == null) {
      throw Exception(
        'FolderStructureService not initialized. Call initialize() first.',
      );
    }
    return _backupDirectory!;
  }

  /// Get configuration file path
  String get configFilePath => '${configDirectory.path}/api_config.json';

  /// Get tabs file path
  String get tabsFilePath => '${configDirectory.path}/tabs.json';

  /// Get app settings file path
  String get settingsFilePath => '${configDirectory.path}/app_settings.json';

  /// Get history file path
  String get historyFilePath =>
      '${historyDirectory.path}/processing_history.json';

  /// Backup file path with timestamp
  String getBackupFilePath() {
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];
    return '${backupDirectory.path}/backup_$timestamp.zip';
  }

  /// Get output file path with timestamp
  String getOutputFilePath(String pattern) {
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];
    final filename = pattern.replaceAll('{date}', timestamp);
    final finalFilename = filename.endsWith('.json')
        ? filename
        : '$filename.json';
    return '${outputDirectory.path}/$finalFilename';
  }

  /// Get organized output file path by date
  String getOrganizedOutputFilePath(String pattern) {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    // Create date-based subdirectory
    final dateDir = Directory('${outputDirectory.path}/$year/$month/$day');
    dateDir.createSync(recursive: true);

    final timestamp = now.toIso8601String().replaceAll(':', '-').split('.')[0];
    final filename = pattern.replaceAll('{date}', timestamp);
    final finalFilename = filename.endsWith('.json')
        ? filename
        : '$filename.json';

    return '${dateDir.path}/$finalFilename';
  }

  /// Get all configuration files
  Future<List<File>> getConfigFiles() async {
    try {
      final configDir = configDirectory;
      if (!await configDir.exists()) return [];

      final files = await configDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all output files
  Future<List<File>> getOutputFiles() async {
    try {
      final outputDir = outputDirectory;
      if (!await outputDir.exists()) return [];

      final files = <File>[];
      await for (final entity in outputDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.json')) {
          files.add(entity);
        }
      }

      // Sort by modification time (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
      return files;
    } catch (e) {
      return [];
    }
  }

  /// Get folder size in bytes
  Future<int> getFolderSize(Directory directory) async {
    try {
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get formatted folder size
  Future<String> getFormattedFolderSize(Directory directory) async {
    final sizeInBytes = await getFolderSize(directory);
    return _formatBytes(sizeInBytes);
  }

  /// Get application statistics
  Future<Map<String, dynamic>> getAppStats() async {
    try {
      final configFiles = await getConfigFiles();
      final outputFiles = await getOutputFiles();

      final totalConfigSize = await getFolderSize(configDirectory);
      final totalOutputSize = await getFolderSize(outputDirectory);
      final totalHistorySize = await getFolderSize(historyDirectory);
      final totalTempSize = await getFolderSize(tempDirectory);

      return {
        'configFiles': configFiles.length,
        'outputFiles': outputFiles.length,
        'totalConfigSize': totalConfigSize,
        'totalOutputSize': totalOutputSize,
        'totalHistorySize': totalHistorySize,
        'totalTempSize': totalTempSize,
        'totalSize':
            totalConfigSize +
            totalOutputSize +
            totalHistorySize +
            totalTempSize,
        'appDirectory': appDirectory.path,
      };
    } catch (e) {
      return {
        'configFiles': 0,
        'outputFiles': 0,
        'totalConfigSize': 0,
        'totalOutputSize': 0,
        'totalHistorySize': 0,
        'totalTempSize': 0,
        'totalSize': 0,
        'appDirectory': 'Error: $e',
      };
    }
  }

  /// Clean temporary files
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = tempDirectory;
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Ignore errors when cleaning temp files
    }
  }

  /// Clean old output files (older than specified days)
  Future<void> cleanOldOutputFiles(int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final outputFiles = await getOutputFiles();

      for (final file in outputFiles) {
        final lastModified = await file.lastModified();
        if (lastModified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore errors when cleaning old files
    }
  }

  /// Create README file in main directory
  Future<void> _createReadmeFile() async {
    try {
      final readmeFile = File('${appDirectory.path}/README.txt');
      if (!await readmeFile.exists()) {
        const readmeContent = '''
API Utility Flutter - Folder Structure

This folder contains all data for the API Utility Flutter application:

📁 config/
   - api_config.json: Your saved API configurations
   - Additional config files (if any)

📁 output/
   - Processing results organized by date (YYYY/MM/DD/)
   - JSON files containing API responses and errors

📁 history/
   - processing_history.json: Complete processing history
   - Backup files (if any)

📁 temp/
   - Temporary files (automatically cleaned)

📄 README.txt: This file

For support or questions, please refer to the application documentation.
''';
        await readmeFile.writeAsString(readmeContent);
      }
    } catch (e) {
      // Ignore errors when creating README
    }
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Open app directory in file explorer (platform specific)
  Future<void> openAppDirectory() async {
    try {
      // This would need platform-specific implementation
      // For now, we'll just return the path
      debugPrint('App directory: ${appDirectory.path}');
    } catch (e) {
      throw Exception('Failed to open app directory: $e');
    }
  }
}
