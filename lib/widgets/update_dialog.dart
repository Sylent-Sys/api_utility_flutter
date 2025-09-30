import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/update_provider.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  String? _downloadedFilePath;

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        final update = updateProvider.availableUpdate;
        if (update == null) {
          return const SizedBox.shrink();
        }

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Update Available'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version ${update.version}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current version: ${updateProvider.currentVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (update.releaseNotes.isNotEmpty) ...[
                  Text(
                    'Release Notes:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        update.releaseNotes,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isDownloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: updateProvider.downloadProgress,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading... ${(updateProvider.downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (updateProvider.error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            updateProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isDownloading
                  ? null
                  : () {
                      updateProvider.dismissUpdate();
                      Navigator.of(context).pop();
                    },
              child: const Text('Later'),
            ),
            if (!_isDownloading && _downloadedFilePath == null)
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    _isDownloading = true;
                  });

                  final filePath = await updateProvider.downloadUpdate();

                  if (mounted) {
                    setState(() {
                      _isDownloading = false;
                      _downloadedFilePath = filePath;
                    });

                    if (filePath != null) {
                      _showInstallPrompt(context, updateProvider, filePath);
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            if (_downloadedFilePath != null)
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await updateProvider.installUpdate(_downloadedFilePath!);
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Update installer launched. Please complete the installation.'),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to launch update installer'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.install_desktop),
                label: const Text('Install'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showInstallPrompt(BuildContext context, UpdateProvider updateProvider, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Complete'),
        content: const Text(
          'The update has been downloaded successfully. Would you like to install it now?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await updateProvider.installUpdate(filePath);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Update installer launched. The app will restart to complete installation.'),
                    ),
                  );
                  // Close all dialogs
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to launch update installer'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Install Now'),
          ),
        ],
      ),
    );
  }
}
