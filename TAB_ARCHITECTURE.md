# Tab System Architecture

## Overview
Sistem tab management memungkinkan aplikasi untuk mengelola multiple konfigurasi API secara bersamaan dengan interface yang mirip browser. Setiap tab memiliki konfigurasi independen dan history processing yang terpisah.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TabHomeScreen                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                TabBarWidget                         │   │
│  │  [Tab 1] [Tab 2] [Tab 3] [+]                       │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              IndexedStack                           │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │   │
│  │  │TabConfig    │ │TabProcessing│ │History      │   │   │
│  │  │Screen       │ │Screen       │ │Screen       │   │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  TabAppProvider                            │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   TabManager    │  │ProcessingService│                 │
│  │                 │  │                 │                 │
│  │ • Manage tabs   │  │ • Process data  │                 │
│  │ • Save/load     │  │ • Progress      │                 │
│  │ • Switch tabs   │  │ • Results       │                 │
│  │ • Tab history   │  │ • Tab context   │                 │
│  └─────────────────┘  └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                              │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   ConfigService │  │FolderStructure  │                 │
│  │                 │  │Service          │                 │
│  │ • Save tabs     │  │ • Manage paths  │                 │
│  │ • Load tabs     │  │ • Create dirs   │                 │
│  │ • Tab history   │  │ • Tab files     │                 │
│  └─────────────────┘  └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    File System                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   tabs.json     │  │ processing_     │                 │
│  │                 │  │ history.json    │                 │
│  │ • Tab data      │  │                 │                 │
│  │ • Configurations│  │ • Tab history   │                 │
│  │ • Tab metadata  │  │ • Processing    │                 │
│  └─────────────────┘  │ results         │                 │
│                       └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Tab Creation Flow
```
User clicks "+" → TabManager.addNewTab() → Create TabData → Save to tabs.json → Update UI
```

### 2. Configuration Save Flow
```
User modifies config → TabAppProvider.saveCurrentTabConfig() → TabManager.updateTabConfig() → Save to tabs.json → Update UI
```

### 3. Tab Switch Flow
```
User clicks tab → TabManager.switchToTab() → Update activeTabId → Notify listeners → Update UI
```

### 4. Processing Flow
```
User starts processing → TabAppProvider.processCurrentTabData() → Get current tab config → ProcessingService.processData() with tab context → Save tab-specific history → Return results
```

### 5. History Tracking Flow
```
Processing completes → Create ProcessingHistory with tab info → Generate tab-specific ID → Save to history.json → Update UI
```

## Key Components

### TabData Model
```dart
class TabData {
  final String id;           // Unique identifier
  final String title;        // Display name
  final ApiConfig config;    // API configuration
  final String? selectedFilePath; // Selected input file
  final DateTime createdAt;  // Creation timestamp
  final DateTime lastModified; // Last modification timestamp
}
```

### ProcessingHistory Model (Enhanced)
```dart
class ProcessingHistory {
  // Existing fields...
  final String tabId;        // Tab ID when processing was done
  final String tabName;      // Tab name when processing was done
  final DateTime tabCreatedAt; // When the tab was created
  
  // Tab-specific history ID generation
  static String generateTabHistoryId(String tabName, String tabId, DateTime timestamp) {
    // Format: {tabName}-{tabId}-{YYYYMMDD}-{HHMMSS}
  }
}
```

### TabManager
- Manages list of tabs
- Handles tab operations (add, remove, switch, duplicate, rename)
- Persists tab data to file system
- Notifies UI of changes
- Maintains tab counter for unique naming

### TabAppProvider
- Combines TabManager with ProcessingService
- Provides unified interface for tab-aware operations
- Manages current tab state
- Handles configuration and processing per tab
- Coordinates between tab management and processing logic

### TabBarWidget
- Displays tab bar UI
- Handles tab interactions (click, close, add)
- Shows tab context menu (rename, duplicate)
- Provides visual indicators for tab status
- Manages tab overflow and scrolling

## File Structure

```
lib/
├── models/
│   ├── tab.dart                    # TabData model
│   ├── config.dart                 # ApiConfig model (existing)
│   ├── result.dart                 # ProcessingResult model (existing)
│   └── processing_history.dart     # Enhanced with tab information
├── providers/
│   ├── tab_manager.dart            # Tab management logic
│   ├── tab_app_provider.dart       # Main provider combining tab + app logic
│   └── app_provider.dart           # Legacy provider (kept for compatibility)
├── screens/
│   ├── tab_home_screen.dart        # Main screen with tab interface
│   ├── tab_config_screen.dart      # Config screen for current tab
│   ├── tab_processing_screen.dart  # Processing screen for current tab
│   ├── history_screen.dart         # Enhanced with tab-aware history
│   └── ... (other existing screens)
├── widgets/
│   └── tab_bar_widget.dart         # Tab bar UI component
└── services/
    ├── config_service.dart         # Extended with tab persistence
    ├── history_service.dart        # Enhanced with tab-specific methods
    ├── processing_service.dart     # Enhanced with tab context
    └── folder_structure_service.dart # Extended with tabs.json path
```

## State Management

### Tab State
- **Active Tab ID**: Currently selected tab
- **Tab List**: All available tabs with their data
- **Tab Data**: Configuration and file path per tab
- **Tab Counter**: For generating unique tab names

### App State
- **Loading State**: Global loading indicator
- **Error State**: Error messages
- **Processing State**: Current processing status
- **Results**: Last processing results
- **History**: Tab-specific processing history

### Validation State
- **Real-time Validation**: Configuration validity per tab
- **Error Messages**: Specific validation errors
- **Visual Indicators**: Status indicators across UI

## Persistence Strategy

### Automatic Saving
- Tab changes saved immediately
- Configuration changes saved on explicit save action
- File path changes saved immediately
- History entries saved after each processing

### File Format

#### tabs.json
```json
[
  {
    "id": "tab_1",
    "title": "Production API",
    "config": { /* ApiConfig JSON */ },
    "selectedFilePath": "/path/to/file.csv",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "lastModified": "2024-01-01T12:00:00.000Z"
  }
]
```

#### processing_history.json
```json
[
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
    "results": [ /* ApiResult array */ ],
    "isTestMode": false,
    "testRows": null,
    "tabId": "tab_1",
    "tabName": "Production API",
    "tabCreatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### Error Handling
- Graceful fallback to default tab if file is corrupted
- Validation of tab data on load
- Automatic recovery from invalid states
- History corruption handling with fallback

## Validation System

### Real-time Validation
- Configuration validation on every change
- Visual indicators for valid/invalid status
- Error messages with specific guidance
- Pre-processing validation checks

### Validation Rules
- **Required Fields**: Base URL, Endpoint Path
- **URL Format**: Valid URL format (supports localhost:7071)
- **Authentication**: Required fields based on auth method
- **Numeric Values**: Positive values for timeout, batch size, etc.

## Benefits

1. **Multi-Environment Support**: Different tabs for different environments
2. **Configuration Isolation**: Each tab has independent configuration
3. **Improved Workflow**: Switch between different API setups quickly
4. **Better Organization**: Clear separation of different use cases
5. **Familiar UX**: Browser-like interface that users understand
6. **Data Persistence**: All configurations saved automatically
7. **Scalability**: Easy to add more tabs as needed
8. **History Tracking**: Rich context for each processing run
9. **Validation**: Real-time feedback on configuration issues
10. **Error Prevention**: Pre-processing validation prevents runtime errors

## Migration Strategy

### From Legacy Version
- Automatic migration of existing configuration to first tab
- Legacy `api_config.json` preserved as backup
- Seamless transition for existing users
- No data loss during migration

### Backward Compatibility
- Legacy screens still available
- Existing configuration files supported
- Gradual migration path for users
- Fallback mechanisms for corrupted data

## Performance Considerations

### Memory Management
- Lazy loading of tab configurations
- Efficient state updates with ChangeNotifier
- Proper disposal of resources
- Minimal memory footprint per tab

### File I/O Optimization
- Batch file operations where possible
- Efficient JSON serialization
- Async file operations
- Error recovery mechanisms

### UI Performance
- Efficient widget rebuilding
- Proper use of Consumer pattern
- Minimal unnecessary redraws
- Smooth tab switching animations