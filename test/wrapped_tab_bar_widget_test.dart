import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:api_utility_flutter/widgets/wrapped_tab_bar_widget.dart';
import 'package:api_utility_flutter/providers/tab_app_provider.dart';

void main() {
  Widget wrapWithProviders(Widget child, {TabAppProvider? provider}) {
    final p = provider ?? TabAppProvider();
    // Disable auto-save timers to avoid pending timers in tests
    p.setAutoSaveTabs(false);
    return ChangeNotifierProvider<TabAppProvider>.value(
      value: p,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('WrappedTabBarWidget renders tabs and add button', (tester) async {
    final provider = TabAppProvider();
    provider.setAutoSaveTabs(false);
    // Ensure at least two tabs for close button branch
    provider.addNewTab();

    // Enlarge test surface to reduce overflows
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      wrapWithProviders(
        const WrappedTabBarWidget(
          wrapEnabled: false,
          maxTabsPerRow: 5,
          tabHeight: 48,
          showTabNumbers: true,
        ),
        provider: provider,
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.api), findsWidgets);
  });

  testWidgets('WrappedTabBarWidget supports wrapped layout', (tester) async {
    final provider = TabAppProvider();
    provider.setAutoSaveTabs(false);
    // Create more than maxTabsPerRow tabs to trigger wrapping
    for (int i = 0; i < 7; i++) {
      provider.addNewTab();
    }

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      wrapWithProviders(
        const WrappedTabBarWidget(
          wrapEnabled: true,
          maxTabsPerRow: 5,
          tabHeight: 48,
          showTabNumbers: true,
        ),
        provider: provider,
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
  });
}


