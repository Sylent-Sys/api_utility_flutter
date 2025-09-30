import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tab_app_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/update_provider.dart';
import 'services/config_service.dart';
import 'screens/tab_home_screen.dart';
import 'services/folder_structure_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize folder structure
  try {
    await FolderStructureService.instance.initialize();
  } catch (e) {
    debugPrint('Warning: Failed to initialize folder structure: $e');
  }

  // Preload app settings to avoid theme flicker
  final settingsProvider = AppSettingsProvider();
  try {
    final json = await ConfigService.instance.loadAppSettings();
    if (json != null) {
      settingsProvider.fromJson(json);
    }
  } catch (_) {}

  runApp(ApiUtilityApp(initialSettings: settingsProvider));
}

class ApiUtilityApp extends StatelessWidget {
  final AppSettingsProvider initialSettings;
  const ApiUtilityApp({super.key, required this.initialSettings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TabAppProvider()),
        ChangeNotifierProvider.value(value: initialSettings),
        ChangeNotifierProvider(create: (context) => UpdateProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          final textScale = settings.fontSize == 'small'
              ? 0.9
              : settings.fontSize == 'large'
                  ? 1.1
                  : 1.0;

          ThemeData baseLight = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          );

          ThemeData baseDark = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          );

          final mode = settings.themeMode == 'dark'
              ? ThemeMode.dark
              : settings.themeMode == 'light'
                  ? ThemeMode.light
                  : ThemeMode.system;

          return MaterialApp(
            title: 'API Utility Flutter',
            theme: baseLight,
            darkTheme: baseDark,
            themeMode: mode,
            home: const TabHomeScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
