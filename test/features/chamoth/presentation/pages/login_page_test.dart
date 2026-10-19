import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gebere/auth/signup/sign_up.dart';
import 'package:smart_gebere/auth/login/login.dart';
import 'package:smart_gebere/l10n/app_localizations.dart';

class FakeLoginAuthGateway implements LoginAuthGateway {
  FakeLoginAuthGateway(
      {this.signInError, this.resetError, this.signInCompleter});

  final Object? signInError;
  final Object? resetError;
  final Completer<void>? signInCompleter;
  final signIns = <({String email, String password})>[];
  final resetEmails = <String>[];

  @override
  Future<void> signIn({required String email, required String password}) async {
    signIns.add((email: email, password: password));
    if (signInCompleter != null) await signInCompleter!.future;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetEmails.add(email);
    if (resetError != null) throw resetError!;
  }
}

class FakeLoginEmailStore implements LoginEmailStore {
  FakeLoginEmailStore([this.value]);

  String? value;
  final writes = <String>[];

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String email) async {
    value = email;
    writes.add(email);
  }
}

void main() {
  Widget buildSubject({
    FakeLoginAuthGateway? auth,
    FakeLoginEmailStore? store,
  }) =>
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: LoginPage(
          authGateway: auth ?? FakeLoginAuthGateway(),
          emailStore: store ?? FakeLoginEmailStore(),
        ),
      );

  Future<void> tapWhenVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  Future<void> enterCredentials(
    WidgetTester tester, {
    String email = 'grower@example.com',
    String password = 'password123',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  testWidgets('renders the GreenPlan login form', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Welcome back 👋'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('validates email and password', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pump();
    expect(find.text('Email address is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'bad-email');
    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(1)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).at(1)).obscureText,
      isFalse,
    );
  });

  testWidgets('restores and saves only the remembered email', (tester) async {
    final store = FakeLoginEmailStore('saved@example.com');
    final auth = FakeLoginAuthGateway();
    await tester.pumpWidget(buildSubject(auth: auth, store: store));
    await tester.pump();
    expect(find.text('saved@example.com'), findsOneWidget);

    await enterCredentials(tester, email: 'new@example.com');
    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pump();
    expect(store.writes, ['new@example.com']);
  });

  testWidgets('sends a password reset email', (tester) async {
    final auth = FakeLoginAuthGateway();
    await tester.pumpWidget(buildSubject(auth: auth));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'grower@example.com');
    await tester.tap(find.text('Send link'));
    await tester.pumpAndSettle();
    expect(auth.resetEmails, ['grower@example.com']);
  });

  testWidgets('handles failed authentication gracefully', (tester) async {
    final auth = FakeLoginAuthGateway(signInError: StateError('offline'));
    await tester.pumpWidget(buildSubject(auth: auth));
    await enterCredentials(tester);
    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pump();
    expect(find.text('Unable to log in. Check your connection and try again.'),
        findsOneWidget);
  });

  testWidgets('prevents duplicate login submissions while loading',
      (tester) async {
    final completer = Completer<void>();
    final auth = FakeLoginAuthGateway(signInCompleter: completer);
    await tester.pumpWidget(buildSubject(auth: auth));
    await enterCredentials(tester);
    await tapWhenVisible(tester, find.text('Log In'));
    await tester.pump();
    await tester.tap(find.text('Logging in…'));
    expect(auth.signIns, hasLength(1));
    completer.complete();
    await tester.pump();
  });

  testWidgets('navigates to signup', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('can navigate back', (tester) async {
    final auth = FakeLoginAuthGateway();
    final store = FakeLoginEmailStore();
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => LoginPage(authGateway: auth, emailStore: store),
          )),
          child: const Text('Open login'),
        ),
      ),
    ));
    await tester.tap(find.text('Open login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open login'), findsOneWidget);
  });

  testWidgets('does not overflow on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildSubject());
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
