import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRegViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String matricStaffNumber,
    required String icNumber,
    required String telephoneNumber,
    required String college,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'password': password,
        'fullname': fullName,
        'MatricStaffNo': matricStaffNumber,
        'ICNO': icNumber,
        'telNo': telephoneNumber,
        'collegeAddress': college,
      });
    } catch (e) {
      print('Error registering user: $e');
      rethrow; // Throw the error to be handled by the caller
    }
  }
}
