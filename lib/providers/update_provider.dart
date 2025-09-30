import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/update_service.dart';

class UpdateProvider with ChangeNotifier {
  final UpdateService _updateService = UpdateService.instance;

  UpdateInfo? _availableUpdate;
  bool _isChecking = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;
  Timer? _autoCheckTimer;

  UpdateInfo? get availableUpdate => _availableUpdate;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get error => _error;
  bool get hasUpdate => _availableUpdate != null;

  String get currentVersion => _updateService.currentVersion;

  UpdateProvider() {
    _initAutoCheck();
  }

  // Initialize auto-check timer
  Future<void> _initAutoCheck() async {
    // Check immediately on startup if needed
    if (await _updateService.shouldCheckForUpdates()) {
      await checkForUpdates(silent: true);
    }

    // Set up periodic check
    final intervalHours = await _updateService.getCheckIntervalHours();
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(
      Duration(hours: intervalHours),
      (_) => checkForUpdates(silent: true),
    );
  }

  // Check for updates
  Future<void> checkForUpdates({bool silent = false}) async {
    if (_isChecking) return;

    _isChecking = true;
    _error = null;
    if (!silent) notifyListeners();

    try {
      final updateInfo = await _updateService.checkForUpdates();
      _availableUpdate = updateInfo;
      _error = null;
    } catch (e) {
      _error = 'Failed to check for updates: $e';
      debugPrint(_error);
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // Download update
  Future<String?> downloadUpdate() async {
    if (_availableUpdate == null || _isDownloading) return null;

    _isDownloading = true;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final filePath = await _updateService.downloadUpdate(
        _availableUpdate!.downloadUrl,
        onProgress: (received, total) {
          _downloadProgress = received / total;
          notifyListeners();
        },
      );

      if (filePath == null) {
        _error = 'Failed to download update';
      }

      return filePath;
    } catch (e) {
      _error = 'Error downloading update: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Install update
  Future<bool> installUpdate(String filePath) async {
    try {
      return await _updateService.installUpdate(filePath);
    } catch (e) {
      _error = 'Error installing update: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Dismiss update notification
  void dismissUpdate() {
    _availableUpdate = null;
    _error = null;
    notifyListeners();
  }

  // Get auto-check enabled status
  Future<bool> isAutoCheckEnabled() async {
    return await _updateService.isAutoCheckEnabled();
  }

  // Set auto-check enabled status
  Future<void> setAutoCheckEnabled(bool enabled) async {
    await _updateService.setAutoCheckEnabled(enabled);
    if (enabled) {
      _initAutoCheck();
    } else {
      _autoCheckTimer?.cancel();
      _autoCheckTimer = null;
    }
    notifyListeners();
  }

  // Get check interval
  Future<int> getCheckIntervalHours() async {
    return await _updateService.getCheckIntervalHours();
  }

  // Set check interval
  Future<void> setCheckIntervalHours(int hours) async {
    await _updateService.setCheckIntervalHours(hours);
    _initAutoCheck(); // Restart timer with new interval
    notifyListeners();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }
}
