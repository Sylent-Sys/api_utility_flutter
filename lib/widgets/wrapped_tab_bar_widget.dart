import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_app_provider.dart';
import '../providers/tab_manager.dart';
import '../models/tab.dart';

class WrappedTabBarWidget extends StatelessWidget {
  final bool wrapEnabled;
  final int maxTabsPerRow;
  final double tabHeight;
  final bool showTabNumbers;

  const WrappedTabBarWidget({
    super.key,
    this.wrapEnabled = false,
    this.maxTabsPerRow = 5,
    this.tabHeight = 48.0,
    this.showTabNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TabAppProvider>(
      builder: (context, provider, child) {
        final tabManager = provider.tabManager;
        if (!tabManager.hasTabs) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: (wrapEnabled && tabManager.tabs.length > maxTabsPerRow)
              ? _buildWrappedTabs(context, tabManager, provider)
              : _buildHorizontalTabs(context, tabManager, provider),
        );
      },
    );
  }

  Widget _buildWrappedTabs(BuildContext context, TabManager tabManager, TabAppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ..._buildTabWidgets(context, tabManager, provider),
          _buildAddTabButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildHorizontalTabs(BuildContext context, TabManager tabManager, TabAppProvider provider) {
    return SizedBox(
      height: tabHeight,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabManager.tabs.length,
              itemBuilder: (context, index) {
                final tab = tabManager.tabs[index];
                final isActive = tab.id == tabManager.activeTabId;
                
                return _buildTab(
                  context,
                  tab,
                  isActive,
                  provider,
                  isWrapped: false,
                  displayIndex: index + 1,
                );
              },
            ),
          ),
          _buildAddTabButton(context, provider),
        ],
      ),
    );
  }

  List<Widget> _buildTabWidgets(BuildContext context, TabManager tabManager, TabAppProvider provider) {
    return tabManager.tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isActive = tab.id == tabManager.activeTabId;
      return _buildTab(context, tab, isActive, provider, isWrapped: true, displayIndex: index + 1);
    }).toList();
  }

  Widget _buildTab(BuildContext context, TabData tab, bool isActive, TabAppProvider provider, {bool isWrapped = false, int? displayIndex}) {
    return Container(
      constraints: isWrapped
          ? const BoxConstraints.tightFor(width: 160)
          : const BoxConstraints(minWidth: 120, maxWidth: 200),
      child: Material(
        color: isActive 
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => provider.switchToTab(tab.id),
          onSecondaryTap: () => _showTabContextMenu(context, tab, provider),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: tabHeight - 8,
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
                Flexible(
                  child: Text(
                    _getDisplayTitle(tab, displayIndex: displayIndex),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      constraints: const BoxConstraints(minWidth: 32, maxWidth: 48),
      height: tabHeight - 8,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => provider.addNewTab(),
          borderRadius: BorderRadius.circular(4),
          child: Icon(
            Icons.add,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String _getDisplayTitle(TabData tab, {int? displayIndex}) {
    if (!showTabNumbers) {
      return tab.title;
    }
    final prefix = displayIndex != null ? '$displayIndex. ' : '';
    return '$prefix${tab.title}';
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
