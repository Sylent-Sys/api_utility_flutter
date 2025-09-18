import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_app_provider.dart';
import '../widgets/tab_bar_widget.dart';
import 'tab_config_screen.dart';
import 'tab_processing_screen.dart';
import 'history_screen.dart';
import 'folder_management_screen.dart';

class TabHomeScreen extends StatefulWidget {
  const TabHomeScreen({super.key});

  @override
  State<TabHomeScreen> createState() => _TabHomeScreenState();
}

class _TabHomeScreenState extends State<TabHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TabConfigScreen(),
    const TabProcessingScreen(),
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
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
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
          body: Column(
            children: [
              // Only show tabs for Configuration and Processing screens
              if (_selectedIndex == 0 || _selectedIndex == 1) 
                const TabBarWidget(),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
              ),
            ],
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
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'API Utility Flutter',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.api, size: 48),
      children: [
        const Text(
          'A powerful Flutter tool for processing CSV/Excel data through API calls with multi-tab support.',
        ),
        const SizedBox(height: 16),
        const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('• Multi-tab interface with independent configurations'),
        const Text('• CSV/Excel file processing'),
        const Text('• Multiple authentication methods'),
        const Text('• Rate limiting and retry mechanisms'),
        const Text('• Batch processing with progress tracking'),
        const Text('• Real-time result monitoring'),
        const Text('• Tab management (add, close, duplicate, rename)'),
      ],
    );
  }
}
