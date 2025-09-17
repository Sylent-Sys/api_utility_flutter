import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/config.dart';
import '../providers/app_provider.dart';

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

  String _authMethod = 'bearer';
  String _requestMethod = 'GET';

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
    _timeoutController = TextEditingController(text: config.timeoutSec.toString());
    _batchSizeController = TextEditingController(text: config.batchSize.toString());
    _rateLimitController = TextEditingController(text: config.rateLimitSecond.toString());
    _maxRetriesController = TextEditingController(text: config.maxRetries.toString());
    _stringKeysController = TextEditingController(text: config.stringKeys.join(', '));
    
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
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
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

  Widget _buildSectionHeader(String title) {
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Base URL is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _endpointPathController,
          decoration: const InputDecoration(
            labelText: 'Endpoint Path',
            hintText: '/FYP/Bengkel/AttendanceMonitoring/Create',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Endpoint path is required';
            }
            return null;
          },
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
            validator: (value) {
              if (_authMethod == 'bearer' && (value == null || value.isEmpty)) {
                return 'Token is required for Bearer authentication';
              }
              return null;
            },
          ),
        ] else if (_authMethod == 'api_key') ...[
          TextFormField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (_authMethod == 'api_key' && (value == null || value.isEmpty)) {
                return 'API Key is required for API Key authentication';
              }
              return null;
            },
          ),
        ] else if (_authMethod == 'basic') ...[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_authMethod == 'basic' && (value == null || value.isEmpty)) {
                return 'Username is required for Basic authentication';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (_authMethod == 'basic' && (value == null || value.isEmpty)) {
                return 'Password is required for Basic authentication';
              }
              return null;
            },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Timeout is required';
                  }
                  final timeout = int.tryParse(value);
                  if (timeout == null || timeout <= 0) {
                    return 'Timeout must be a positive number';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Batch size is required';
                  }
                  final batchSize = int.tryParse(value);
                  if (batchSize == null || batchSize <= 0) {
                    return 'Batch size must be a positive number';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rate limit is required';
                  }
                  final rateLimit = double.tryParse(value);
                  if (rateLimit == null || rateLimit < 0) {
                    return 'Rate limit must be a non-negative number';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Max retries is required';
                  }
                  final maxRetries = int.tryParse(value);
                  if (maxRetries == null || maxRetries < 0) {
                    return 'Max retries must be a non-negative number';
                  }
                  return null;
                },
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

    final config = ApiConfig(
      baseUrl: _baseUrlController.text.trim(),
      endpointPath: _endpointPathController.text.trim(),
      token: _tokenController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      timeoutSec: int.parse(_timeoutController.text),
      batchSize: int.parse(_batchSizeController.text),
      rateLimitSecond: double.parse(_rateLimitController.text),
      maxRetries: int.parse(_maxRetriesController.text),
      requestMethod: _requestMethod,
      authMethod: _authMethod,
      stringKeys: _stringKeysController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );

    context.read<AppProvider>().saveConfig(config);
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
