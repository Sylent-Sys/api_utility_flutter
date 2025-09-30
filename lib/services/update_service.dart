import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final String publishedAt;
  final bool isPrerelease;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    required this.isPrerelease,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    // Find Windows MSIX or ZIP asset
    String? downloadUrl;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null) {
      for (var asset in assets) {
        final name = asset['name'] as String?;
        if (name != null && (name.endsWith('.msix') || name.endsWith('.zip'))) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
    }

    return UpdateInfo(
      version: json['tag_name'] as String? ?? '',
      downloadUrl: downloadUrl ?? '',
      releaseNotes: json['body'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? '',
      isPrerelease: json['prerelease'] as bool? ?? false,
    );
  }
}

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  static UpdateService get instance => _instance;

  UpdateService._internal();

  static const String _githubRepo = 'Sylent-Sys/api_utility_flutter';
  static const String _currentVersion = '2.3.0'; // Should match pubspec.yaml
  static const String _lastCheckKey = 'last_update_check';
  static const String _autoCheckEnabledKey = 'auto_update_check_enabled';
  static const String _checkIntervalKey = 'update_check_interval_hours';

  // Check for updates from GitHub releases
  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$_githubRepo/releases/latest');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final updateInfo = UpdateInfo.fromJson(json);

        // Compare versions
        if (_isNewerVersion(updateInfo.version, _currentVersion)) {
          await _saveLastCheckTime();
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    
    await _saveLastCheckTime();
    return null;
  }

  // Compare version strings (e.g., "v2.3.0" vs "2.2.0")
  bool _isNewerVersion(String remoteVersion, String currentVersion) {
    // Remove 'v' prefix if present
    final remote = remoteVersion.replaceFirst('v', '');
    final current = currentVersion.replaceFirst('v', '');

    // Split by '.' and '+' to get version parts
    final remoteParts = remote.split(RegExp(r'[.+]'));
    final currentParts = current.split(RegExp(r'[.+]'));

    // Compare major, minor, patch
    for (int i = 0; i < 3 && i < remoteParts.length && i < currentParts.length; i++) {
      final remoteNum = int.tryParse(remoteParts[i]) ?? 0;
      final currentNum = int.tryParse(currentParts[i]) ?? 0;

      if (remoteNum > currentNum) return true;
      if (remoteNum < currentNum) return false;
    }

    return false;
  }

  // Download update file
  Future<String?> downloadUpdate(String downloadUrl, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download update: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      final fileName = downloadUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      int received = 0;
      final sink = file.openWrite();

      await for (var chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null && contentLength > 0) {
          onProgress(received, contentLength);
        }
      }

      await sink.close();
      client.close();

      return filePath;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return null;
    }
  }

  // Install update (opens the downloaded file)
  Future<bool> installUpdate(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      // On Windows, we can launch the MSIX or extract ZIP
      if (filePath.endsWith('.msix')) {
        // Launch MSIX installer
        await Process.start(filePath, [], runInShell: true);
        return true;
      } else if (filePath.endsWith('.zip')) {
        // Extract ZIP to a temporary location
        final tempDir = await getTemporaryDirectory();
        final extractPath = '${tempDir.path}/update_extracted';
        final extractDir = Directory(extractPath);
        if (await extractDir.exists()) {
          await extractDir.delete(recursive: true);
        }
        await extractDir.create(recursive: true);

        // Extract ZIP
        final bytes = await file.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        extractFileToDisk(archive, extractPath);

        // Find and launch the executable
        final exeFile = File('$extractPath/api_utility_flutter.exe');
        if (await exeFile.exists()) {
          await Process.start(exeFile.path, [], runInShell: true);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error installing update: $e');
      return false;
    }
  }

  // Check if auto-update check is enabled
  Future<bool> isAutoCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoCheckEnabledKey) ?? true;
  }

  // Set auto-update check enabled/disabled
  Future<void> setAutoCheckEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCheckEnabledKey, enabled);
  }

  // Get update check interval in hours
  Future<int> getCheckIntervalHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_checkIntervalKey) ?? 24; // Default 24 hours
  }

  // Set update check interval in hours
  Future<void> setCheckIntervalHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_checkIntervalKey, hours);
  }

  // Check if it's time to check for updates
  Future<bool> shouldCheckForUpdates() async {
    if (!await isAutoCheckEnabled()) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);
    if (lastCheck == null) {
      return true;
    }

    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    final now = DateTime.now();
    final intervalHours = await getCheckIntervalHours();
    final difference = now.difference(lastCheckTime);

    return difference.inHours >= intervalHours;
  }

  // Save last check time
  Future<void> _saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get current app version
  String get currentVersion => _currentVersion;
}
