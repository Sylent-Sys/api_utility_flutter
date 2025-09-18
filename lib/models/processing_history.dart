import 'result.dart';

class ProcessingHistory {
  final String id;
  final DateTime timestamp;
  final String inputFileName;
  final String inputFilePath;
  final String outputPath;
  final int totalRows;
  final int successCount;
  final int errorCount;
  final String configName;
  final List<ApiResult> results;
  final bool isTestMode;
  final int? testRows;
  
  // Tab-specific information
  final String tabId;
  final String tabName;
  final DateTime tabCreatedAt;

  const ProcessingHistory({
    required this.id,
    required this.timestamp,
    required this.inputFileName,
    required this.inputFilePath,
    required this.outputPath,
    required this.totalRows,
    required this.successCount,
    required this.errorCount,
    required this.configName,
    required this.results,
    this.isTestMode = false,
    this.testRows,
    required this.tabId,
    required this.tabName,
    required this.tabCreatedAt,
  });

  double get successRate => totalRows > 0 ? successCount / totalRows : 0.0;
  double get errorRate => totalRows > 0 ? errorCount / totalRows : 0.0;

  // Generate tab-specific history ID
  static String generateTabHistoryId(String tabName, String tabId, DateTime timestamp) {
    final sanitizedTabName = tabName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
    return '$sanitizedTabName-$tabId-$dateStr-$timeStr';
  }

  // Get display name for history entry
  String get displayName => '$tabName ($formattedTimestamp)';

  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get duration {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'inputFileName': inputFileName,
      'inputFilePath': inputFilePath,
      'outputPath': outputPath,
      'totalRows': totalRows,
      'successCount': successCount,
      'errorCount': errorCount,
      'configName': configName,
      'results': results.map((r) => r.toJson()).toList(),
      'isTestMode': isTestMode,
      'testRows': testRows,
      'tabId': tabId,
      'tabName': tabName,
      'tabCreatedAt': tabCreatedAt.toIso8601String(),
    };
  }

  factory ProcessingHistory.fromJson(Map<String, dynamic> json) {
    return ProcessingHistory(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      inputFileName: json['inputFileName'],
      inputFilePath: json['inputFilePath'],
      outputPath: json['outputPath'],
      totalRows: json['totalRows'],
      successCount: json['successCount'],
      errorCount: json['errorCount'],
      configName: json['configName'],
      results: (json['results'] as List)
          .map((r) => ApiResult.fromJson(r))
          .toList(),
      isTestMode: json['isTestMode'] ?? false,
      testRows: json['testRows'],
      tabId: json['tabId'] ?? '',
      tabName: json['tabName'] ?? 'Unknown Tab',
      tabCreatedAt: json['tabCreatedAt'] != null 
          ? DateTime.parse(json['tabCreatedAt']) 
          : DateTime.now(),
    );
  }
}
