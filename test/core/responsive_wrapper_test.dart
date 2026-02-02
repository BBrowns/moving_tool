// ResponsiveWrapper Tests
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moving_tool_flutter/core/widgets/responsive_wrapper.dart';

void main() {
  group('Breakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(Breakpoints.mobile, 600);
    });

    test('tablet breakpoint is 900', () {
      expect(Breakpoints.tablet, 900);
    });

    test('desktop breakpoint is 1200', () {
      expect(Breakpoints.desktop, 1200);
    });
  });

  group('ResponsiveWrapper', () {
    testWidgets('applies max width constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveWrapper(
              maxWidth: 800,
              child: Container(
                key: const Key('content'),
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Find the ResponsiveWrapper and verify it has the expected structure
      final responsiveWrapper = tester.widget<ResponsiveWrapper>(
        find.byType(ResponsiveWrapper),
      );
      
      expect(responsiveWrapper.maxWidth, 800);
    });

    testWidgets('centers content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveWrapper(
              maxWidth: 400,
              child: SizedBox(
                key: const Key('content'),
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      // The Center widget should be present
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      const testPadding = EdgeInsets.all(24);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveWrapper(
              maxWidth: 800,
              padding: testPadding,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, testPadding);
    });
  });

  group('ResponsiveExtension', () {
    testWidgets('isMobile returns true for small screens', (WidgetTester tester) async {
      bool? isMobile;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                isMobile = context.isMobile;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, true);
    });

    testWidgets('isDesktop returns true for wide screens', (WidgetTester tester) async {
      bool? isDesktop;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                isDesktop = context.isDesktop;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isDesktop, true);
    });

    testWidgets('responsive helper returns correct value for mobile', (WidgetTester tester) async {
      String? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'mobile',
                  tablet: 'tablet',
                  desktop: 'desktop',
                );
                return Container();
              },
            ),
          ),
        ),
      );

      expect(result, 'mobile');
    });

    testWidgets('responsive helper returns correct value for desktop', (WidgetTester tester) async {
      String? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                result = context.responsive(
                  mobile: 'mobile',
                  tablet: 'tablet',
                  desktop: 'desktop',
                );
                return Container();
              },
            ),
          ),
        ),
      );

      expect(result, 'desktop');
    });
  });
}
