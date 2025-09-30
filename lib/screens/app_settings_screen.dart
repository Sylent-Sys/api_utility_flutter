import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../services/file_service.dart';
import '../providers/tab_app_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/update_provider.dart';
import '../widgets/update_dialog.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pengaturan Aplikasi'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveSettings(settingsProvider),
                tooltip: 'Simpan Pengaturan',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabSettingsSection(settingsProvider),
                const SizedBox(height: 24),
                _buildDisplaySettingsSection(settingsProvider),
                const SizedBox(height: 24),
                _buildUpdateSettingsSection(),
                const SizedBox(height: 24),
                _buildBehaviorSettingsSection(settingsProvider),
                const SizedBox(height: 24),
                _buildTabPreviewSection(settingsProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSettingsSection(AppSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tab,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengaturan Tab',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Aktifkan Tab Wrap'),
              subtitle: const Text('Menampilkan tab dalam beberapa baris jika diperlukan'),
              value: settingsProvider.tabWrapEnabled,
              onChanged: (value) {
                settingsProvider.setTabWrapEnabled(value);
                settingsProvider.save();
              },
            ),
            SwitchListTile(
              title: const Text('Tampilkan Nomor Tab'),
              subtitle: const Text('Menampilkan nomor urut pada setiap tab'),
              value: settingsProvider.showTabNumbers,
              onChanged: (value) {
                settingsProvider.setShowTabNumbers(value);
                settingsProvider.save();
              },
            ),
            SwitchListTile(
              title: const Text('Auto Save Tab'),
              subtitle: const Text('Menyimpan perubahan tab secara otomatis'),
              value: settingsProvider.autoSaveTabs,
              onChanged: (value) {
                settingsProvider.setAutoSaveTabs(value);
                context.read<TabAppProvider>().setAutoSaveTabs(value);
                settingsProvider.save();
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Maksimal Tab per Baris: ${settingsProvider.maxTabsPerRow}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: settingsProvider.maxTabsPerRow.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: settingsProvider.maxTabsPerRow.toString(),
              onChanged: (value) {
                settingsProvider.setMaxTabsPerRow(value.round());
                settingsProvider.save();
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tinggi Tab: ${settingsProvider.tabHeight.round()}px',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: settingsProvider.tabHeight,
              min: 40.0,
              max: 80.0,
              divisions: 20,
              label: '${settingsProvider.tabHeight.round()}px',
              onChanged: (value) {
                settingsProvider.setTabHeight(value);
                settingsProvider.save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySettingsSection(AppSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengaturan Tampilan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Tema Aplikasi'),
              subtitle: const Text('Pilih tema yang sesuai'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showThemeDialog,
            ),
            ListTile(
              leading: const Icon(Icons.font_download),
              title: const Text('Ukuran Font'),
              subtitle: const Text('Sesuaikan ukuran font aplikasi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showFontSizeDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSettingsSection() {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.system_update,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Auto Update',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<bool>(
                  future: updateProvider.isAutoCheckEnabled(),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? true;
                    return SwitchListTile(
                      title: const Text('Cek Update Otomatis'),
                      subtitle: const Text('Periksa update secara berkala'),
                      value: isEnabled,
                      onChanged: (value) async {
                        await updateProvider.setAutoCheckEnabled(value);
                      },
                    );
                  },
                ),
                FutureBuilder<int>(
                  future: updateProvider.getCheckIntervalHours(),
                  builder: (context, snapshot) {
                    final hours = snapshot.data ?? 24;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Interval Cek Update: $hours jam',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Slider(
                          value: hours.toDouble(),
                          min: 1,
                          max: 168, // 1 week
                          divisions: 11,
                          label: '$hours jam',
                          onChanged: (value) async {
                            await updateProvider.setCheckIntervalHours(value.round());
                          },
                        ),
                      ],
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('Versi Saat Ini: ${updateProvider.currentVersion}'),
                  subtitle: updateProvider.hasUpdate
                      ? Text('Update tersedia: ${updateProvider.availableUpdate?.version}')
                      : const Text('Aplikasi sudah versi terbaru'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: updateProvider.isChecking
                        ? null
                        : () async {
                            await updateProvider.checkForUpdates();
                            if (updateProvider.hasUpdate && mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => const UpdateDialog(),
                              );
                            } else if (!updateProvider.hasUpdate && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Aplikasi sudah versi terbaru'),
                                ),
                              );
                            }
                          },
                    icon: updateProvider.isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(updateProvider.isChecking ? 'Memeriksa...' : 'Cek Update'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBehaviorSettingsSection(AppSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pengaturan Perilaku',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup & Restore'),
              subtitle: const Text('Kelola backup konfigurasi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showBackupDialog,
            ),
            SwitchListTile(
              title: const Text('Sertakan Output pada Backup'),
              subtitle: const Text('Menyertakan folder output (bisa besar)'),
              value: settingsProvider.includeOutputInBackup,
              onChanged: (value) {
                settingsProvider.setIncludeOutputInBackup(value);
                settingsProvider.save();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Reset Pengaturan'),
              subtitle: const Text('Kembalikan ke pengaturan default'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showResetDialog(settingsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPreviewSection(AppSettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preview Tab Layout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildTabPreview(settingsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPreview(AppSettingsProvider settingsProvider) {
    // Simulasi tab untuk preview
    final List<String> sampleTabs = [
      'Tab 1', 'Tab 2', 'Tab 3', 'Tab 4', 'Tab 5', 
      'Tab 6', 'Tab 7', 'Tab 8', 'Tab 9', 'Tab 10'
    ];

    if (settingsProvider.tabWrapEnabled) {
      return _buildWrappedTabPreview(sampleTabs, settingsProvider);
    } else {
      return _buildHorizontalTabPreview(sampleTabs, settingsProvider);
    }
  }

  Widget _buildWrappedTabPreview(List<String> tabs, AppSettingsProvider settingsProvider) {
    return Container(
      height: settingsProvider.tabHeight * 2, // Space for 2 rows
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tabs.take(settingsProvider.maxTabsPerRow * 2).map((tabName) {
          final index = tabs.indexOf(tabName);
          return Container(
            height: settingsProvider.tabHeight - 8,
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 200,
            ),
            child: Material(
              color: index == 0 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.api,
                      size: 14,
                      color: index == 0 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        settingsProvider.showTabNumbers ? '${index + 1}. $tabName' : tabName,
                        style: TextStyle(
                          fontSize: 12,
                          color: index == 0 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tabs.length > 1)
                      Icon(
                        Icons.close,
                        size: 12,
                        color: index == 0 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalTabPreview(List<String> tabs, AppSettingsProvider settingsProvider) {
    return Container(
      height: settingsProvider.tabHeight,
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return Container(
            height: settingsProvider.tabHeight - 8,
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: index == 0 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.api,
                      size: 14,
                      color: index == 0 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        settingsProvider.showTabNumbers ? '${index + 1}. ${tabs[index]}' : tabs[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: index == 0 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tabs.length > 1)
                      Icon(
                        Icons.close,
                        size: 12,
                        color: index == 0 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveSettings(AppSettingsProvider settingsProvider) async {
    try {
      await settingsProvider.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pengaturan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showThemeDialog() {
    final settings = context.read<AppSettingsProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Tema Terang'),
              trailing: settings.themeMode == 'light' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setThemeMode('light');
                settings.save();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Tema Gelap'),
              trailing: settings.themeMode == 'dark' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setThemeMode('dark');
                settings.save();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('Mengikuti Sistem'),
              trailing: settings.themeMode == 'system' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setThemeMode('system');
                settings.save();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    final settings = context.read<AppSettingsProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukuran Font'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kecil'),
              trailing: settings.fontSize == 'small' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setFontSize('small');
                settings.save();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Normal'),
              trailing: settings.fontSize == 'normal' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setFontSize('normal');
                settings.save();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Besar'),
              trailing: settings.fontSize == 'large' ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setFontSize('large');
                settings.save();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    final config = ConfigService.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Buat backup semua data konfigurasi, tab, history, output, dan pengaturan. Anda juga dapat me-restore dari file backup (.zip).'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final path = await config.createBackup();
                messenger.showSnackBar(
                  SnackBar(content: Text('Backup dibuat: $path')),
                );
                navigator.pop();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Gagal backup: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Buat Backup'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final settings = context.read<AppSettingsProvider>();
              final tabManager = context.read<TabAppProvider>().tabManager;
              try {
                final path = await FileService.instance.pickFile(allowedExtensions: ['zip']);
                if (path == null) return;
                await config.restoreBackup(path);
                await settings.load();
                await tabManager.loadTabs();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Restore berhasil. Memuat ulang data...')),
                );
                navigator.pop();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Gagal restore: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Restore Backup'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(AppSettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text('Apakah Anda yakin ingin mengembalikan semua pengaturan ke default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings(settingsProvider);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetSettings(AppSettingsProvider settingsProvider) {
    settingsProvider.resetToDefaults();
    settingsProvider.save();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan telah direset ke default'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
