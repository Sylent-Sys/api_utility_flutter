# API Reference

## Overview
Dokumentasi API Reference untuk API Utility Flutter v2.0.0 dengan Multi-Tab Interface support.

## 📁 Models

### TabData
Model untuk data tab dengan konfigurasi independen.

```dart
class TabData {
  final String id;                    // Unique identifier
  final String title;                 // Display name
  final ApiConfig config;             // API configuration
  final String? selectedFilePath;     // Selected input file
  final DateTime createdAt;           // Creation timestamp
  final DateTime lastModified;        // Last modification timestamp
}
```

**Properties:**
- `id`: String - Unique identifier untuk tab
- `title`: String - Nama yang ditampilkan di tab
- `config`: ApiConfig - Konfigurasi API untuk tab ini
- `selectedFilePath`: String? - Path file input yang dipilih
- `createdAt`: DateTime - Kapan tab dibuat
- `lastModified`: DateTime - Kapan tab terakhir dimodifikasi

### ApiConfig
Model untuk konfigurasi API.

```dart
class ApiConfig {
  final String baseUrl;               // Base URL API
  final String endpointPath;          // Endpoint path
  final String token;                 // Bearer token
  final String apiKey;                // API key
  final String username;              // Username untuk basic auth
  final String password;              // Password untuk basic auth
  final int timeoutSec;               // Timeout dalam detik
  final int batchSize;                // Batch size untuk processing
  final double rateLimitSecond;       // Rate limit dalam detik
  final int maxRetries;               // Maximum retry attempts
  final String requestMethod;         // HTTP method (GET/POST)
  final String authMethod;            // Authentication method
  final List<String> stringKeys;      // String fields configuration
}
```

**Properties:**
- `baseUrl`: String - Base URL API (e.g., "localhost:7071")
- `endpointPath`: String - Endpoint path (e.g., "/api/v1/process")
- `token`: String - Bearer token untuk authentication
- `apiKey`: String - API key untuk authentication
- `username`: String - Username untuk basic authentication
- `password`: String - Password untuk basic authentication
- `timeoutSec`: int - Timeout request dalam detik
- `batchSize`: int - Jumlah request yang diproses bersamaan
- `rateLimitSecond`: double - Minimum detik antar request
- `maxRetries`: int - Maximum retry attempts
- `requestMethod`: String - HTTP method ("GET" atau "POST")
- `authMethod`: String - Authentication method ("bearer", "api_key", "basic", "none")
- `stringKeys`: List<String> - List field yang dianggap sebagai string

**Methods:**
- `isValid`: bool - Apakah konfigurasi valid
- `copyWith()`: ApiConfig - Copy dengan field yang diubah

### ProcessingHistory
Model untuk history processing dengan tab context.

```dart
class ProcessingHistory {
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
  final String tabId;                 // Tab ID
  final String tabName;               // Tab name
  final DateTime tabCreatedAt;        // Tab creation date
}
```

**Properties:**
- `id`: String - ID unik dengan format `{tabName}-{tabId}-{timestamp}`
- `timestamp`: DateTime - Kapan processing dilakukan
- `inputFileName`: String - Nama file input
- `inputFilePath`: String - Path file input
- `outputPath`: String - Path file output
- `totalRows`: int - Total baris yang diproses
- `successCount`: int - Jumlah request yang berhasil
- `errorCount`: int - Jumlah request yang gagal
- `configName`: String - Nama konfigurasi API
- `results`: List<ApiResult> - Detail hasil processing
- `isTestMode`: bool - Apakah dalam mode test
- `testRows`: int? - Jumlah baris untuk test mode
- `tabId`: String - ID tab yang melakukan processing
- `tabName`: String - Nama tab yang melakukan processing
- `tabCreatedAt`: DateTime - Kapan tab dibuat

**Methods:**
- `successRate`: double - Rate keberhasilan (0.0 - 1.0)
- `errorRate`: double - Rate error (0.0 - 1.0)
- `formattedTimestamp`: String - Timestamp yang diformat
- `duration`: String - Durasi relatif (e.g., "2 hours ago")
- `displayName`: String - Nama untuk display
- `generateTabHistoryId()`: String - Generate ID untuk tab history

## 🏗️ Providers

### TabManager
Provider untuk mengelola tab lifecycle.

```dart
class TabManager extends ChangeNotifier {
  // Properties
  List<TabData> get tabs;             // List semua tab
  TabData? get activeTab;             // Tab yang aktif
  String? get activeTabId;            // ID tab yang aktif
  bool get hasTabs;                   // Apakah ada tab
  
  // Methods
  void addNewTab();                   // Tambah tab baru
  void closeTab(String tabId);        // Tutup tab
  void switchToTab(String tabId);     // Switch ke tab
  void updateTabTitle(String tabId, String newTitle); // Update nama tab
  void duplicateTab(String tabId);    // Duplikasi tab
  void updateTabConfig(String tabId, ApiConfig config); // Update konfigurasi
  void setTabFilePath(String tabId, String? filePath); // Set file path
  Future<void> saveTabs();            // Simpan tab ke file
  Future<void> loadTabs();            // Load tab dari file
}
```

### TabAppProvider
Provider utama yang menggabungkan tab management dengan app logic.

```dart
class TabAppProvider extends ChangeNotifier {
  // Properties
  TabManager get tabManager;          // Tab manager instance
  TabData? get currentTab;            // Tab yang aktif
  ApiConfig get currentConfig;        // Konfigurasi tab aktif
  String? get currentSelectedFilePath; // File path tab aktif
  bool get isLoading;                 // Loading state
  String? get error;                  // Error message
  ProcessingResult? get lastResult;   // Hasil processing terakhir
  bool get isProcessing;              // Sedang processing
  
  // Methods
  void addNewTab();                   // Tambah tab baru
  void closeTab(String tabId);        // Tutup tab
  void switchToTab(String tabId);     // Switch ke tab
  void updateTabTitle(String tabId, String newTitle); // Update nama tab
  void duplicateTab(String tabId);    // Duplikasi tab
  void saveCurrentTabConfig(ApiConfig config); // Simpan konfigurasi
  void resetCurrentTabConfig();       // Reset konfigurasi
  void setCurrentTabFilePath(String? filePath); // Set file path
  Future<ProcessingResult> processCurrentTabData({int? testRows}); // Process data
  void cancelProcessing();            // Cancel processing
  void clearError();                  // Clear error
}
```

## 🛠️ Services

### HistoryService
Service untuk mengelola history processing.

```dart
class HistoryService {
  // Singleton
  static HistoryService get instance;
  
  // Methods
  Future<List<ProcessingHistory>> getHistory(); // Get semua history
  Future<void> addToHistory(ProcessingHistory history); // Tambah history
  Future<void> removeFromHistory(String historyId); // Hapus history
  Future<void> clearHistory(); // Clear semua history
  Future<ProcessingHistory?> getHistoryById(String id); // Get history by ID
  Future<List<ProcessingHistory>> searchHistory(String query); // Search history
  Future<List<ProcessingHistory>> getHistoryByDateRange(DateTime start, DateTime end); // Filter by date
  Future<Map<String, int>> getHistoryStats(); // Get statistics
  
  // NEW: Tab-specific methods
  Future<List<ProcessingHistory>> getHistoryByTab(String tabId); // Get history by tab
  Future<Map<String, List<ProcessingHistory>>> getHistoryByTabs(); // Get grouped history
  Future<List<String>> getAllTabNames(); // Get semua tab names
}
```

### ProcessingService
Service untuk processing data dengan tab context.

```dart
class ProcessingService {
  // Singleton
  static ProcessingService get instance;
  
  // Properties
  Stream<double> get progressStream;  // Progress stream
  Stream<String> get statusStream;    // Status stream
  Stream<List<ApiResult>> get resultsStream; // Results stream
  bool get isProcessing;              // Processing state
  
  // Methods
  Future<ProcessingResult> processData({
    required ApiConfig config,
    required String inputFilePath,
    int? testRows,
    String? tabId,        // NEW: Tab context
    String? tabName,      // NEW: Tab context
    DateTime? tabCreatedAt, // NEW: Tab context
  });
  
  void cancelProcessing(); // Cancel processing
}
```

### ConfigService
Service untuk mengelola konfigurasi dengan tab support.

```dart
class ConfigService {
  // Singleton
  static ConfigService get instance;
  
  // Methods
  Future<void> saveConfig(ApiConfig config); // Simpan konfigurasi
  Future<ApiConfig> loadConfig(); // Load konfigurasi
  Future<void> saveTabs(List<TabData> tabs); // Simpan tab data
  Future<List<TabData>> loadTabs(); // Load tab data
}
```

### FolderStructureService
Service untuk mengelola struktur folder.

```dart
class FolderStructureService {
  // Singleton
  static FolderStructureService get instance;
  
  // Properties
  String get documentsPath;           // Documents directory
  String get configPath;              // Config directory
  String get resultsPath;             // Results directory
  String get configFilePath;          // Config file path
  String get tabsFilePath;            // Tabs file path
  String get historyFilePath;         // History file path
  
  // Methods
  Future<void> initializeDirectories(); // Initialize directories
}
```

## 🎨 Widgets

### TabBarWidget
Widget untuk menampilkan tab bar.

```dart
class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Returns tab bar with add/close functionality
  }
}
```

**Features:**
- Display tabs dengan nama dan status
- Add new tab button
- Close tab functionality
- Context menu (rename, duplicate)
- Visual indicators untuk status

## 📱 Screens

### TabHomeScreen
Main screen dengan tab interface.

```dart
class TabHomeScreen extends StatefulWidget {
  const TabHomeScreen({super.key});
  
  @override
  State<TabHomeScreen> createState() => _TabHomeScreenState();
}
```

**Features:**
- Tab bar integration
- Screen switching (Configuration, Processing, History, Folders)
- Tab visibility control (tabs only shown for relevant screens)

### TabConfigScreen
Configuration screen untuk tab aktif.

```dart
class TabConfigScreen extends StatefulWidget {
  const TabConfigScreen({super.key});
  
  @override
  State<TabConfigScreen> createState() => _TabConfigScreenState();
}
```

**Features:**
- Real-time validation
- Tab information display
- Configuration form
- Save/reset functionality
- Visual validation indicators

### TabProcessingScreen
Processing screen untuk tab aktif.

```dart
class TabProcessingScreen extends StatefulWidget {
  const TabProcessingScreen({super.key});
  
  @override
  State<TabProcessingScreen> createState() => _TabProcessingScreenState();
}
```

**Features:**
- File selection
- Test mode configuration
- Processing controls
- Real-time progress
- Tab-specific processing

### HistoryScreen
History screen dengan tab context.

```dart
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
```

**Features:**
- History display dengan tab context
- Search dan filter functionality
- Detailed history view
- Export functionality

## 🔧 Validation

### Validation Rules
```dart
List<String> _getValidationErrors(ApiConfig config) {
  final errors = <String>[];
  
  // Required fields
  if (config.baseUrl.isEmpty) {
    errors.add('Base URL is required');
  }
  
  if (config.endpointPath.isEmpty) {
    errors.add('Endpoint Path is required');
  }
  
  // URL validation
  if (config.baseUrl.isNotEmpty) {
    final uri = Uri.tryParse(config.baseUrl);
    if (uri == null) {
      final uriWithScheme = Uri.tryParse('http://${config.baseUrl}');
      if (uriWithScheme == null || !uriWithScheme.hasAuthority) {
        errors.add('Base URL must be a valid URL');
      }
    }
  }
  
  // Authentication validation
  if (config.authMethod == 'bearer' && config.token.isEmpty) {
    errors.add('Bearer Token is required');
  }
  
  if (config.authMethod == 'api_key' && config.apiKey.isEmpty) {
    errors.add('API Key is required');
  }
  
  if (config.authMethod == 'basic') {
    if (config.username.isEmpty) {
      errors.add('Username is required for Basic Auth');
    }
    if (config.password.isEmpty) {
      errors.add('Password is required for Basic Auth');
    }
  }
  
  // Numeric validation
  if (config.timeoutSec <= 0) {
    errors.add('Timeout must be greater than 0');
  }
  
  if (config.batchSize <= 0) {
    errors.add('Batch Size must be greater than 0');
  }
  
  if (config.rateLimitSecond < 0) {
    errors.add('Rate Limit cannot be negative');
  }
  
  if (config.maxRetries < 0) {
    errors.add('Max Retries cannot be negative');
  }
  
  return errors;
}
```

## 📁 File Structure

```
lib/
├── models/
│   ├── tab.dart                    # TabData model
│   ├── config.dart                 # ApiConfig model
│   ├── result.dart                 # ApiResult model
│   └── processing_history.dart     # ProcessingHistory model
├── providers/
│   ├── tab_manager.dart            # Tab management
│   ├── tab_app_provider.dart       # Main provider
│   └── app_provider.dart           # Legacy provider
├── services/
│   ├── history_service.dart        # History management
│   ├── processing_service.dart     # Data processing
│   ├── config_service.dart         # Configuration
│   ├── file_service.dart           # File operations
│   └── folder_structure_service.dart # Folder management
├── screens/
│   ├── tab_home_screen.dart        # Main screen
│   ├── tab_config_screen.dart      # Configuration
│   ├── tab_processing_screen.dart  # Processing
│   ├── history_screen.dart         # History
│   └── folder_management_screen.dart # Folder management
├── widgets/
│   └── tab_bar_widget.dart         # Tab bar widget
└── main.dart                       # App entry point
```

## 🔄 Data Flow

### Tab Creation
```
User clicks "+" → TabManager.addNewTab() → Create TabData → Save to tabs.json → Update UI
```

### Configuration Save
```
User modifies config → TabAppProvider.saveCurrentTabConfig() → TabManager.updateTabConfig() → Save to tabs.json → Update UI
```

### Processing with History
```
User starts processing → TabAppProvider.processCurrentTabData() → ProcessingService.processData() with tab context → Create ProcessingHistory with tab info → Save to history.json → Update UI
```

### Tab Switch
```
User clicks tab → TabManager.switchToTab() → Update activeTabId → Notify listeners → Update UI
```

## 🧪 Testing

### Unit Tests
```dart
// Test tab creation
test('should create new tab with default config', () {
  final tabManager = TabManager();
  tabManager.addNewTab();
  expect(tabManager.tabs.length, 1);
  expect(tabManager.activeTab?.title, 'Tab 1');
});

// Test validation
test('should validate required fields', () {
  final config = ApiConfig();
  final errors = _getValidationErrors(config);
  expect(errors, contains('Base URL is required'));
});
```

### Integration Tests
```dart
// Test processing with tab context
testWidgets('should process data with tab context', (tester) async {
  await tester.pumpWidget(MyApp());
  // Test processing flow
});
```

## 📚 Examples

### Creating a New Tab
```dart
final provider = context.read<TabAppProvider>();
provider.addNewTab();
```

### Saving Configuration
```dart
final config = ApiConfig(
  baseUrl: 'localhost:7071',
  endpointPath: '/api/v1/process',
  authMethod: 'bearer',
  token: 'your-token',
  // ... other fields
);
provider.saveCurrentTabConfig(config);
```

### Processing Data
```dart
final result = await provider.processCurrentTabData(testRows: 10);
```

### Getting History
```dart
final historyService = HistoryService.instance;
final history = await historyService.getHistoryByTab('tab_1');
```
