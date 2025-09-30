## [v2.3.0] - 2025-09-30

### minor version bump
- Version bumped from 2.2.1+10 to 2.3.0+11
- Automated release build

### Changes
- See commit history for detailed changes

## [v2.2.1] - 2025-09-24

### patch version bump
- Version bumped from 2.2.0+9 to 2.2.1+10
- Automated release build

### Changes
- See commit history for detailed changes

## [v2.2.0] - 2025-09-24

### minor version bump
- Version bumped from 2.1.1+8 to 2.2.0+9
- Automated release build

### Changes
- See commit history for detailed changes

## [v2.1.1] - 2025-09-18

### patch version bump
- Version bumped from 2.1.0+7 to 2.1.1+8
- Automated release build

### Changes
- See commit history for detailed changes

## [v2.1.0] - 2025-09-18

### minor version bump
- Version bumped from 2.0.0+6 to 2.1.0+7
- Automated release build

### Changes
- See commit history for detailed changes

# Changelog

All notable changes to this project will be documented in this file.

## [v2.0.0] - 2025-9-18

### 🎉 Major Release - Multi-Tab Interface

#### ✨ New Features
- **Multi-Tab Interface**: Browser-like tab management system
  - Add, remove, rename, and duplicate tabs
  - Each tab maintains independent API configurations
  - Visual tab indicators with status information
  - Tab persistence across application sessions

- **Tab-Specific History**: Enhanced history tracking
  - History entries include tab information (name, ID, creation date)
  - Persistent history even after tab deletion
  - Rich context for each processing run
  - Naming convention: `{tabName}-{tabId}-{timestamp}`

- **Real-time Validation System**: Comprehensive configuration validation
  - Real-time validation status indicators
  - Smart error messages with actionable feedback
  - Pre-processing validation checks
  - Visual status indicators across all screens

- **Enhanced User Experience**:
  - Context-aware notifications and error messages
  - Improved dropdown synchronization between tabs
  - Better URL validation (supports localhost:7071 format)
  - Consistent validation logic across all screens

#### 🔧 Technical Improvements
- **New Architecture**: Tab-aware application architecture
  - `TabManager` for tab lifecycle management
  - `TabAppProvider` for unified state management
  - `TabBarWidget` for tab interface
  - Enhanced `ProcessingHistory` model with tab information

- **Enhanced Services**:
  - `HistoryService` with tab-specific methods
  - `ProcessingService` with tab context
  - `ConfigService` with tab persistence
  - Improved error handling and validation

- **New Models**:
  - `TabData` model for tab information
  - Enhanced `ProcessingHistory` with tab context
  - Improved `ApiConfig` validation

#### 🐛 Bug Fixes
- Fixed dropdown fields not syncing when switching tabs
- Fixed authentication fields not appearing when changing auth method
- Fixed Base URL validation to accept localhost:7071 and similar URLs
- Fixed setState() called during build error
- Fixed validation inconsistency between Configuration and Processing screens
- Fixed tabs appearing in History and Folders screens (now hidden appropriately)

#### 📱 UI/UX Improvements
- Tab bar with visual indicators
- Real-time validation status cards
- Context-aware error messages
- Improved navigation between screens
- Better visual feedback for user actions

#### 🗂️ File Structure Changes
```
lib/
├── models/
│   ├── tab.dart                    # NEW: Tab data model
│   ├── processing_history.dart     # ENHANCED: Tab-specific history
│   ├── config.dart                 # EXISTING: API configuration
│   └── result.dart                 # EXISTING: Processing results
├── providers/
│   ├── tab_manager.dart            # NEW: Tab management logic
│   ├── tab_app_provider.dart       # NEW: Main tab-aware provider
│   └── app_provider.dart           # EXISTING: Legacy provider
├── screens/
│   ├── tab_home_screen.dart        # NEW: Main screen with tabs
│   ├── tab_config_screen.dart      # NEW: Tab-aware config screen
│   ├── tab_processing_screen.dart  # NEW: Tab-aware processing screen
│   ├── history_screen.dart         # ENHANCED: Tab-aware history
│   └── ... (other existing screens)
├── widgets/
│   └── tab_bar_widget.dart         # NEW: Tab bar UI component
└── services/
    ├── history_service.dart        # ENHANCED: Tab-specific methods
    ├── processing_service.dart     # ENHANCED: Tab context support
    ├── config_service.dart         # ENHANCED: Tab persistence
    └── folder_structure_service.dart # ENHANCED: Tab file paths
```

#### 💾 Data Storage
- **New File**: `tabs.json` for tab data persistence
- **Enhanced**: History tracking with tab context
- **Backward Compatible**: Legacy configuration files still supported

---

## [v1.1.3] - 2025-09-17

### patch version bump
- Version bumped from 1.1.2+4 to 1.1.3+5
- Automated release build

### Changes
- See commit history for detailed changes

## [v1.1.2] - 2025-09-17

### patch version bump
- Version bumped from 1.1.1+3 to 1.1.2+4
- Automated release build

### Changes
- See commit history for detailed changes

## [v1.1.1] - 2025-09-17

### patch version bump
- Version bumped from 1.1.0+2 to 1.1.1+3
- Automated release build

### Changes
- See commit history for detailed changes

## [v1.1.0] - 2025-09-17

### minor version bump
- Version bumped from 1.0.0+1 to 1.1.0+2
- Automated release build

### Changes
- See commit history for detailed changes

## [v1.0.0] - 2025-09-17

### 🎉 Initial Release
- Basic API utility functionality
- CSV/Excel file processing
- Multiple authentication methods
- Batch processing with rate limiting
- Result management and export
- Configuration persistence