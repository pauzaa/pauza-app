import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  group('PauzaUserAvatar', () {
    testWidgets('renders with fallback icon when no imageUrl', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          home: const Scaffold(body: PauzaUserAvatar()),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('renders with fallback icon when imageUrl is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          home: const Scaffold(body: PauzaUserAvatar(imageUrl: '')),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('uses custom radius', (WidgetTester tester) async {
      const customRadius = 64.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          home: const Scaffold(body: PauzaUserAvatar(radius: customRadius)),
        ),
      );

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, customRadius);
    });

    testWidgets('applies border', (WidgetTester tester) async {
      const borderWidth = 4.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          home: const Scaffold(body: PauzaUserAvatar(borderWidth: borderWidth)),
        ),
      );

      final circleAvatarFinder = find.byType(CircleAvatar);
      final decoratedBoxFinder = find.ancestor(of: circleAvatarFinder, matching: find.byType(DecoratedBox));
      final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder.first);
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, borderWidth);
    });

    testWidgets('renders with imageUrl', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PauzaTheme.light,
          home: const Scaffold(body: PauzaUserAvatar(imageUrl: 'https://example.com/avatar.jpg')),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.foregroundImage, isNotNull);
      expect(avatar.foregroundImage.toString(), contains('CachedNetworkImageProvider'));
    });
  });
}
