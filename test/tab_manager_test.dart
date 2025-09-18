import 'package:flutter_test/flutter_test.dart';
import 'package:api_utility_flutter/providers/tab_manager.dart';
import 'package:api_utility_flutter/models/config.dart';

void main() {
  group('TabManager', () {
    test('initializes with a default tab', () {
      final m = TabManager();
      expect(m.hasTabs, isTrue);
      expect(m.tabs.length, 1);
      expect(m.activeTab, isNotNull);
      expect(m.activeTabId, m.tabs.first.id);
    });

    test('addNewTab adds and activates new tab', () {
      final m = TabManager();
      final initialCount = m.tabs.length;
      int notifications = 0;
      m.addListener(() => notifications++);

      m.addNewTab();

      expect(m.tabs.length, initialCount + 1);
      expect(m.activeTab, isNotNull);
      expect(notifications, 1);
    });

    test('closeTab will not close last tab', () {
      final m = TabManager();
      final lastId = m.tabs.first.id;
      m.closeTab(lastId);
      expect(m.tabs.length, 1);
      expect(m.activeTabId, lastId);
    });

    test('switchToTab changes active tab', () {
      final m = TabManager();
      m.addNewTab();
      final secondId = m.tabs.last.id;
      int notify = 0;
      m.addListener(() => notify++);
      m.switchToTab(secondId);
      expect(m.activeTabId, secondId);
      expect(notify, 1);
    });

    test('updateTabConfig updates config and notifies', () {
      final m = TabManager();
      final id = m.tabs.first.id;
      int notify = 0;
      m.addListener(() => notify++);
      final newConfig = const ApiConfig(baseUrl: 'https://example.com');
      m.updateTabConfig(id, newConfig);
      expect(m.tabs.first.config, newConfig);
      expect(notify, 1);
    });

    test('updateTabTitle updates title and notifies', () {
      final m = TabManager();
      final id = m.tabs.first.id;
      int notify = 0;
      m.addListener(() => notify++);
      m.updateTabTitle(id, 'New Title');
      expect(m.tabs.first.title, 'New Title');
      expect(notify, 1);
    });

    test('duplicateTab inserts copy next to original and activates', () {
      final m = TabManager();
      m.addNewTab();
      final originalIndex = 0;
      final originalId = m.tabs[originalIndex].id;
      m.duplicateTab(originalId);
      expect(m.tabs[originalIndex + 1].title.contains('(Copy)'), isTrue);
      expect(m.activeTabId, m.tabs[originalIndex + 1].id);
    });

    test('reorderTabs reorders list', () {
      final m = TabManager();
      m.addNewTab();
      m.addNewTab();
      final first = m.tabs[0];
      m.reorderTabs(0, 2);
      expect(m.tabs[1].id, first.id);
    });
  });
}


