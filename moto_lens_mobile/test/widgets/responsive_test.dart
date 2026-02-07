import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:moto_lens_mobile/providers/connectivity_provider.dart';
import 'package:moto_lens_mobile/widgets/offline_banner.dart';

import '../helpers/test_helpers.dart';

/// Simulated responsive content widget for testing layout behavior
/// across different screen sizes. Since the real screens have complex
/// dependencies (cameras, platform channels), we test the responsive
/// principles with a representative widget.
class _ResponsiveTestWidget extends StatelessWidget {
  const _ResponsiveTestWidget();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 360;
    final isMedium = size.width >= 360 && size.width < 600;
    final isTablet = size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // App bar area
        Container(
          height: 56,
          color: const Color(0xFF0A0A0A), // Carbon Black
          alignment: Alignment.center,
          child: Text(
            'MotoLens',
            key: const Key('app_title'),
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 24 : 18,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : (isMedium ? 16 : 8)),
            child: Column(
              children: [
                // VIN input field — must be at least 44px tall (touch target)
                SizedBox(
                  height: isCompact ? 44 : 48,
                  child: const TextField(
                    key: Key('vin_input'),
                    decoration: InputDecoration(
                      hintText: 'Enter VIN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action button — minimum 44x44 touch target
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('decode_button'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9), // Electric Blue
                    ),
                    child: Text(
                      'Decode VIN',
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),

                // Layout indicator for test assertions
                Text(
                  isTablet
                      ? 'tablet_layout'
                      : isMedium
                      ? 'medium_layout'
                      : 'compact_layout',
                  key: const Key('layout_indicator'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  late MockConnectivityProvider mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivityProvider();
    when(() => mockConnectivity.isOnline).thenReturn(true);
    when(() => mockConnectivity.isSyncing).thenReturn(false);
    when(() => mockConnectivity.showBanner).thenReturn(false);
    when(() => mockConnectivity.pendingSyncCount).thenReturn(0);
  });

  Widget buildResponsiveWidget({required Size size}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: ChangeNotifierProvider<ConnectivityProvider>.value(
          value: mockConnectivity,
          child: const Scaffold(
            body: OfflineBannerWrapper(child: _ResponsiveTestWidget()),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Android Screen Sizes
  // ===========================================================================

  group('Android Screen Sizes', () {
    testWidgets('renders on small phone (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(320, 568)),
      );

      expect(find.byKey(const Key('vin_input')), findsOneWidget);
      expect(find.byKey(const Key('decode_button')), findsOneWidget);
      expect(find.text('compact_layout'), findsOneWidget);
    });

    testWidgets('renders on medium phone (375x812 — iPhone X size)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(375, 812)),
      );

      expect(find.byKey(const Key('vin_input')), findsOneWidget);
      expect(find.text('medium_layout'), findsOneWidget);
    });

    testWidgets('renders on large phone (414x896)', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(414, 896)),
      );

      expect(find.byKey(const Key('vin_input')), findsOneWidget);
      expect(find.text('medium_layout'), findsOneWidget);
    });

    testWidgets('renders on tablet (768x1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(768, 1024)),
      );

      expect(find.byKey(const Key('vin_input')), findsOneWidget);
      expect(find.text('tablet_layout'), findsOneWidget);
    });
  });

  // ===========================================================================
  // iOS Sizes (if available)
  // ===========================================================================

  group('iOS Screen Sizes', () {
    testWidgets('renders on iPhone SE (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(320, 568)),
      );

      expect(find.byKey(const Key('vin_input')), findsOneWidget);
    });

    testWidgets('renders on iPad (1024x1366)', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(1024, 1366)),
      );

      expect(find.text('tablet_layout'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Touch Target Requirements
  // ===========================================================================

  group('Touch Target Requirements', () {
    testWidgets('VIN input field meets 44px minimum height', (tester) async {
      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(375, 812)),
      );

      final inputFinder = find.byKey(const Key('vin_input'));
      expect(inputFinder, findsOneWidget);

      final inputBox = tester.getSize(inputFinder);
      expect(inputBox.height, greaterThanOrEqualTo(44));
    });

    testWidgets('Decode button meets 44px minimum height', (tester) async {
      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(375, 812)),
      );

      final buttonFinder = find.byKey(const Key('decode_button'));
      expect(buttonFinder, findsOneWidget);

      final buttonBox = tester.getSize(buttonFinder);
      expect(buttonBox.height, greaterThanOrEqualTo(44));
    });
  });

  // ===========================================================================
  // Network Conditions (offline banner at different sizes)
  // ===========================================================================

  group('Network Conditions', () {
    testWidgets('offline banner visible on small phone', (tester) async {
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(() => mockConnectivity.showBanner).thenReturn(true);

      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(320, 568)),
      );
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text("You're offline — showing cached data"), findsOneWidget);
    });

    testWidgets('offline banner visible on tablet', (tester) async {
      when(() => mockConnectivity.isOnline).thenReturn(false);
      when(() => mockConnectivity.showBanner).thenReturn(true);

      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(768, 1024)),
      );
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text("You're offline — showing cached data"), findsOneWidget);
      // Content should still be visible below the banner
      expect(find.byKey(const Key('app_title')), findsOneWidget);
    });

    testWidgets('syncing banner visible on medium device', (tester) async {
      when(() => mockConnectivity.isOnline).thenReturn(true);
      when(() => mockConnectivity.isSyncing).thenReturn(true);
      when(() => mockConnectivity.showBanner).thenReturn(true);
      when(() => mockConnectivity.pendingSyncCount).thenReturn(5);

      await tester.pumpWidget(
        buildResponsiveWidget(size: const Size(375, 812)),
      );
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Back online — syncing 5 items…'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Text Scaling (Accessibility)
  // ===========================================================================

  group('Text Scaling', () {
    testWidgets('renders correctly with large text scale (1.5x)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              textScaler: TextScaler.linear(1.5),
            ),
            child: ChangeNotifierProvider<ConnectivityProvider>.value(
              value: mockConnectivity,
              child: const Scaffold(
                body: OfflineBannerWrapper(child: _ResponsiveTestWidget()),
              ),
            ),
          ),
        ),
      );

      // Should still render without overflow
      expect(find.byKey(const Key('vin_input')), findsOneWidget);
      expect(find.byKey(const Key('decode_button')), findsOneWidget);
    });
  });
}
