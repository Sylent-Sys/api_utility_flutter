import 'package:flutter/material.dart';

/// Utility class for common UI operations and widgets
class UIUtils {
  /// Creates a section header widget
  static Widget buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Creates a validation status card
  static Widget buildValidationStatusCard({
    required bool isValid,
    required List<String> validationErrors,
  }) {
    return Card(
      color: isValid ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green.shade700 : Colors.red.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isValid ? 'Configuration Valid' : 'Configuration Invalid',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 4),
                    ...validationErrors.map((error) => Text(
                      '• $error',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    )),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'All required fields are properly configured',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an error message container
  static Widget buildErrorMessage({
    required String message,
    required VoidCallback onDismiss,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  /// Creates a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Creates an error snackbar with validation errors
  static void showValidationErrorSnackBar(
    BuildContext context,
    List<String> validationErrors,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration has validation errors:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...validationErrors.map((error) => Text('• $error')),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Creates a confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Creates a text input dialog
  static Future<String?> showTextInputDialog({
    required BuildContext context,
    required String title,
    required String labelText,
    String? initialValue,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    final controller = TextEditingController(text: initialValue);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.of(context).pop(value.isNotEmpty ? value : null);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Creates a loading button
  static Widget buildLoadingButton({
    required VoidCallback? onPressed,
    required String label,
    required bool isLoading,
    IconData? icon,
    ButtonStyle? style,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.save),
      label: Text(label),
      style: style,
    );
  }

  /// Creates a tab info card
  static Widget buildTabInfoCard({
    required BuildContext context,
    required String tabTitle,
    required String lastModified,
    required VoidCallback onEdit,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.tab,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Tab: $tabTitle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Last modified: $lastModified',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  /// Formats DateTime for display
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Creates a dropdown form field with common styling
  static Widget buildDropdownFormField<T>({
    required T? initialValue,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  /// Creates a text form field with common styling
  static Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
    );
  }
}
