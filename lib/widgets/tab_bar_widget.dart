import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_app_provider.dart';
import '../models/tab.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
        final tabManager = provider.tabManager;
        if (!tabManager.hasTabs) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabManager.tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabManager.tabs[index];
                    final isActive = tab.id == tabManager.activeTabId;
                    
                    return _buildTab(context, tab, isActive, provider);
                  },
                ),
              ),
              _buildAddTabButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, TabData tab, bool isActive, TabAppProvider provider) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      child: Material(
        color: isActive 
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        child: InkWell(
          onTap: () => provider.switchToTab(tab.id),
          onSecondaryTap: () => _showTabContextMenu(context, tab, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tab icon
                Icon(
                  Icons.api,
                  size: 16,
                  color: isActive 
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                
                // Tab title
                Expanded(
                  child: Text(
                    tab.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Close button
                if (provider.tabManager.tabs.length > 1) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => provider.closeTab(tab.id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTabButton(BuildContext context, TabAppProvider provider) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.addNewTab(),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showTabContextMenu(BuildContext context, TabData tab, TabAppProvider provider) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy, size: 18),
              SizedBox(width: 8),
              Text('Duplicate'),
            ],
          ),
        ),
        if (provider.tabManager.tabs.length > 1)
          const PopupMenuItem(
            value: 'close',
            child: Row(
              children: [
                Icon(Icons.close, size: 18),
                SizedBox(width: 8),
                Text('Close'),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context, tab, provider);
            break;
          case 'duplicate':
            provider.duplicateTab(tab.id);
            break;
          case 'close':
            provider.closeTab(tab.id);
            break;
        }
      }
    });
  }

  void _showRenameDialog(BuildContext context, TabData tab, TabAppProvider provider) {
    final controller = TextEditingController(text: tab.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Tab'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tab Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != tab.title) {
                provider.updateTabTitle(tab.id, newTitle);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
