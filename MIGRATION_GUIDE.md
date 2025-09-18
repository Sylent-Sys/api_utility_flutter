# Migration Guide

## Overview
Panduan migrasi dari API Utility Flutter v1.x ke v2.0.0 dengan Multi-Tab Interface support.

## 🚀 What's New in v2.0.0

### Major Features
- **Multi-Tab Interface**: Browser-like tab management
- **Tab-Specific History**: Rich history tracking per tab
- **Real-time Validation**: Comprehensive configuration validation
- **Enhanced UX**: Better user experience with visual indicators

### Breaking Changes
- **New Architecture**: Tab-aware application architecture
- **File Structure**: New files and enhanced existing files
- **Data Format**: Enhanced data formats with tab context
- **API Changes**: New methods and enhanced existing methods

## 📁 File Structure Changes

### New Files
```
lib/
├── models/
│   └── tab.dart                    # NEW: Tab data model
├── providers/
│   ├── tab_manager.dart            # NEW: Tab management
│   └── tab_app_provider.dart       # NEW: Main tab provider
├── screens/
│   ├── tab_home_screen.dart        # NEW: Main screen with tabs
│   ├── tab_config_screen.dart      # NEW: Tab-aware config
│   └── tab_processing_screen.dart  # NEW: Tab-aware processing
├── widgets/
│   └── tab_bar_widget.dart         # NEW: Tab bar widget
└── docs/
    ├── TAB_ARCHITECTURE.md         # NEW: Architecture docs
    ├── TAB_FEATURES.md             # NEW: Features docs
    ├── VALIDATION_FEATURES.md      # NEW: Validation docs
    ├── TAB_HISTORY_FEATURES.md     # NEW: History docs
    ├── API_REFERENCE.md            # NEW: API reference
    └── MIGRATION_GUIDE.md          # NEW: This file
```

### Enhanced Files
```
lib/
├── models/
│   └── processing_history.dart     # ENHANCED: Tab context
├── services/
│   ├── history_service.dart        # ENHANCED: Tab methods
│   ├── processing_service.dart     # ENHANCED: Tab context
│   ├── config_service.dart         # ENHANCED: Tab persistence
│   └── folder_structure_service.dart # ENHANCED: Tab paths
├── screens/
│   └── history_screen.dart         # ENHANCED: Tab context
└── main.dart                       # ENHANCED: Tab provider
```

### Legacy Files (Kept for Compatibility)
```
lib/
├── providers/
│   └── app_provider.dart           # LEGACY: Kept for compatibility
├── screens/
│   ├── config_screen.dart          # LEGACY: Original config screen
│   ├── processing_screen.dart      # LEGACY: Original processing screen
│   └── home_screen.dart            # LEGACY: Original home screen
```

## 🔄 Data Migration

### Automatic Migration
Aplikasi akan otomatis melakukan migrasi saat pertama kali dibuka dengan v2.0.0:

1. **Deteksi Konfigurasi Lama**: Aplikasi mendeteksi file `api_config.json`
2. **Buat Tab Default**: Konfigurasi lama di-copy ke tab default baru
3. **Preserve Data**: Semua data lama tetap tersimpan
4. **Seamless Transition**: User bisa langsung menggunakan fitur tab

### Migration Process
```dart
// Automatic migration in TabManager
Future<void> _initializeDefaultTab() async {
  try {
    // Try to load existing config
    final existingConfig = await _configService.loadConfig();
    
    // Create default tab with existing config
    final defaultTab = TabData(
      id: _generateTabId(),
      title: 'Tab 1',
      config: existingConfig,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    _tabs.add(defaultTab);
    _activeTabId = defaultTab.id;
    
    // Save new tab structure
    await saveTabs();
  } catch (e) {
    // Create default tab with default config
    final defaultTab = TabData(
      id: _generateTabId(),
      title: 'Tab 1',
      config: const ApiConfig(),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    _tabs.add(defaultTab);
    _activeTabId = defaultTab.id;
  }
}
```

### File Structure Changes

#### Before (v1.x)
```
{AppDocuments}/API_Utility_Flutter/
├── config/
│   └── api_config.json             # Single configuration
├── results/
│   └── results_*.json              # Processing results
└── processing_history.json         # Processing history
```

#### After (v2.0.0)
```
{AppDocuments}/API_Utility_Flutter/
├── config/
│   ├── api_config.json             # Legacy config (preserved)
│   └── tabs.json                   # NEW: Tab data
├── results/
│   └── results_*.json              # Processing results
└── processing_history.json         # ENHANCED: Tab-specific history
```

## 🔧 Code Migration

### Provider Changes

#### Before (v1.x)
```dart
// Using AppProvider
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final config = provider.config;
        // Use config...
      },
    );
  }
}
```

#### After (v2.0.0)
```dart
// Using TabAppProvider
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
        final config = provider.currentConfig;
        final currentTab = provider.currentTab;
        // Use config and tab info...
      },
    );
  }
}
```

### Screen Changes

#### Before (v1.x)
```dart
// Using legacy screens
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(), // Legacy home screen
    );
  }
}
```

#### After (v2.0.0)
```dart
// Using tab-aware screens
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TabAppProvider(),
      child: MaterialApp(
        home: TabHomeScreen(), // NEW: Tab-aware home screen
      ),
    );
  }
}
```

### Configuration Access

#### Before (v1.x)
```dart
// Direct config access
final config = provider.config;
await provider.saveConfig(newConfig);
```

#### After (v2.0.0)
```dart
// Tab-aware config access
final config = provider.currentConfig;
final currentTab = provider.currentTab;
await provider.saveCurrentTabConfig(newConfig);
```

### Processing Changes

#### Before (v1.x)
```dart
// Simple processing
final result = await provider.processData(
  config: config,
  inputFilePath: filePath,
);
```

#### After (v2.0.0)
```dart
// Tab-aware processing
final result = await provider.processCurrentTabData(
  testRows: testRows,
);
// Tab context automatically included
```

## 📊 Data Format Changes

### Configuration Format

#### Before (v1.x)
```json
{
  "baseUrl": "https://api.example.com",
  "endpointPath": "/v1/process",
  "authMethod": "bearer",
  "token": "your-token",
  "timeoutSec": 240,
  "batchSize": 10,
  "rateLimitSecond": 0.5,
  "maxRetries": 3
}
```

#### After (v2.0.0)
```json
[
  {
    "id": "tab_1",
    "title": "Tab 1",
    "config": {
      "baseUrl": "https://api.example.com",
      "endpointPath": "/v1/process",
      "authMethod": "bearer",
      "token": "your-token",
      "timeoutSec": 240,
      "batchSize": 10,
      "rateLimitSecond": 0.5,
      "maxRetries": 3,
      "requestMethod": "POST",
      "stringKeys": []
    },
    "selectedFilePath": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "lastModified": "2024-01-01T00:00:00.000Z"
  }
]
```

### History Format

#### Before (v1.x)
```json
{
  "id": "uuid-123",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "inputFileName": "data.csv",
  "totalRows": 100,
  "successCount": 95,
  "errorCount": 5
}
```

#### After (v2.0.0)
```json
{
  "id": "Tab1-tab_1-20240101-120000",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "inputFileName": "data.csv",
  "totalRows": 100,
  "successCount": 95,
  "errorCount": 5,
  "tabId": "tab_1",
  "tabName": "Tab 1",
  "tabCreatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 🛠️ Migration Steps

### For Users
1. **Backup Data**: Backup folder `{AppDocuments}/API_Utility_Flutter/`
2. **Update App**: Install v2.0.0
3. **First Launch**: App akan otomatis migrasi
4. **Verify Data**: Cek apakah konfigurasi lama tersedia di tab pertama
5. **Explore Features**: Coba fitur tab baru

### For Developers
1. **Update Dependencies**: Pastikan semua dependencies up-to-date
2. **Review Changes**: Baca dokumentasi perubahan
3. **Update Code**: Update code sesuai dengan API baru
4. **Test Migration**: Test migrasi dengan data lama
5. **Update Tests**: Update unit tests dan integration tests

### For Custom Integrations
1. **Review API Changes**: Cek perubahan di API
2. **Update Integration**: Update kode integrasi
3. **Test Compatibility**: Test kompatibilitas dengan v2.0.0
4. **Update Documentation**: Update dokumentasi integrasi

## 🔍 Troubleshooting

### Migration Issues

#### Konfigurasi Tidak Ter-migrasi
**Problem**: Konfigurasi lama tidak muncul di tab pertama
**Solution**:
1. Cek file `api_config.json` apakah ada dan valid
2. Restart aplikasi
3. Jika masih tidak ada, buat tab baru dan konfigurasi manual

#### Tab Tidak Tersimpan
**Problem**: Tab hilang setelah restart
**Solution**:
1. Cek permission aplikasi untuk menulis file
2. Cek folder `{AppDocuments}/API_Utility_Flutter/config/`
3. Cek file `tabs.json` apakah ada dan valid

#### History Tidak Muncul
**Problem**: History lama tidak muncul
**Solution**:
1. History lama tetap ada di file `processing_history.json`
2. History baru akan menggunakan format tab-specific
3. Tidak ada data yang hilang

### Performance Issues

#### Aplikasi Lambat
**Problem**: Aplikasi menjadi lambat setelah update
**Solution**:
1. Restart aplikasi
2. Cek jumlah tab (recommended: max 10-15)
3. Clear history lama jika tidak diperlukan

#### Memory Usage Tinggi
**Problem**: Memory usage tinggi
**Solution**:
1. Close tab yang tidak digunakan
2. Restart aplikasi
3. Monitor memory usage

## 🔮 Rollback Plan

### Jika Perlu Rollback ke v1.x
1. **Backup Data**: Backup folder aplikasi
2. **Uninstall v2.0.0**: Uninstall aplikasi
3. **Install v1.x**: Install versi lama
4. **Restore Data**: Restore data dari backup
5. **Verify**: Pastikan semua data tersedia

### Data Compatibility
- **v1.x → v2.0.0**: Otomatis migrasi
- **v2.0.0 → v1.x**: Manual restore diperlukan
- **Legacy Support**: v2.0.0 tetap support file format lama

## 📚 Additional Resources

### Documentation
- [TAB_ARCHITECTURE.md](TAB_ARCHITECTURE.md) - Architecture overview
- [TAB_FEATURES.md](TAB_FEATURES.md) - Features documentation
- [VALIDATION_FEATURES.md](VALIDATION_FEATURES.md) - Validation system
- [TAB_HISTORY_FEATURES.md](TAB_HISTORY_FEATURES.md) - History system
- [API_REFERENCE.md](API_REFERENCE.md) - API reference

### Support
- **GitHub Issues**: Report bugs dan request features
- **Documentation**: Baca dokumentasi lengkap
- **Community**: Join community discussion

## ✅ Migration Checklist

### Pre-Migration
- [ ] Backup data aplikasi
- [ ] Review changelog
- [ ] Update dependencies
- [ ] Test dengan data sample

### Migration
- [ ] Install v2.0.0
- [ ] Launch aplikasi
- [ ] Verify automatic migration
- [ ] Check tab functionality
- [ ] Test configuration save/load
- [ ] Test processing functionality
- [ ] Check history display

### Post-Migration
- [ ] Explore new features
- [ ] Create additional tabs
- [ ] Test tab management
- [ ] Verify data persistence
- [ ] Update custom integrations
- [ ] Update documentation
- [ ] Train users (if applicable)

## 🎉 Benefits After Migration

### For Users
- **Multi-Environment**: Manage multiple API configurations
- **Better Organization**: Clear separation of different use cases
- **Rich History**: Detailed processing history with context
- **Improved UX**: Better user experience with validation

### For Developers
- **Better Architecture**: Cleaner, more maintainable code
- **Enhanced API**: More powerful and flexible API
- **Better Testing**: Improved testability and reliability
- **Future-Proof**: Ready for future enhancements

### For Operations
- **Better Monitoring**: Rich context for monitoring and debugging
- **Improved Reliability**: Better error handling and validation
- **Enhanced Security**: Better data isolation and management
- **Scalability**: Ready for scaling and growth
