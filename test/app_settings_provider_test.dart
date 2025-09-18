import 'package:flutter_test/flutter_test.dart';
import 'package:api_utility_flutter/providers/app_settings_provider.dart';

void main() {
  group('AppSettingsProvider', () {
    test('defaults are correct', () {
      final p = AppSettingsProvider();
      expect(p.tabWrapEnabled, isFalse);
      expect(p.showTabNumbers, isTrue);
      expect(p.autoSaveTabs, isTrue);
      expect(p.includeOutputInBackup, isTrue);
      expect(p.maxTabsPerRow, 5);
      expect(p.tabHeight, 48.0);
      expect(p.themeMode, 'system');
      expect(p.fontSize, 'normal');
    });

    test('setters update values and notify', () {
      final p = AppSettingsProvider();
      int notifications = 0;
      p.addListener(() => notifications++);

      p.setTabWrapEnabled(true);
      p.setShowTabNumbers(false);
      p.setAutoSaveTabs(false);
      p.setIncludeOutputInBackup(false);
      p.setMaxTabsPerRow(7);
      p.setTabHeight(60.0);
      p.setThemeMode('dark');
      p.setFontSize('large');

      expect(p.tabWrapEnabled, isTrue);
      expect(p.showTabNumbers, isFalse);
      expect(p.autoSaveTabs, isFalse);
      expect(p.includeOutputInBackup, isFalse);
      expect(p.maxTabsPerRow, 7);
      expect(p.tabHeight, 60.0);
      expect(p.themeMode, 'dark');
      expect(p.fontSize, 'large');
      expect(notifications, greaterThanOrEqualTo(8));
    });

    test('invalid theme/font values do not notify', () {
      final p = AppSettingsProvider();
      int notifications = 0;
      p.addListener(() => notifications++);

      p.setThemeMode('invalid');
      p.setFontSize('invalid');

      expect(p.themeMode, 'system');
      expect(p.fontSize, 'normal');
      expect(notifications, 0);
    });

    test('toJson and fromJson roundtrip', () {
      final p = AppSettingsProvider();
      p.setTabWrapEnabled(true);
      p.setShowTabNumbers(false);
      p.setAutoSaveTabs(false);
      p.setIncludeOutputInBackup(false);
      p.setMaxTabsPerRow(9);
      p.setTabHeight(44.0);
      p.setThemeMode('light');
      p.setFontSize('small');

      final json = p.toJson();

      final p2 = AppSettingsProvider();
      int notify = 0;
      p2.addListener(() => notify++);
      p2.fromJson(json);

      expect(p2.tabWrapEnabled, isTrue);
      expect(p2.showTabNumbers, isFalse);
      expect(p2.autoSaveTabs, isFalse);
      expect(p2.includeOutputInBackup, isFalse);
      expect(p2.maxTabsPerRow, 9);
      expect(p2.tabHeight, 44.0);
      expect(p2.themeMode, 'light');
      expect(p2.fontSize, 'small');
      expect(notify, 1);
    });

    test('resetToDefaults restores defaults', () {
      final p = AppSettingsProvider();
      p.setTabWrapEnabled(true);
      p.setShowTabNumbers(false);
      p.setAutoSaveTabs(false);
      p.setIncludeOutputInBackup(false);
      p.setMaxTabsPerRow(1);
      p.setTabHeight(10);
      p.setThemeMode('dark');
      p.setFontSize('large');

      int notifications = 0;
      p.addListener(() => notifications++);
      p.resetToDefaults();

      expect(p.tabWrapEnabled, isFalse);
      expect(p.showTabNumbers, isTrue);
      expect(p.autoSaveTabs, isTrue);
      expect(p.includeOutputInBackup, isTrue);
      expect(p.maxTabsPerRow, 5);
      expect(p.tabHeight, 48.0);
      expect(p.themeMode, 'system');
      expect(p.fontSize, 'normal');
      expect(notifications, 1);
    });
  });
}


