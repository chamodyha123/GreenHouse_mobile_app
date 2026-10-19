// GreenPlan's canonical splash screen.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_gebere/auth/signup/sign_up.dart';

import 'package:smart_gebere/auth/login/login.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_auth_scaffold.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_benefit_card.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_logo.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_primary_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    this.onGetStarted,
    this.onLogIn,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onLogIn;

  @override
  Widget build(BuildContext context) {
    return GreenPlanAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: GreenPlanLogo(size: 68)),
          const SizedBox(height: 16),
          Text(
            'GreenPlan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1F5D3B),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your greenhouse companion',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: const Color(0xFF607568), fontSize: 13),
          ),
          const SizedBox(height: 28),
          Text(
            'Plan, grow and harvest with confidence \u{1F331}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF163625),
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'GreenPlan supports greenhouse planning, crop care and harvest decisions for Sri Lankan growers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF607568),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          const GreenPlanBenefitCard(
            icon: Icons.grid_view_rounded,
            title: 'BOM & Layout',
            subtitle: 'Materials list and greenhouse planning in seconds.',
          ),
          const SizedBox(height: 12),
          const GreenPlanBenefitCard(
            icon: Icons.document_scanner_outlined,
            title: 'Disease Scan',
            subtitle: 'Capture a leaf photo and receive guidance.',
          ),
          const SizedBox(height: 12),
          const GreenPlanBenefitCard(
            icon: Icons.language_rounded,
            title: 'Your Language',
            subtitle: 'Agricultural support designed for local growers.',
          ),
          const SizedBox(height: 28),
          Semantics(
            label:
                'Language selection. English is available; Sinhala and Tamil are coming soon.',
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _LanguagePill(label: 'English', selected: true),
                _LanguagePill(
                  label: '\u{0DC3}\u{0DD2}\u{0D82}\u{0DC4}',
                  available: false,
                ),
                _LanguagePill(
                  label: '\u{0BA4}\u{0BAE}\u{0BBF}\u{0BB4}\u{0BCD}',
                  available: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GreenPlanPrimaryButton(
              label: 'Get Started', onPressed: () => _openSignup(context)),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Already have an account? ',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: const Color(0xFF607568))),
              TextButton(
                onPressed: () => _openLogin(context),
                child: Text('Log In',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF1F5D3B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSignup(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SignupPage()));
  }

  void _openLogin(BuildContext context) {
    if (onLogIn != null) {
      onLogIn!();
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill(
      {required this.label, this.selected = false, this.available = true});

  final String label;
  final bool selected;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: available,
      selected: selected,
      label: available ? '$label language' : '$label language, coming soon',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F5D3B) : const Color(0xFFE2F1E7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? const Color(0xFF1F5D3B) : const Color(0xFFB8D5C0)),
        ),
        child: Text(
          available ? label : '$label · Soon',
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : const Color(0xFF607568),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
