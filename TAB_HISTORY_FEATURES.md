# Tab-Specific History Features

## Overview
Aplikasi API Utility Flutter sekarang mendukung sistem history per tab yang memungkinkan tracking processing history dengan konteks yang kaya. Setiap history entry menyimpan informasi tab yang melakukan processing, memungkinkan identifikasi yang jelas meski tab sudah dihapus.

## 🎯 Fitur Utama

### 1. **Tab-Specific History Tracking**
- **Rich Context**: Setiap history entry menyimpan informasi tab lengkap
- **Persistent Tracking**: History tetap ada meski tab dihapus
- **Unique Identification**: ID history yang unik dengan format yang jelas
- **Cross-Session**: History tersimpan di file dan persist across restarts

### 2. **Naming Convention**
- **Format**: `{tabName}-{tabId}-{YYYYMMDD}-{HHMMSS}`
- **Example**: `APIDev-abc123-20241218-143022`
- **Benefits**: 
  - Mudah diidentifikasi
  - Sortable by timestamp
  - Unique per processing run
  - Human-readable

### 3. **Enhanced History Information**
- **Tab Context**: Nama tab, ID tab, dan tanggal pembuatan tab
- **Processing Context**: File input, konfigurasi API, hasil processing
- **Temporal Context**: Timestamp processing dan durasi
- **Status Context**: Success/error count, test mode info

## 📊 Data Structure

### ProcessingHistory Model (Enhanced)
```dart
class ProcessingHistory {
  // Existing fields...
  final String id;                    // Tab-specific ID
  final DateTime timestamp;           // Processing timestamp
  final String inputFileName;         // Input file name
  final String inputFilePath;         // Input file path
  final String outputPath;            // Output file path
  final int totalRows;                // Total rows processed
  final int successCount;             // Successful requests
  final int errorCount;               // Failed requests
  final String configName;            // Configuration name
  final List<ApiResult> results;      // Detailed results
  final bool isTestMode;              // Test mode flag
  final int? testRows;                // Test rows count
  
  // NEW: Tab-specific information
  final String tabId;                 // Tab ID when processing was done
  final String tabName;               // Tab name when processing was done
  final DateTime tabCreatedAt;        // When the tab was created
  
  // Helper methods
  static String generateTabHistoryId(String tabName, String tabId, DateTime timestamp);
  String get displayName;             // Human-readable display name
}
```

### History ID Generation
```dart
static String generateTabHistoryId(String tabName, String tabId, DateTime timestamp) {
  final sanitizedTabName = tabName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
  final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
  return '$sanitizedTabName-$tabId-$dateStr-$timeStr';
}
```

## 🗂️ File Storage

### History File Structure
- **Location**: `{AppDocuments}/API_Utility_Flutter/processing_history.json`
- **Format**: JSON array berisi history entries
- **Auto-save**: Setiap processing selesai, history tersimpan otomatis
- **Backup**: File history di-backup secara otomatis

### Example History Entry
```json
{
  "id": "ProductionAPI-tab_1-20241218-143022",
  "timestamp": "2024-12-18T14:30:22.000Z",
  "inputFileName": "data.csv",
  "inputFilePath": "/path/to/data.csv",
  "outputPath": "/path/to/results.json",
  "totalRows": 200,
  "successCount": 195,
  "errorCount": 5,
  "configName": "https://api.example.com/v1/process",
  "results": [
    {
      "rowIndex": 0,
      "data": {"id": "1", "name": "John", "email": "john@example.com"},
      "success": true,
      "response": {"status": "success", "id": "123"},
      "error": null,
      "duration": 150
    }
  ],
  "isTestMode": false,
  "testRows": null,
  "tabId": "tab_1",
  "tabName": "Production API",
  "tabCreatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 🔍 History Service Features

### Enhanced HistoryService Methods
```dart
class HistoryService {
  // Existing methods...
  Future<List<ProcessingHistory>> getHistory();
  Future<void> addToHistory(ProcessingHistory history);
  Future<void> removeFromHistory(String historyId);
  Future<void> clearHistory();
  
  // NEW: Tab-specific methods
  Future<List<ProcessingHistory>> getHistoryByTab(String tabId);
  Future<Map<String, List<ProcessingHistory>>> getHistoryByTabs();
  Future<List<String>> getAllTabNames();
  
  // Enhanced search
  Future<List<ProcessingHistory>> searchHistory(String query);
}
```

### Tab-Specific Queries
- **By Tab ID**: Get all history for specific tab
- **By Tab Name**: Get all history for tabs with specific name
- **Grouped by Tab**: Get history grouped by tab
- **All Tab Names**: Get list of all tab names from history
- **Enhanced Search**: Search by tab name, file name, or configuration

## 🎨 User Interface

### History Screen Enhancements
- **Tab Context Display**: Show tab information for each history entry
- **Enhanced Search**: Search by tab name, file name, or configuration
- **Grouped View**: Option to group history by tab
- **Rich Information**: Display tab name, creation date, and processing details

### History Entry Display
```
📊 Production API (18/12/2024 14:30)
   Tab: Production API (created: 15/12/2024 10:00)
   File: data.csv (200 rows)
   Status: 195/200 success (97.5%)
   Config: https://api.example.com/v1/process
   Duration: 2m 30s
```

### Search and Filter Options
- **By Tab Name**: Filter history by specific tab
- **By Date Range**: Filter by processing date
- **By Status**: Filter by success/error status
- **By File**: Filter by input file name
- **By Configuration**: Filter by API configuration

## 🚀 Usage Examples

### Creating Tab-Specific History
```dart
// During processing
final history = ProcessingHistory(
  id: ProcessingHistory.generateTabHistoryId(
    tabName: "Production API",
    tabId: "tab_1", 
    timestamp: DateTime.now()
  ),
  timestamp: DateTime.now(),
  // ... other fields
  tabId: "tab_1",
  tabName: "Production API",
  tabCreatedAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
);

await historyService.addToHistory(history);
```

### Querying Tab-Specific History
```dart
// Get history for specific tab
final tabHistory = await historyService.getHistoryByTab("tab_1");

// Get history grouped by tab
final groupedHistory = await historyService.getHistoryByTabs();

// Get all tab names from history
final tabNames = await historyService.getAllTabNames();

// Search history by tab name
final searchResults = await historyService.searchHistory("Production");
```

## 📈 Benefits

### **For Users**
1. **Clear Tracking**: Tahu persis history dari tab mana
2. **Persistent Data**: History tidak hilang meski tab dihapus
3. **Rich Context**: Informasi lengkap tentang tab dan processing
4. **Easy Identification**: Format ID yang mudah dipahami
5. **Cross-Session**: History tersimpan permanent

### **For Developers**
1. **Debugging**: Mudah debug dengan konteks tab yang jelas
2. **Analytics**: Bisa analisis performance per tab
3. **Audit Trail**: Trail lengkap untuk audit dan compliance
4. **Data Integrity**: Data history yang konsisten dan reliable
5. **Extensibility**: Mudah extend dengan informasi tambahan

### **For Operations**
1. **Monitoring**: Monitor processing per environment/tab
2. **Troubleshooting**: Troubleshoot issue dengan konteks yang jelas
3. **Performance Analysis**: Analisis performance per konfigurasi
4. **Capacity Planning**: Planning berdasarkan usage pattern
5. **Compliance**: Audit trail untuk compliance requirements

## 🔧 Implementation Details

### Processing Service Integration
```dart
Future<ProcessingResult> processData({
  required ApiConfig config,
  required String inputFilePath,
  int? testRows,
  String? tabId,        // NEW: Tab context
  String? tabName,      // NEW: Tab context
  DateTime? tabCreatedAt, // NEW: Tab context
}) async {
  // ... processing logic
  
  // Create history with tab context
  final history = ProcessingHistory(
    id: tabId != null && tabName != null 
        ? ProcessingHistory.generateTabHistoryId(tabName, tabId, timestamp)
        : _uuid.v4(),
    // ... other fields
    tabId: tabId ?? '',
    tabName: tabName ?? 'Unknown Tab',
    tabCreatedAt: tabCreatedAt ?? DateTime.now(),
  );
  
  await _historyService.addToHistory(history);
}
```

### Tab App Provider Integration
```dart
Future<ProcessingResult> processCurrentTabData({int? testRows}) async {
  final result = await _processingService.processData(
    config: currentConfig,
    inputFilePath: currentTab!.selectedFilePath!,
    testRows: testRows,
    tabId: currentTab!.id,        // Pass tab context
    tabName: currentTab!.title,   // Pass tab context
    tabCreatedAt: currentTab!.createdAt, // Pass tab context
  );
}
```

## 🧪 Testing

### Unit Tests
- **ID Generation**: Test tab history ID generation
- **Data Serialization**: Test JSON serialization/deserialization
- **Validation**: Test data validation and error handling
- **Edge Cases**: Test dengan edge cases (empty names, special characters)

### Integration Tests
- **History Service**: Test tab-specific history methods
- **Processing Integration**: Test history creation during processing
- **File Operations**: Test file read/write operations
- **Cross-session**: Test persistence across app restarts

### UI Tests
- **History Display**: Test tampilan history dengan tab context
- **Search Functionality**: Test search dan filter functionality
- **Navigation**: Test navigation ke detail history
- **Error Handling**: Test error handling di UI

## 🔮 Future Enhancements

### Advanced Features
- **History Analytics**: Dashboard analytics untuk history
- **Export History**: Export history ke berbagai format
- **History Backup**: Backup history ke cloud
- **History Archiving**: Archive old history entries
- **History Compression**: Compress old history untuk save space

### UI Improvements
- **Timeline View**: Timeline view untuk history
- **Chart Visualization**: Chart untuk success rate, performance
- **Advanced Filtering**: Filter yang lebih advanced
- **Bulk Operations**: Bulk operations untuk history
- **History Comparison**: Compare history antar tab

### Integration Features
- **API Integration**: Integrate dengan external analytics
- **Notification System**: Notifikasi untuk history events
- **Webhook Support**: Webhook untuk history events
- **Real-time Updates**: Real-time updates untuk history
- **Collaboration**: Share history dengan team members
