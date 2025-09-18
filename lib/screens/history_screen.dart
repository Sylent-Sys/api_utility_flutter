import 'package:flutter/material.dart';
import '../models/processing_history.dart';
import '../services/history_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService.instance;
  List<ProcessingHistory> _history = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, oldest, success_rate, error_rate

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }


  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _historyService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load history: $e')));
      }
    }
  }

  List<ProcessingHistory> get _filteredHistory {
    var filtered = _history;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filtered = filtered.where((h) {
        return h.inputFileName.toLowerCase().contains(queryLower) ||
            h.configName.toLowerCase().contains(queryLower) ||
            h.outputPath.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'success_rate':
        filtered.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case 'error_rate':
        filtered.sort((a, b) => b.errorRate.compareTo(a.errorRate));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearHistoryDialog();
              } else if (value == 'stats') {
                _showStatsDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('View Statistics'),
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear History'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Processing History',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your processing results will appear here',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_searchQuery.isNotEmpty || _sortBy != 'newest') ...[
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                if (_searchQuery.isNotEmpty) ...[
                  Chip(
                    label: Text('Search: "$_searchQuery"'),
                    onDeleted: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                if (_sortBy != 'newest') ...[
                  Chip(
                    label: Text('Sort: ${_getSortLabel(_sortBy)}'),
                    onDeleted: () {
                      setState(() {
                        _sortBy = 'newest';
                      });
                    },
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _sortBy = 'newest';
                    });
                  },
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: _filteredHistory.length,
            itemBuilder: (context, index) {
              final history = _filteredHistory[index];
              return _buildHistoryCard(history);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(ProcessingHistory history) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: history.successRate > 0.8
              ? Colors.green
              : history.successRate > 0.5
              ? Colors.orange
              : Colors.red,
          child: Icon(
            history.isTestMode ? Icons.science : Icons.api,
            color: Colors.white,
          ),
        ),
        title: Text(
          history.inputFileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Config: ${history.configName}'),
            Text(
              '${history.totalRows} rows • ${history.successCount} success • ${history.errorCount} errors',
            ),
            Text('${history.formattedTimestamp} • ${history.duration}'),
            if (history.isTestMode)
              Chip(
                label: Text('Test Mode (${history.testRows} rows)'),
                backgroundColor: Colors.orange.shade100,
                labelStyle: const TextStyle(fontSize: 10),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _viewResults(history),
              tooltip: 'View Results',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteHistory(history),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _viewResults(history),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'Newest First';
      case 'oldest':
        return 'Oldest First';
      case 'success_rate':
        return 'Success Rate';
      case 'error_rate':
        return 'Error Rate';
      default:
        return 'Newest First';
    }
  }

  void _viewResults(ProcessingHistory history) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(results: history.results),
      ),
    );
  }

  Future<void> _deleteHistory(ProcessingHistory history) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: Text(
          'Are you sure you want to delete this processing history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.removeFromHistory(history.id);
        await _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('History deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete history: $e')),
          );
        }
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search History'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by filename, config, or path...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort History'),
        content: DropdownButtonFormField<String>(
          initialValue: _sortBy,
          decoration: const InputDecoration(
            labelText: 'Sort by',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest First')),
            DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
            DropdownMenuItem(
              value: 'success_rate',
              child: Text('Success Rate'),
            ),
            DropdownMenuItem(value: 'error_rate', child: Text('Error Rate')),
          ],
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearHistoryDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all processing history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clearHistory();
        await _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All history cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear history: $e')),
          );
        }
      }
    }
  }

  Future<void> _showStatsDialog() async {
    try {
      final stats = await _historyService.getHistoryStats();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('History Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  'Total Processings',
                  stats['totalProcessings']!.toString(),
                ),
                _buildStatRow(
                  'Total Rows Processed',
                  stats['totalRows']!.toString(),
                ),
                _buildStatRow(
                  'Total Successful',
                  stats['totalSuccess']!.toString(),
                ),
                _buildStatRow('Total Errors', stats['totalErrors']!.toString()),
                _buildStatRow(
                  'Test Mode Runs',
                  stats['testModeCount']!.toString(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Success Rate: ${((stats['totalSuccess']! / (stats['totalSuccess']! + stats['totalErrors']!)) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load statistics: $e')),
        );
      }
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
