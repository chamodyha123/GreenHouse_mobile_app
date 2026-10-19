import 'package:flutter/material.dart';

/// Shared responsive canvas for the GreenPlan entry flow.
class GreenPlanAuthScaffold extends StatelessWidget {
  const GreenPlanAuthScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F2),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
