import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_gebere/stream/stream_provider.dart';

void main() {
  Widget buildGate(Stream<UserModel?> stream) {
    return MaterialApp(
      home: AuthSessionGate(
        authState: stream,
        dashboardBuilder: (_) => const Text('dashboard'),
        signedOutBuilder: (_) => const Text('splash'),
      ),
    );
  }

  testWidgets('shows a loading state before auth state is available',
      (tester) async {
    final controller = StreamController<UserModel?>();
    addTearDown(controller.close);
    await tester.pumpWidget(buildGate(controller.stream));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows splash for a signed-out session', (tester) async {
    await tester.pumpWidget(buildGate(Stream<UserModel?>.value(null)));
    await tester.pump();

    expect(find.text('splash'), findsOneWidget);
  });

  testWidgets('shows dashboard once for repeated authenticated updates',
      (tester) async {
    final controller = StreamController<UserModel?>();
    addTearDown(controller.close);
    await tester.pumpWidget(buildGate(controller.stream));

    controller.add(UserModel(uid: 'farmer-1'));
    await tester.pump();
    controller.add(UserModel(uid: 'farmer-1'));
    await tester.pump();

    expect(find.text('dashboard'), findsOneWidget);
    expect(find.text('splash'), findsNothing);
  });
}
