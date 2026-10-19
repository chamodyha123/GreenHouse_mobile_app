import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_gebere/auth/login/login.dart';
import 'package:smart_gebere/auth/signup/registration_service.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_auth_scaffold.dart';
import 'package:smart_gebere/features/chamoth/presentation/widgets/green_plan_logo.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.registrationService});

  final RegistrationService? registrationService;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final RegistrationService _registrationService =
      widget.registrationService ?? FirebaseRegistrationService();
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _receiveFarmingUpdates = false;
  bool _showConsentError = false;
  String? _errorMessage;

  double _passwordStrength = 0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    var strength = 0.0;

    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp('[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp('[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength += 0.25;
    }

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.yellow[700] ?? Colors.yellow;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GreenPlanAuthScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: () async {
                        await Navigator.maybePop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF1F5D3B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: GreenPlanLogo(size: 56)),
                const SizedBox(height: 20),
                Text(
                  'Create your account 🌱',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF17452D),
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join GreenPlan and make planning your growing season easier.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF66776B),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Sri Lankan Phone Number (+94)',
                  hint: '+94 7X XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final number =
                        value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
                    if (number.isEmpty) return 'Phone number is required';
                    if (!RegExp(r'^(\+94|0)?7\d{8}$').hasMatch(number)) {
                      return 'Enter a valid Sri Lankan mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'farmer@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  onToggleVisibility: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _passwordStrength,
                            backgroundColor: Colors.grey[200],
                            valueColor:
                                AlwaysStoppedAnimation(_passwordStrengthColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _passwordStrengthText,
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPasswordRequirement(
                        '8+ characters',
                        _passwordController.text.length >= 8,
                      ),
                      _buildPasswordRequirement(
                        'Uppercase',
                        _passwordController.text.contains(RegExp('[A-Z]')),
                      ),
                      _buildPasswordRequirement(
                        'Number',
                        _passwordController.text.contains(RegExp('[0-9]')),
                      ),
                      _buildPasswordRequirement(
                        'Special',
                        _passwordController.text
                            .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  onToggleVisibility: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreedToTerms,
                  onChanged: _isLoading
                      ? null
                      : (value) => setState(() {
                            _agreedToTerms = value ?? false;
                            _showConsentError = false;
                          }),
                  activeColor: const Color(0xFF1F5D3B),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text.rich(
                    TextSpan(
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF53645A),
                        fontSize: 13,
                      ),
                      children: const [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Color(0xFF1F5D3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Color(0xFF1F5D3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                if (_showConsentError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'Please agree to the Terms of Service and Privacy Policy.',
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _receiveFarmingUpdates,
                  onChanged: _isLoading
                      ? null
                      : (value) => setState(
                            () => _receiveFarmingUpdates = value ?? false,
                          ),
                  activeColor: const Color(0xFF1F5D3B),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Send me optional farming updates',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF53645A),
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildErrorMessage(_errorMessage!),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5D3B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF9AB8A6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF66776B),
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () async => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginPage(),
                                ),
                              ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF1F5D3B),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF35473B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autocorrect: false,
          enableSuggestions: !obscureText,
          style: GoogleFonts.poppins(
            color: const Color(0xFF26382D),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9AA79E),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF527762),
              size: 21,
            ),
            suffixIcon: onToggleVisibility == null
                ? null
                : IconButton(
                    tooltip: obscureText ? 'Show password' : 'Hide password',
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF718278),
                      size: 20,
                    ),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2EBE4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4E8762),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: met ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: met ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      await HapticFeedback.mediumImpact();
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _showConsentError = true);
      await HapticFeedback.mediumImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _registrationService.register(
        profile: RegistrationProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        ),
        password: _passwordController.text,
      );

      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _getErrorMessage(error.code));
    } on Object catch (_) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Account creation is currently disabled.';
      default:
        return 'Signup failed. Please try again.';
    }
  }
}
