import 'package:flutter/material.dart';

/// Compact GreenPlan brand mark used by the Chamoth-owned entry screens.
class GreenPlanLogo extends StatelessWidget {
  const GreenPlanLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'GreenPlan logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1F5D3B),
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x261F5D3B),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.eco_rounded, color: Colors.white, size: size * .55),
      ),
    );
  }
}
