import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_gebere/Home/Home.dart';
import 'package:smart_gebere/features/chamoth/presentation/pages/splash_welcome_page.dart';

class UserModel {
  UserModel({required this.uid, this.email, this.displayName});
  final String uid;
  final String? email;
  final String? displayName;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          )
        : null;
  }

  // Auth Stream to listen for changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }
}

class StreamProviderClass extends StatelessWidget {
  const StreamProviderClass({super.key, this.authState});

  /// Injectable for widget tests; production uses Firebase Auth's stream.
  final Stream<UserModel?>? authState;

  @override
  Widget build(BuildContext context) {
    final stream = authState ?? AuthService().user;
    return AuthSessionGate(authState: stream);
  }
}

/// Selects a stable root screen from Firebase Auth state without imperative
/// navigation, avoiding duplicate routes when the auth stream rebuilds.
class AuthSessionGate extends StatelessWidget {
  const AuthSessionGate({
    required this.authState,
    super.key,
    this.dashboardBuilder,
    this.signedOutBuilder,
  });

  final Stream<UserModel?> authState;
  final WidgetBuilder? dashboardBuilder;
  final WidgetBuilder? signedOutBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return (dashboardBuilder ?? (_) => const Home_Screen())(context);
        }
        return (signedOutBuilder ?? (_) => const SplashWelcomePage())(context);
      },
    );
  }
}
