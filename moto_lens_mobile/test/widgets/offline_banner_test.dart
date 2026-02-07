import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:moto_lens_mobile/widgets/offline_banner.dart';
import 'package:moto_lens_mobile/providers/connectivity_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockConnectivityProvider mockProvider;

  setUp(() {
    mockProvider = MockConnectivityProvider();

    // Default: online, nothing to show
    when(() => mockProvider.isOnline).thenReturn(true);
    when(() => mockProvider.isSyncing).thenReturn(false);
    when(() => mockProvider.showBanner).thenReturn(false);
    when(() => mockProvider.pendingSyncCount).thenReturn(0);
  });

  Widget buildWidget({Widget? child}) {
    return MaterialApp(
      home: ChangeNotifierProvider<ConnectivityProvider>.value(
        value: mockProvider,
        child: Scaffold(
          body: child ?? const OfflineBannerWrapper(child: Text('Content')),
        ),
      ),
    );
  }

  // ===========================================================================
  // OfflineBanner
  // ===========================================================================

  group('OfflineBanner', () {
    testWidgets('hidden when online and not syncing', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Banner should not be visible
      expect(find.text("You're offline — showing cached data"), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });

    testWidgets('shows offline message when not connected', (tester) async {
      when(() => mockProvider.isOnline).thenReturn(false);
      when(() => mockProvider.showBanner).thenReturn(true);

      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 350)); // animation

      expect(find.text("You're offline — showing cached data"), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('shows syncing message when back online with pending items', (
      tester,
    ) async {
      when(() => mockProvider.isOnline).thenReturn(true);
      when(() => mockProvider.isSyncing).thenReturn(true);
      when(() => mockProvider.showBanner).thenReturn(true);
      when(() => mockProvider.pendingSyncCount).thenReturn(3);

      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Back online — syncing 3 items…'), findsOneWidget);
    });

    testWidgets('syncing message uses singular for 1 item', (tester) async {
      when(() => mockProvider.isOnline).thenReturn(true);
      when(() => mockProvider.isSyncing).thenReturn(true);
      when(() => mockProvider.showBanner).thenReturn(true);
      when(() => mockProvider.pendingSyncCount).thenReturn(1);

      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Back online — syncing 1 item…'), findsOneWidget);
    });

    testWidgets('syncing with 0 pending shows generic syncing message', (
      tester,
    ) async {
      when(() => mockProvider.isOnline).thenReturn(true);
      when(() => mockProvider.isSyncing).thenReturn(true);
      when(() => mockProvider.showBanner).thenReturn(true);
      when(() => mockProvider.pendingSyncCount).thenReturn(0);

      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Back online — syncing…'), findsOneWidget);
    });
  });

  // ===========================================================================
  // OfflineBannerWrapper
  // ===========================================================================

  group('OfflineBannerWrapper', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('child remains visible when banner is shown', (tester) async {
      when(() => mockProvider.isOnline).thenReturn(false);
      when(() => mockProvider.showBanner).thenReturn(true);

      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 350));

      // Both banner and content should be visible
      expect(find.text("You're offline — showing cached data"), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
