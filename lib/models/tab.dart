import 'config.dart';

class TabData {
  final String id;
  final String title;
  final ApiConfig config;
  final String? selectedFilePath;
  final DateTime createdAt;
  final DateTime lastModified;

  const TabData({
    required this.id,
    required this.title,
    required this.config,
    this.selectedFilePath,
    required this.createdAt,
    required this.lastModified,
  });

  TabData copyWith({
    String? id,
    String? title,
    ApiConfig? config,
    String? selectedFilePath,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return TabData(
      id: id ?? this.id,
      title: title ?? this.title,
      config: config ?? this.config,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'config': config.toJson(),
      'selectedFilePath': selectedFilePath,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory TabData.fromJson(Map<String, dynamic> json) {
    return TabData(
      id: json['id'],
      title: json['title'],
      config: ApiConfig.fromJson(json['config']),
      selectedFilePath: json['selectedFilePath'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TabData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
