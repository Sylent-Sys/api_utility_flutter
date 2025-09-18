import 'package:flutter_test/flutter_test.dart';
import 'package:api_utility_flutter/models/tab.dart';
import 'package:api_utility_flutter/models/config.dart';

void main() {
  test('TabData copyWith and equality', () {
    final t1 = TabData(
      id: 'tab_1',
      title: 'Tab 1',
      config: const ApiConfig(),
      createdAt: DateTime(2024, 1, 1),
      lastModified: DateTime(2024, 1, 1),
    );

    final t2 = t1.copyWith(title: 'New');
    expect(t2.id, 'tab_1');
    expect(t2.title, 'New');
    expect(t2 == t1, isTrue, reason: 'Equality based on id');
    expect(t2.hashCode, t1.hashCode);
  });

  test('TabData toJson/fromJson roundtrip', () {
    final t = TabData(
      id: 'tab_42',
      title: 'Meaning',
      config: const ApiConfig(baseUrl: 'https://api'),
      selectedFilePath: 'file.csv',
      createdAt: DateTime(2024, 5, 20, 10, 30),
      lastModified: DateTime(2024, 5, 20, 10, 45),
    );

    final json = t.toJson();
    final parsed = TabData.fromJson(json);

    expect(parsed.id, t.id);
    expect(parsed.title, t.title);
    expect(parsed.config.baseUrl, 'https://api');
    expect(parsed.selectedFilePath, 'file.csv');
    expect(parsed.createdAt, t.createdAt);
    expect(parsed.lastModified, t.lastModified);
  });
}


