import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/config.dart';
import '../providers/app_provider.dart';
import '../utils/validation_utils.dart';
import '../utils/ui_utils.dart';
import '../utils/config_utils.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _baseUrlController;
  late TextEditingController _endpointPathController;
  late TextEditingController _tokenController;
  late TextEditingController _apiKeyController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _timeoutController;
  late TextEditingController _batchSizeController;
  late TextEditingController _rateLimitController;
  late TextEditingController _maxRetriesController;
  late TextEditingController _stringKeysController;

  String _authMethod = 'none';
  String _requestMethod = 'GET';
  bool _didInitialSync = false;
  Timer? _autoSaveDebounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final config = context.read<AppProvider>().config;

    _baseUrlController = TextEditingController(text: config.baseUrl);
    _endpointPathController = TextEditingController(text: config.endpointPath);
    _tokenController = TextEditingController(text: config.token);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _usernameController = TextEditingController(text: config.username);
    _passwordController = TextEditingController(text: config.password);
    _timeoutController = TextEditingController(
      text: config.timeoutSec.toString(),
    );
    _batchSizeController = TextEditingController(
      text: config.batchSize.toString(),
    );
    _rateLimitController = TextEditingController(
      text: config.rateLimitSecond.toString(),
    );
    _maxRetriesController = TextEditingController(
      text: config.maxRetries.toString(),
    );
    _stringKeysController = TextEditingController(
      text: config.stringKeys.join(', '),
    );

    _authMethod = config.authMethod;
    _requestMethod = config.requestMethod;
  }

  void _setControllerText(TextEditingController controller, String newText) {
    if (controller.text == newText) return;
    final collapsedAtEnd = TextSelection.collapsed(offset: newText.length);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: collapsedAtEnd,
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _autoSaveDebounceTimer?.cancel();
    _baseUrlController.dispose();
    _endpointPathController.dispose();
    _tokenController.dispose();
    _apiKeyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _timeoutController.dispose();
    _batchSizeController.dispose();
    _rateLimitController.dispose();
    _maxRetriesController.dispose();
    _stringKeysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!_didInitialSync && !provider.isLoading) {
          _syncFromProvider(provider.config);
          _didInitialSync = true;
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('API Configuration'),
                _buildUrlSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Authentication'),
                _buildAuthSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Processing Settings'),
                _buildProcessingSection(),
                const SizedBox(height: 24),
                _buildActionButtons(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncFromProvider(ApiConfig config) {
    _setControllerText(_baseUrlController, config.baseUrl);
    _setControllerText(_endpointPathController, config.endpointPath);
    _setControllerText(_tokenController, config.token);
    _setControllerText(_apiKeyController, config.apiKey);
    _setControllerText(_usernameController, config.username);
    _setControllerText(_passwordController, config.password);
    _setControllerText(_timeoutController, config.timeoutSec.toString());
    _setControllerText(_batchSizeController, config.batchSize.toString());
    _setControllerText(_rateLimitController, config.rateLimitSecond.toString());
    _setControllerText(_maxRetriesController, config.maxRetries.toString());
    _setControllerText(
      _stringKeysController,
      config.stringKeys.join(', '),
    );

    _authMethod = config.authMethod;
    _requestMethod = config.requestMethod;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUrlSection() {
    return Column(
      children: [
        TextFormField(
          controller: _baseUrlController,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'http://localhost:7071/api',
            border: OutlineInputBorder(),
          ),
          validator: (value) => ValidationUtils.validateUrl(value, fieldName: 'Base URL'),
          onChanged: (value) => _autoSaveConfig(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _endpointPathController,
          decoration: const InputDecoration(
            labelText: 'Endpoint Path',
            hintText: '/FYP/Bengkel/AttendanceMonitoring/Create',
            border: OutlineInputBorder(),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, fieldName: 'Endpoint path'),
          onChanged: (value) => _autoSaveConfig(),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _requestMethod,
          decoration: const InputDecoration(
            labelText: 'Request Method',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'GET', child: Text('GET')),
            DropdownMenuItem(value: 'POST', child: Text('POST')),
          ],
          onChanged: (value) {
            setState(() {
              _requestMethod = value!;
            });
            _autoSaveConfig();
          },
        ),
      ],
    );
  }

  Widget _buildAuthSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _authMethod,
          decoration: const InputDecoration(
            labelText: 'Authentication Method',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'bearer', child: Text('Bearer Token')),
            DropdownMenuItem(value: 'api_key', child: Text('API Key')),
            DropdownMenuItem(value: 'basic', child: Text('Basic Auth')),
            DropdownMenuItem(value: 'none', child: Text('None')),
          ],
          onChanged: (value) {
            setState(() {
              _authMethod = value!;
            });
            _autoSaveConfig();
          },
        ),
        const SizedBox(height: 16),
        if (_authMethod == 'bearer') ...[
          TextFormField(
            controller: _tokenController,
            decoration: const InputDecoration(
              labelText: 'Bearer Token',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => ValidationUtils.validateAuthField(value, _authMethod, 'bearer'),
            onChanged: (value) => _autoSaveConfig(),
          ),
        ] else if (_authMethod == 'api_key') ...[
          TextFormField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => ValidationUtils.validateAuthField(value, _authMethod, 'api_key'),
            onChanged: (value) => _autoSaveConfig(),
          ),
        ] else if (_authMethod == 'basic') ...[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) => ValidationUtils.validateAuthField(value, _authMethod, 'basic'),
            onChanged: (value) => _autoSaveConfig(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) => ValidationUtils.validatePassword(value, _authMethod),
            onChanged: (value) => _autoSaveConfig(),
          ),
        ],
      ],
    );
  }

  Widget _buildProcessingSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _timeoutController,
                decoration: const InputDecoration(
                  labelText: 'Timeout (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validatePositiveInteger(value, fieldName: 'Timeout'),
                onChanged: (value) => _autoSaveConfig(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _batchSizeController,
                decoration: const InputDecoration(
                  labelText: 'Batch Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validatePositiveInteger(value, fieldName: 'Batch size'),
                onChanged: (value) => _autoSaveConfig(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rateLimitController,
                decoration: const InputDecoration(
                  labelText: 'Rate Limit (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => ValidationUtils.validateNonNegativeDouble(value, fieldName: 'Rate limit'),
                onChanged: (value) => _autoSaveConfig(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxRetriesController,
                decoration: const InputDecoration(
                  labelText: 'Max Retries',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validateNonNegativeInteger(value, fieldName: 'Max retries'),
                onChanged: (value) => _autoSaveConfig(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stringKeysController,
          decoration: const InputDecoration(
            labelText: 'String Fields (comma-separated)',
            hintText: 'id, name, email',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _autoSaveConfig(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _saveConfig,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Configuration'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.isLoading ? null : _resetConfig,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Default'),
              ),
            ),
          ],
        ),
        if (provider.error != null) ...[
          const SizedBox(height: 16),
          Container(
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
                    provider.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: provider.clearError,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _saveConfig() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = _buildConfigFromForm();
    
    // Check for validation errors
    final validationErrors = ValidationUtils.getConfigValidationErrors(config);
    if (validationErrors.isNotEmpty) {
      UIUtils.showValidationErrorSnackBar(context, validationErrors);
      return;
    }

    // Show success message
    UIUtils.showSuccessSnackBar(context, 'Configuration saved successfully!');

    context.read<AppProvider>().saveConfig(config);
  }

  /// Auto-save configuration when form fields change
  void _autoSaveConfig() {
    _autoSaveDebounceTimer?.cancel();
    _autoSaveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final config = _buildConfigFromForm();
      final validationErrors = ValidationUtils.getConfigValidationErrors(config);
      if (validationErrors.isEmpty) {
        context.read<AppProvider>().saveConfig(config);
      }
    });
  }

  /// Builds ApiConfig from current form values
  ApiConfig _buildConfigFromForm() {
    return ApiConfig(
      baseUrl: _baseUrlController.text.trim(),
      endpointPath: _endpointPathController.text.trim(),
      token: _tokenController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      timeoutSec: int.tryParse(_timeoutController.text) ?? 240,
      batchSize: int.tryParse(_batchSizeController.text) ?? 10,
      rateLimitSecond: double.tryParse(_rateLimitController.text) ?? 0.5,
      maxRetries: int.tryParse(_maxRetriesController.text) ?? 3,
      requestMethod: _requestMethod,
      authMethod: _authMethod,
      stringKeys: ConfigUtils.parseStringKeys(_stringKeysController.text),
    );
  }

  void _resetConfig() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Configuration'),
        content: const Text(
          'Are you sure you want to reset all configuration to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AppProvider>().resetConfig();
              _initializeControllers();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
