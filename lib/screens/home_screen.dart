import 'package:flutter/material.dart';
import 'config_screen.dart';
import 'processing_screen.dart';
import 'history_screen.dart';
import 'folder_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ConfigScreen(),
    const ProcessingScreen(),
    const HistoryScreen(),
    const FolderManagementScreen(),
  ];

  final List<String> _titles = [
    'Configuration',
    'Processing',
    'History',
    'Folders',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Processing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Folders',
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'API Utility Flutter',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.api, size: 48),
      children: [
        const Text(
          'A powerful Flutter tool for processing CSV/Excel data through API calls.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• CSV/Excel file processing'),
        const Text('• Multiple authentication methods'),
        const Text('• Rate limiting and retry mechanisms'),
        const Text('• Batch processing with progress tracking'),
        const Text('• Real-time result monitoring'),
      ],
    );
  }
}
