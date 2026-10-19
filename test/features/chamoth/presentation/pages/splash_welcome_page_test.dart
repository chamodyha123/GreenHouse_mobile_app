import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:smart_gebere/auth/signup/sign_up.dart';
import 'package:smart_gebere/auth/login/login.dart';
import 'package:smart_gebere/splash/splash_screen.dart';
import 'package:smart_gebere/l10n/app_localizations.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('green_plan_splash_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox<String>('user_prefs');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  Widget buildSubject({VoidCallback? onGetStarted, VoidCallback? onLogIn}) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(
        onGetStarted: onGetStarted,
        onLogIn: onLogIn,
      ),
    );
  }

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  testWidgets('renders the GreenPlan welcome content and benefit cards',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.bySemanticsLabel('GreenPlan logo'), findsOneWidget);
    expect(
      find.text('Plan, grow and harvest with confidence \u{1F331}'),
      findsOneWidget,
    );
    expect(find.text('BOM & Layout'), findsOneWidget);
    expect(find.text('Disease Scan'), findsOneWidget);
    expect(find.text('Your Language'), findsOneWidget);
  });

  testWidgets('runs the supplied Get Started action', (tester) async {
    var opened = false;
    await tester.pumpWidget(buildSubject(onGetStarted: () => opened = true));

    await tapWhenVisible(tester, find.text('Get Started'));

    expect(opened, isTrue);
  });

  testWidgets('runs the supplied Log In action', (tester) async {
    var opened = false;
    await tester.pumpWidget(buildSubject(onLogIn: () => opened = true));

    await tapWhenVisible(tester, find.text('Log In'));

    expect(opened, isTrue);
  });

  testWidgets('opens the existing signup screen by default', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tapWhenVisible(tester, find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('opens the existing login screen by default', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('shows unsupported local languages as unavailable',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(
      find.text('\u{0DC3}\u{0DD2}\u{0D82}\u{0DC4} · Soon'),
      findsOneWidget,
    );
    expect(
      find.text('\u{0BA4}\u{0BAE}\u{0BBF}\u{0BB4}\u{0BCD} · Soon'),
      findsOneWidget,
    );
    for (final language in [
      '\u{0DC3}\u{0DD2}\u{0D82}\u{0DC4}',
      '\u{0BA4}\u{0BAE}\u{0BBF}\u{0BB4}\u{0BCD}',
    ]) {
      final unavailableLanguage = find.bySemanticsLabel(
        RegExp('$language language, coming soon'),
      );

      expect(unavailableLanguage, findsOneWidget);
      expect(
        tester.getSemantics(unavailableLanguage),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
    }
  });

  testWidgets('does not overflow across supported viewport sizes',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 844),
      const Size(800, 600),
      const Size(1024, 768),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(buildSubject());
      expect(tester.takeException(), isNull, reason: 'viewport: $size');
    }
  });
}
