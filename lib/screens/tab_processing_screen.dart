import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/tab_app_provider.dart';
import '../services/file_service.dart';
import '../utils/utils.dart';
import 'result_screen.dart';

class TabProcessingScreen extends StatefulWidget {
  const TabProcessingScreen({super.key});

  @override
  State<TabProcessingScreen> createState() => _TabProcessingScreenState();
}

class _TabProcessingScreenState extends State<TabProcessingScreen> {
  final FileService _fileService = FileService.instance;
  int? _testRows;

  @override
  Widget build(BuildContext context) {
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTabInfo(provider),
              const SizedBox(height: 16),
              _buildValidationStatus(provider),
              const SizedBox(height: 24),
              _buildFileSelectionSection(provider),
              const SizedBox(height: 24),
              _buildTestModeSection(),
              const SizedBox(height: 24),
              _buildActionButtons(provider),
              const SizedBox(height: 24),
              if (provider.isProcessing) _buildProgressSection(provider),
              if (provider.error != null) _buildErrorSection(provider),
              if (provider.lastResult != null) _buildResultSummary(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabInfo(TabAppProvider provider) {
    final currentTab = provider.currentTab;
    if (currentTab == null) return const SizedBox.shrink();

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.tab,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Processing for: ${currentTab.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    'API: ${currentTab.config.baseUrl}${currentTab.config.endpointPath}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (currentTab.config.isValid)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              )
            else
              Icon(
                Icons.error,
                color: Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
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

  Widget _buildFileSelectionSection(TabAppProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input File',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (provider.currentSelectedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileService.getFileName(
                              provider.currentSelectedFilePath!,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            provider.currentSelectedFilePath!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => provider.setCurrentTabFilePath(null),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_upload, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('No file selected')),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: provider.isProcessing ? null : _selectFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select CSV/Excel File'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestModeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Mode',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Process only a limited number of rows for testing purposes.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Number of rows (leave empty for all)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _testRows = value.isEmpty ? null : int.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                if (_testRows != null)
                  Chip(
                    label: Text('Test Mode: $_testRows rows'),
                    backgroundColor: Colors.orange.shade100,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(TabAppProvider provider) {
    final canProcess =
        provider.currentSelectedFilePath != null &&
        !provider.isProcessing &&
        provider.currentConfig.isValid;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canProcess ? () => _startProcessing(provider) : null,
            icon: provider.isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              provider.isProcessing ? 'Processing...' : 'Start Processing',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        if (provider.isProcessing) ...[
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => provider.cancelProcessing(),
              icon: const Icon(Icons.stop),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(TabAppProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processing Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: provider.progressStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SpinKitWave(color: Colors.blue, size: 30.0),
                  );
                }

                final progress = snapshot.data!;
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.percentage / 100,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(progress.message),
                        Text('${progress.percentage.toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.processedRows} / ${progress.totalRows} rows processed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(TabAppProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.clearError,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary(TabAppProvider provider) {
    final result = provider.lastResult!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Processing ${result.success ? 'Completed' : 'Failed'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: result.success
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result.success) ...[
              _buildStatCard(
                'Total Rows',
                result.totalRows.toString(),
                Icons.list,
              ),
              const SizedBox(height: 8),
              _buildStatCard(
                'Successful',
                result.successCount.toString(),
                Icons.check,
              ),
              const SizedBox(height: 8),
              _buildStatCard(
                'Failed',
                result.errorCount.toString(),
                Icons.error,
              ),
              const SizedBox(height: 8),
              _buildStatCard(
                'Success Rate',
                '${(result.successRate * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
              ),
              if (result.outputPath != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.file_download, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Results saved to:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              result.outputPath!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewResults(provider),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Results'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _exportResults(provider),
                        icon: const Icon(Icons.download),
                        label: const Text('Export Results'),
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Text('Error: ${result.error}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final filePath = await _fileService.pickFile();
      if (filePath != null && mounted) {
        context.read<TabAppProvider>().setCurrentTabFilePath(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to select file: $e')));
      }
    }
  }

  Future<void> _startProcessing(TabAppProvider provider) async {
    // Check if configuration is valid before processing
    if (!provider.currentConfig.isValid) {
      final validationErrors = ValidationUtils.getConfigValidationErrors(provider.currentConfig);
      UIUtils.showValidationErrorSnackBar(context, validationErrors);
      return;
    }

    try {
      await provider.processCurrentTabData(testRows: _testRows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Processing failed: $e')));
      }
    }
  }


  void _viewResults(TabAppProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(results: provider.lastResult!.results),
      ),
    );
  }

  Future<void> _exportResults(TabAppProvider provider) async {
    try {
      final result = provider.lastResult!;
      if (result.outputPath != null) {
        // Show a dialog with the file path and copy option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Results have been saved to:'),
                const SizedBox(height: 8),
                SelectableText(
                  result.outputPath!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You can find this file in your device\'s documents folder.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No results to export')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
