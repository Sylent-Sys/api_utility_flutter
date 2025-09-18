# API Utility Flutter

A powerful Flutter application for processing CSV/Excel data through API calls with **Multi-Tab Interface** support, inspired by the Go API utility project.

## 🚀 Features

### Core Features
- **Multi-Tab Interface**: Browser-like tab management for multiple API configurations
- **File Processing**: Support for CSV and Excel (.xlsx, .xlsm) files
- **Multiple Authentication Methods**: Bearer token, API key, Basic auth, or no authentication
- **Batch Processing**: Process data in configurable batches with rate limiting
- **Real-time Progress**: Live progress tracking with detailed status updates
- **Retry Logic**: Automatic retry with exponential backoff for failed requests
- **Result Management**: View, search, and filter processing results
- **Configuration Management**: Save and load API configurations per tab
- **Test Mode**: Process limited rows for testing purposes

### Tab Management Features
- **Add/Remove Tabs**: Create and delete tabs with independent configurations
- **Tab Operations**: Rename, duplicate, and switch between tabs
- **Per-Tab Configuration**: Each tab maintains its own API settings
- **Tab Persistence**: All tab configurations saved automatically
- **Visual Indicators**: Status indicators for each tab's configuration validity

### Validation & Notifications
- **Real-time Validation**: Instant feedback on configuration validity
- **Smart Notifications**: Context-aware error messages and success notifications
- **Pre-processing Checks**: Validation before starting data processing
- **Visual Status Indicators**: Clear visual cues for configuration status

### History Management
- **Tab-Specific History**: Processing history tracked per tab
- **Persistent History**: History remains even after tab deletion
- **Rich Context**: History includes tab information and timestamps
- **Search & Filter**: Find specific processing runs easily

## 📱 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd api_utility_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 🎯 Usage

### Tab Management

1. **Create New Tab**: Click the "+" button in the tab bar
2. **Switch Tabs**: Click on any tab to switch between configurations
3. **Rename Tab**: Right-click on tab or use edit button in configuration screen
4. **Duplicate Tab**: Right-click on tab and select "Duplicate"
5. **Close Tab**: Click "X" button (minimum 1 tab must remain)

### Configuration

1. Navigate to the **Configuration** tab
2. Select the desired tab from the tab bar
3. Set up your API settings:
   - **Base URL**: Your API endpoint base URL (e.g., `localhost:7071`)
   - **Endpoint Path**: The specific API endpoint path
   - **Request Method**: GET or POST
   - **Authentication**: Choose from Bearer, API Key, Basic, or None
   - **Processing Settings**: Configure timeout, batch size, rate limiting, and retry settings
4. Save your configuration (validates automatically)

### Processing Data

1. Navigate to the **Processing** tab
2. Ensure you're on the correct tab
3. Select a CSV or Excel file using the file picker
4. Optionally set test mode to process only a limited number of rows
5. Click **Start Processing** to begin
6. Monitor real-time progress and results
7. View detailed results in the results screen

### History

1. Navigate to the **History** tab
2. View all processing history across all tabs
3. Search and filter by tab name, file name, or configuration
4. Click on any history entry to view detailed results

## ⚙️ Configuration Options

### API Settings
- **Base URL**: The base URL of your API (e.g., `http://localhost:7071`, `https://api.example.com`)
- **Endpoint Path**: The endpoint path (e.g., `/api/v1/process`)
- **Request Method**: GET or POST
- **Authentication Method**: Bearer, API Key, Basic, or None

### Processing Settings
- **Timeout**: Request timeout in seconds (default: 240)
- **Batch Size**: Number of requests to process concurrently (default: 10)
- **Rate Limit**: Minimum seconds between requests (default: 0.5)
- **Max Retries**: Maximum number of retry attempts (default: 3)
- **String Fields**: Comma-separated list of fields to treat as strings

## 📁 File Formats

### Input Files
- **CSV**: Standard comma-separated values files
- **Excel**: .xlsx and .xlsm files
- First row should contain column headers
- Data will be processed row by row

### Output Files
- **JSON**: Results are saved as formatted JSON files
- **Filename Pattern**: `results_{timestamp}.json`
- **Location**: Application documents directory

## 🔐 Authentication Methods

### Bearer Token
- Set the `token` field in configuration
- Adds `Authorization: Bearer <token>` header

### API Key
- Set the `apiKey` field in configuration
- Adds `X-API-Key: <key>` header

### Basic Authentication
- Set `username` and `password` fields
- Adds `Authorization: Basic <base64-encoded-credentials>` header

### None
- No authentication headers added

## 🛡️ Error Handling

- **Network Errors**: Automatic retry with exponential backoff
- **HTTP Errors**: Retry on 5xx status codes and 429 (Too Many Requests)
- **Timeout Errors**: Configurable timeout with retry logic
- **Validation Errors**: Clear error messages for configuration issues
- **Real-time Validation**: Immediate feedback on configuration problems

## 🏗️ Development

### Project Structure
```
lib/
├── models/           # Data models (Config, Result, Tab, ProcessingHistory)
├── services/         # Business logic services
├── screens/          # UI screens (tab-aware and legacy)
├── providers/        # State management (tab-aware and legacy)
├── widgets/          # Reusable UI components
└── main.dart         # Application entry point
```

### Key Dependencies
- `provider`: State management
- `dio`: HTTP client with retry logic
- `file_picker`: File selection
- `csv` & `excel`: File parsing
- `shared_preferences`: Configuration persistence
- `flutter_spinkit`: Loading animations

### Architecture
- **Multi-Tab System**: Browser-like interface with independent configurations
- **Provider Pattern**: State management with ChangeNotifier
- **Service Layer**: Business logic separation
- **Validation System**: Real-time configuration validation
- **History Tracking**: Tab-specific processing history

## 📊 Tab-Specific History

The application now tracks processing history per tab with the following features:

### History ID Format
```
{tabName}-{tabId}-{YYYYMMDD}-{HHMMSS}
```

### Example History Entries
```
ID: APIDev-abc123-20241218-143022
Display: API Dev (18/12/2024 14:30)
Tab: API Dev (created: 15/12/2024 10:00)
File: data.csv
Status: 150/200 success

ID: Production-xyz789-20241218-150045  
Display: Production (18/12/2024 15:00)
Tab: Production (created: 16/12/2024 09:00)
File: users.xlsx
Status: 500/500 success
```

### Benefits
- **Persistent Tracking**: History remains even after tab deletion
- **Rich Context**: Know exactly which tab processed which data
- **Easy Identification**: Clear naming convention for history entries
- **Cross-Session**: History persists across application restarts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by the Go API utility project
- Built with Flutter and Dart
- Uses Material Design 3 for UI components
- Multi-tab interface inspired by modern browser design