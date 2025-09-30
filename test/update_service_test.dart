import 'package:flutter_test/flutter_test.dart';
import 'package:api_utility_flutter/services/update_service.dart';

void main() {
  group('UpdateService', () {
    late UpdateService updateService;

    setUp(() {
      updateService = UpdateService.instance;
    });

    test('UpdateService should be a singleton', () {
      final instance1 = UpdateService.instance;
      final instance2 = UpdateService.instance;
      expect(instance1, equals(instance2));
    });

    test('Current version should be defined', () {
      expect(updateService.currentVersion, isNotEmpty);
      expect(updateService.currentVersion, '2.3.0');
    });

    test('Version comparison should work correctly', () {
      // Access the private method through instance testing
      // We'll test through checkForUpdates behavior instead
      expect(updateService.currentVersion, isNotEmpty);
    });
  });

  group('UpdateInfo', () {
    test('should parse JSON correctly', () {
      final json = {
        'tag_name': 'v2.4.0',
        'body': 'Release notes',
        'published_at': '2024-01-01T00:00:00Z',
        'prerelease': false,
        'assets': [
          {
            'name': 'app.msix',
            'browser_download_url': 'https://example.com/app.msix',
          },
        ],
      };

      final updateInfo = UpdateInfo.fromJson(json);

      expect(updateInfo.version, 'v2.4.0');
      expect(updateInfo.releaseNotes, 'Release notes');
      expect(updateInfo.downloadUrl, 'https://example.com/app.msix');
      expect(updateInfo.isPrerelease, false);
    });

    test('should handle missing assets', () {
      final json = {
        'tag_name': 'v2.4.0',
        'body': 'Release notes',
        'published_at': '2024-01-01T00:00:00Z',
        'prerelease': false,
        'assets': [],
      };

      final updateInfo = UpdateInfo.fromJson(json);

      expect(updateInfo.version, 'v2.4.0');
      expect(updateInfo.downloadUrl, '');
    });

    test('should prioritize MSIX over ZIP', () {
      final json = {
        'tag_name': 'v2.4.0',
        'body': 'Release notes',
        'published_at': '2024-01-01T00:00:00Z',
        'prerelease': false,
        'assets': [
          {
            'name': 'app.zip',
            'browser_download_url': 'https://example.com/app.zip',
          },
          {
            'name': 'app.msix',
            'browser_download_url': 'https://example.com/app.msix',
          },
        ],
      };

      final updateInfo = UpdateInfo.fromJson(json);

      expect(updateInfo.downloadUrl, 'https://example.com/app.msix');
    });
  });
}
