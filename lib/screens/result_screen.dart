import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/result.dart';

class ResultScreen extends StatefulWidget {
  final List<ApiResult> results;

  const ResultScreen({super.key, required this.results});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ApiResult> _getFilteredResults(List<ApiResult> baseResults) {
    var filtered = baseResults;

    // Filter by status
    if (_filterStatus != 'all') {
      filtered = filtered
          .where((result) => result.status == _filterStatus)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((result) {
        final searchLower = _searchQuery.toLowerCase();

        // Search in response data
        if (result.response != null) {
          final responseStr = result.response.toString().toLowerCase();
          if (responseStr.contains(searchLower)) return true;
        }

        // Search in error messages
        if (result.pesanErrorSistem != null) {
          if (result.pesanErrorSistem!.toLowerCase().contains(searchLower))
            return true;
        }

        if (result.pesanErrorAPI != null) {
          if (result.pesanErrorAPI!.toLowerCase().contains(searchLower))
            return true;
        }

        // Search in failed data
        if (result.dataGagal != null) {
          final dataStr = result.dataGagal.toString().toLowerCase();
          if (dataStr.contains(searchLower)) return true;
        }

        return false;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final successCount = widget.results.where((r) => r.isSuccess).length;
    final errorCount = widget.results.where((r) => r.isError).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All (${widget.results.length})',
              icon: const Icon(Icons.list),
            ),
            Tab(
              text: 'Success ($successCount)',
              icon: const Icon(Icons.check_circle),
            ),
            Tab(text: 'Errors ($errorCount)', icon: const Icon(Icons.error)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty || _filterStatus != 'all') ...[
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
                  if (_filterStatus != 'all') ...[
                    Chip(
                      label: Text('Status: $_filterStatus'),
                      onDeleted: () {
                        setState(() {
                          _filterStatus = 'all';
                        });
                      },
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterStatus = 'all';
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResultsList(widget.results),
                _buildResultsList(
                  widget.results.where((r) => r.isSuccess).toList(),
                ),
                _buildResultsList(
                  widget.results.where((r) => r.isError).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<ApiResult> results) {
    final filteredResults = _getFilteredResults(results);

    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
            ),
            if (_searchQuery.isNotEmpty || _filterStatus != 'all') ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filter criteria',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(ApiResult result, int index) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
          child: Icon(
            result.isSuccess ? Icons.check : Icons.error,
            color: Colors.white,
          ),
        ),
        title: Text('Result #${index + 1}'),
        subtitle: Text(
          result.isSuccess ? 'Success' : 'Error: ${result.pesanErrorSistem}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.isSuccess && result.response != null) ...[
                  _buildSectionHeader('Response'),
                  _buildJsonView(result.response!),
                ],
                if (result.isError) ...[
                  if (result.dataGagal != null) ...[
                    _buildSectionHeader('Failed Data'),
                    _buildJsonView(result.dataGagal!),
                  ],
                  if (result.pesanErrorSistem != null) ...[
                    _buildSectionHeader('System Error'),
                    _buildTextContent(result.pesanErrorSistem!),
                  ],
                  if (result.pesanErrorAPI != null) ...[
                    _buildSectionHeader('API Error'),
                    _buildTextContent(result.pesanErrorAPI!),
                  ],
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(result),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildJsonView(Map<String, dynamic> json) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          _formatJson(json),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTextContent(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  void _copyToClipboard(ApiResult result) {
    final json = result.toJson();
    final jsonString = _formatJson(json);

    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Result copied to clipboard')));
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Results'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'success', child: Text('Success')),
                DropdownMenuItem(value: 'error', child: Text('Error')),
              ],
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                });
                Navigator.of(context).pop();
              },
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
}
