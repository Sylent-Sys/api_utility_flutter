# Utility Classes

This directory contains utility classes that provide reusable functionality across the application.

## Files

### `validation_utils.dart`
Contains validation logic for forms and configuration data.

**Key Methods:**
- `validateUrl()` - Validates URL format
- `validateRequired()` - Validates required fields
- `validatePositiveInteger()` - Validates positive integers
- `validateNonNegativeInteger()` - Validates non-negative integers
- `validateNonNegativeDouble()` - Validates non-negative doubles
- `validateAuthField()` - Validates authentication fields based on auth method
- `validatePassword()` - Validates password for basic authentication
- `getConfigValidationErrors()` - Gets all validation errors for ApiConfig
- `isConfigValid()` - Checks if configuration is valid

### `config_utils.dart`
Contains configuration-related utility functions.

**Key Methods:**
- `createDefaultConfig()` - Creates default ApiConfig
- `updateConfig()` - Updates configuration with new values
- `parseStringKeys()` - Parses comma-separated string keys
- `stringKeysToString()` - Converts string keys list to comma-separated string
- `getAuthMethods()` - Gets available authentication methods
- `getRequestMethods()` - Gets available request methods
- `getDefaultNumericValues()` - Gets default values for numeric fields
- `sanitizeConfig()` - Validates and sanitizes configuration values
- `areConfigsEqual()` - Checks if two configurations are equal
- `getConfigSummary()` - Gets configuration summary for display

### `ui_utils.dart`
Contains common UI components and utilities.

**Key Methods:**
- `buildSectionHeader()` - Creates section header widget
- `buildValidationStatusCard()` - Creates validation status card
- `buildErrorMessage()` - Creates error message container
- `showSuccessSnackBar()` - Shows success snackbar
- `showValidationErrorSnackBar()` - Shows validation error snackbar
- `showConfirmationDialog()` - Shows confirmation dialog
- `showTextInputDialog()` - Shows text input dialog
- `buildLoadingButton()` - Creates loading button
- `buildTabInfoCard()` - Creates tab info card
- `formatDateTime()` - Formats DateTime for display
- `buildDropdownFormField()` - Creates dropdown form field with common styling
- `buildTextFormField()` - Creates text form field with common styling

### `utils.dart`
Barrel file that exports all utility classes for easier importing.

## Usage

### Import all utilities:
```dart
import '../utils/utils.dart';
```

### Import specific utilities:
```dart
import '../utils/validation_utils.dart';
import '../utils/config_utils.dart';
import '../utils/ui_utils.dart';
```

## Benefits

1. **Reusability** - Common functionality is centralized and can be reused across screens
2. **Maintainability** - Changes to validation or UI logic only need to be made in one place
3. **Consistency** - Ensures consistent behavior across the application
4. **Testability** - Utility functions can be easily unit tested
5. **Clean Code** - Reduces code duplication and improves readability

## Examples

### Using Validation Utils:
```dart
// Validate URL
final urlError = ValidationUtils.validateUrl(value, fieldName: 'Base URL');

// Check if config is valid
final isValid = ValidationUtils.isConfigValid(config);
```

### Using Config Utils:
```dart
// Create default config
final config = ConfigUtils.createDefaultConfig();

// Parse string keys
final keys = ConfigUtils.parseStringKeys('id, name, email');
```

### Using UI Utils:
```dart
// Show success message
UIUtils.showSuccessSnackBar(context, 'Configuration saved!');

// Build validation status card
UIUtils.buildValidationStatusCard(
  isValid: isValid,
  validationErrors: errors,
);
```
