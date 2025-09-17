import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/folder_structure_service.dart';

class FolderManagementScreen extends StatefulWidget {
  const FolderManagementScreen({super.key});

  @override
  State<FolderManagementScreen> createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  final FolderStructureService _folderService = FolderStructureService.instance;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _folderService.getAppStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load folder stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folder Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_stats == null) {
      return const Center(
        child: Text('Failed to load folder information'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppDirectoryCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildFolderStructureCard(),
          const SizedBox(height: 16),
          _buildActionsCard(),
        ],
      ),
    );
  }

  Widget _buildAppDirectoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Application Directory',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _stats!['appDirectory'],
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_stats!['appDirectory']),
                    tooltip: 'Copy Path',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All your configurations, outputs, and history are stored in this directory.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Storage Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Configuration Files', _stats!['configFiles'].toString()),
            _buildStatRow('Output Files', _stats!['outputFiles'].toString()),
            _buildStatRow('Total Size', _formatBytes(_stats!['totalSize'])),
            const Divider(),
            _buildStatRow('Config Size', _formatBytes(_stats!['totalConfigSize'])),
            _buildStatRow('Output Size', _formatBytes(_stats!['totalOutputSize'])),
            _buildStatRow('History Size', _formatBytes(_stats!['totalHistorySize'])),
            _buildStatRow('Temp Size', _formatBytes(_stats!['totalTempSize'])),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderStructureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Folder Structure',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFolderItem('📁 config/', 'API configurations and settings'),
            _buildFolderItem('📁 output/', 'Processing results organized by date'),
            _buildFolderItem('📁 history/', 'Complete processing history'),
            _buildFolderItem('📁 temp/', 'Temporary files (auto-cleaned)'),
            _buildFolderItem('📄 README.txt', 'Folder structure documentation'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Folder Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cleanTempFiles,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clean Temp Files'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cleanOldOutputFiles,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Clean Old Outputs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showCleanupDialog,
                icon: const Icon(Icons.warning),
                label: const Text('Advanced Cleanup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(String icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Path copied to clipboard')),
    );
  }

  Future<void> _cleanTempFiles() async {
    try {
      await _folderService.cleanTempFiles();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Temporary files cleaned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clean temp files: $e')),
        );
      }
    }
  }

  Future<void> _cleanOldOutputFiles() async {
    final days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Old Output Files'),
        content: const Text('Delete output files older than how many days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(30),
            child: const Text('30 days'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(90),
            child: const Text('90 days'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(365),
            child: const Text('1 year'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (days != null) {
      try {
        await _folderService.cleanOldOutputFiles(days);
        await _loadStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Files older than $days days cleaned successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clean old files: $e')),
          );
        }
      }
    }
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Cleanup'),
        content: const Text(
          'This will clean temporary files and old output files. '
          'Your configurations and recent history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cleanTempFiles();
              await _cleanOldOutputFiles();
            },
            child: const Text('Clean All'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
