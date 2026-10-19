import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationProfile {
  const RegistrationProfile(
      {required this.fullName, required this.phone, required this.email});
  final String fullName;
  final String phone;
  final String email;
}

abstract interface class RegistrationService {
  Future<void> register(
      {required RegistrationProfile profile, required String password});
}

class FirebaseRegistrationService implements RegistrationService {
  FirebaseRegistrationService(
      {FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> register(
      {required RegistrationProfile profile, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: profile.email, password: password);
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not return a user.');
    await user.updateDisplayName(profile.fullName);
    final names = profile.fullName.trim().split(RegExp(r'\s+'));
    await _firestore.collection('user_data').doc(user.uid).set({
      'firstName': names.first,
      'lastName': names.skip(1).join(' '),
      'email': profile.email,
      'phone': profile.phone,
      'country': 'Sri Lanka',
      'uid': user.uid,
      'createdAt': Timestamp.now(),
    });
  }
}
