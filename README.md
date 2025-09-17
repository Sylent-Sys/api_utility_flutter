# API Utility Flutter

A powerful Flutter application for processing CSV/Excel data through API calls, inspired by the Go API utility project.

## Features

- **File Processing**: Support for CSV and Excel (.xlsx, .xlsm) files
- **Multiple Authentication Methods**: Bearer token, API key, Basic auth, or no authentication
- **Batch Processing**: Process data in configurable batches with rate limiting
- **Real-time Progress**: Live progress tracking with detailed status updates
- **Retry Logic**: Automatic retry with exponential backoff for failed requests
- **Result Management**: View, search, and filter processing results
- **Configuration Management**: Save and load API configurations
- **Test Mode**: Process limited rows for testing purposes

## Getting Started

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

## Usage

### Configuration

1. Navigate to the **Configuration** tab
2. Set up your API settings:
   - **Base URL**: Your API endpoint base URL
   - **Endpoint Path**: The specific API endpoint path
   - **Authentication**: Choose from Bearer, API Key, Basic, or None
   - **Processing Settings**: Configure timeout, batch size, rate limiting, and retry settings

3. Save your configuration

### Processing Data

1. Navigate to the **Processing** tab
2. Select a CSV or Excel file using the file picker
3. Optionally set test mode to process only a limited number of rows
4. Click **Start Processing** to begin
5. Monitor real-time progress and results
6. View detailed results in the results screen

### Results

- View all results, successful requests, or errors separately
- Search through results by content
- Filter results by status
- Copy individual results to clipboard
- Export results to JSON files

## Configuration Options

### API Settings
- **Base URL**: The base URL of your API (e.g., `http://localhost:7071/api`)
- **Endpoint Path**: The endpoint path (e.g., `/FYP/Bengkel/AttendanceMonitoring/Create`)
- **Request Method**: GET or POST
- **Authentication Method**: Bearer, API Key, Basic, or None

### Processing Settings
- **Timeout**: Request timeout in seconds (default: 240)
- **Batch Size**: Number of requests to process concurrently (default: 10)
- **Rate Limit**: Minimum seconds between requests (default: 0.5)
- **Max Retries**: Maximum number of retry attempts (default: 3)
- **String Fields**: Comma-separated list of fields to treat as strings

## File Formats

### Input Files
- **CSV**: Standard comma-separated values files
- **Excel**: .xlsx and .xlsm files
- First row should contain column headers
- Data will be processed row by row

### Output Files
- **JSON**: Results are saved as formatted JSON files
- **Filename Pattern**: `results_{timestamp}.json`
- **Location**: Application documents directory

## Authentication Methods

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

## Error Handling

- **Network Errors**: Automatic retry with exponential backoff
- **HTTP Errors**: Retry on 5xx status codes and 429 (Too Many Requests)
- **Timeout Errors**: Configurable timeout with retry logic
- **Validation Errors**: Clear error messages for configuration issues

## Development

### Project Structure
```
lib/
├── models/           # Data models (Config, Result)
├── services/         # Business logic services
├── screens/          # UI screens
├── providers/        # State management
└── main.dart         # Application entry point
```

### Key Dependencies
- `provider`: State management
- `dio`: HTTP client with retry logic
- `file_picker`: File selection
- `csv` & `excel`: File parsing
- `shared_preferences`: Configuration persistence
- `flutter_spinkit`: Loading animations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the Go API utility project
- Built with Flutter and Dart
- Uses Material Design 3 for UI components
