// GreenPlan's canonical login screen.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_gebere/auth/signup/sign_up.dart';
import 'package:smart_gebere/core/services/offline_storage.dart';

import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_auth_scaffold.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_logo.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_primary_button.dart';

abstract interface class LoginAuthGateway {
  Future<void> signIn({required String email, required String password});
  Future<void> sendPasswordResetEmail(String email);
}

class FirebaseLoginAuthGateway implements LoginAuthGateway {
  FirebaseLoginAuthGateway({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}

abstract interface class LoginEmailStore {
  Future<String?> read();
  Future<void> write(String email);
}

class OfflineLoginEmailStore implements LoginEmailStore {
  @override
  Future<String?> read() async =>
      OfflineStorage.getUserPref<String>('remembered_email');

  @override
  Future<void> write(String email) =>
      OfflineStorage.setUserPref('remembered_email', email);
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.authGateway,
    this.emailStore,
  });

  final LoginAuthGateway? authGateway;
  final LoginEmailStore? emailStore;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;
  var _rememberEmail = false;
  var _isLoading = false;
  String? _errorMessage;

  LoginAuthGateway? _authGateway;
  late final LoginEmailStore _emailStore;

  @override
  void initState() {
    super.initState();
    _authGateway = widget.authGateway;
    _emailStore = widget.emailStore ?? OfflineLoginEmailStore();
    _restoreEmail();
  }

  Future<void> _restoreEmail() async {
    final email = await _emailStore.read();
    if (!mounted || email == null || email.isEmpty) return;
    setState(() {
      _emailController.text = email;
      _rememberEmail = true;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email address is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required.' : null;

  Future<void> _signIn() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await (_authGateway ??= FirebaseLoginAuthGateway()).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _emailStore
          .write(_rememberEmail ? _emailController.text.trim() : '');
      // AuthSessionGate owns the authenticated destination.
    } on FirebaseAuthException catch (error) {
      _showError(_firebaseError(error.code));
    } catch (_) {
      _showError('Unable to log in. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Unable to log in. Please try again.';
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final controller = TextEditingController(text: _emailController.text);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (_validateEmail(email) != null) return;
              try {
                await (_authGateway ??= FirebaseLoginAuthGateway())
                    .sendPasswordResetEmail(email);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent.')),
                  );
                }
              } catch (_) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text('Unable to send reset email.')),
                  );
                }
              }
            },
            child: const Text('Send link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GreenPlanAuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Center(child: GreenPlanLogo(size: 56)),
            const SizedBox(height: 24),
            Text('Welcome back 👋', style: _headingStyle),
            const SizedBox(height: 8),
            Text(
              'Log in to continue planning your greenhouse.',
              style: _mutedStyle,
            ),
            const SizedBox(height: 32),
            _fieldLabel('EMAIL ADDRESS'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
              decoration: _inputDecoration(
                hint: 'you@example.com',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),
            _fieldLabel('PASSWORD'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              validator: _validatePassword,
              onFieldSubmitted: (_) => _signIn(),
              decoration: _inputDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberEmail,
                      onChanged: _isLoading
                          ? null
                          : (value) =>
                              setState(() => _rememberEmail = value ?? false),
                    ),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: _isLoading ? null : _showPasswordResetDialog,
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            GreenPlanPrimaryButton(
              label: _isLoading ? 'Logging in…' : 'Log In',
              onPressed: _isLoading ? null : _signIn,
            ),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('New to GreenPlan?', style: _mutedStyle),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SignupPage()),
                  ),
                  child: const Text('Create an account'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Keep your account details private when using a shared device.',
              textAlign: TextAlign.center,
              style: _mutedStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _headingStyle => GoogleFonts.poppins(
        color: const Color(0xFF163625),
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  TextStyle get _mutedStyle =>
      GoogleFonts.poppins(color: const Color(0xFF607568), fontSize: 14);

  Widget _fieldLabel(String value) => Text(
        value,
        style: GoogleFonts.poppins(
          color: const Color(0xFF456B55),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );
}
