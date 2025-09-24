import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/config.dart';
import '../providers/tab_app_provider.dart';
import '../utils/utils.dart';

class TabConfigScreen extends StatefulWidget {
  const TabConfigScreen({super.key});

  @override
  State<TabConfigScreen> createState() => _TabConfigScreenState();
}

class _TabConfigScreenState extends State<TabConfigScreen> {
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final provider = context.read<TabAppProvider>();
    final config = provider.currentConfig;

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

  @override
  void dispose() {
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
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
        // Always sync with current tab's config when tab changes
        if (!provider.isLoading) {
          _syncFromProvider(provider.currentConfig);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTabInfo(provider),
                const SizedBox(height: 16),
                _buildValidationStatus(provider),
                const SizedBox(height: 16),
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

  Widget _buildTabInfo(TabAppProvider provider) {
    final currentTab = provider.currentTab;
    if (currentTab == null) return const SizedBox.shrink();

    return UIUtils.buildTabInfoCard(
      context: context,
      tabTitle: currentTab.title,
      lastModified: _formatDateTime(currentTab.lastModified),
      onEdit: () => _showRenameDialog(provider, currentTab.id),
    );
  }

  Widget _buildValidationStatus(TabAppProvider provider) {
    final config = provider.currentConfig;
    final validationErrors = ValidationUtils.getConfigValidationErrors(config);
    final isValid = validationErrors.isEmpty;

    return UIUtils.buildValidationStatusCard(
      isValid: isValid,
      validationErrors: validationErrors,
    );
  }


  void _syncFromProvider(ApiConfig config) {
    _baseUrlController.text = config.baseUrl;
    _endpointPathController.text = config.endpointPath;
    _tokenController.text = config.token;
    _apiKeyController.text = config.apiKey;
    _usernameController.text = config.username;
    _passwordController.text = config.password;
    _timeoutController.text = config.timeoutSec.toString();
    _batchSizeController.text = config.batchSize.toString();
    _rateLimitController.text = config.rateLimitSecond.toString();
    _maxRetriesController.text = config.maxRetries.toString();
    _stringKeysController.text = ConfigUtils.stringKeysToString(config.stringKeys);

    _authMethod = config.authMethod;
    _requestMethod = config.requestMethod;
  }

  Widget _buildSectionHeader(String title) {
    return UIUtils.buildSectionHeader(context, title);
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
          key: ValueKey('request_method_$_requestMethod'),
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
            // Update the provider's current config immediately
            final provider = context.read<TabAppProvider>();
            final currentConfig = provider.currentConfig;
            final updatedConfig = currentConfig.copyWith(requestMethod: value!);
            provider.saveCurrentTabConfig(updatedConfig);
          },
        ),
      ],
    );
  }

  Widget _buildAuthSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('auth_method_$_authMethod'),
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
            // Update the provider's current config immediately
            final provider = context.read<TabAppProvider>();
            final currentConfig = provider.currentConfig;
            final updatedConfig = currentConfig.copyWith(authMethod: value!);
            provider.saveCurrentTabConfig(updatedConfig);
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

  Widget _buildActionButtons(TabAppProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UIUtils.buildLoadingButton(
                onPressed: _saveConfig,
                label: 'Save Configuration',
                isLoading: provider.isLoading,
                icon: Icons.save,
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
          UIUtils.buildErrorMessage(
            message: provider.error!,
            onDismiss: provider.clearError,
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

    context.read<TabAppProvider>().saveCurrentTabConfig(config);
  }

  /// Auto-save configuration when form fields change
  void _autoSaveConfig() {
    final config = _buildConfigFromForm();
    
    // Only auto-save if the configuration is valid
    final validationErrors = ValidationUtils.getConfigValidationErrors(config);
    if (validationErrors.isEmpty) {
      context.read<TabAppProvider>().saveCurrentTabConfig(config);
    }
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

  void _resetConfig() async {
    final confirmed = await UIUtils.showConfirmationDialog(
      context: context,
      title: 'Reset Configuration',
      content: 'Are you sure you want to reset all configuration to default values for this tab?',
      confirmText: 'Reset',
      cancelText: 'Cancel',
    );
    
    if (confirmed == true && mounted) {
      context.read<TabAppProvider>().resetCurrentTabConfig();
      _initializeControllers();
    }
  }

  void _showRenameDialog(TabAppProvider provider, String tabId) async {
    final currentTab = provider.currentTab;
    if (currentTab == null) return;

    final newTitle = await UIUtils.showTextInputDialog(
      context: context,
      title: 'Rename Tab',
      labelText: 'Tab Name',
      initialValue: currentTab.title,
      confirmText: 'Rename',
      cancelText: 'Cancel',
    );
    
    if (newTitle != null && newTitle.isNotEmpty && newTitle != currentTab.title) {
      provider.updateTabTitle(tabId, newTitle);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return UIUtils.formatDateTime(dateTime);
  }
}
