import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DriverRegViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String email = '';
  String password = '';
  String fullName = '';
  String matricStaffNumber = '';
  String icNumber = '';
  String telephoneNumber = '';
  String college = '';

  Future<void> saveTempData({
    required String email,
    required String password,
    required String fullName,
    required String matricStaffNumber,
    required String icNumber,
    required String telephoneNumber,
    required String college,
  }) async {
    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        matricStaffNumber.isEmpty ||
        icNumber.isEmpty ||
        telephoneNumber.isEmpty ||
        college.isEmpty) {
      throw Exception('All fields are required');
    }

    this.email = email;
    this.password = password;
    this.fullName = fullName;
    this.matricStaffNumber = matricStaffNumber;
    this.icNumber = icNumber;
    this.telephoneNumber = telephoneNumber;
    this.college = college;
  }

  Future<void> registerDriver({
    required String photoUrl,
    required String carBrand,
    required String carModel,
    required String carColor,
    required String plateNumber,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('drivers').doc(userCredential.user!.uid).set({
        'email': email,
        'password': password,
        'fullName': fullName,
        'matricStaffNumber': matricStaffNumber,
        'icNumber': icNumber,
        'telephoneNumber': telephoneNumber,
        'college': college,
        'voteFlag': '0',
        'Car Details': {
          'photoUrl': photoUrl,
          'plateNumber': plateNumber,
          'carBrand': carBrand,
          'carModel': carModel,
          'carColor': carColor,
        },
        'status': 'pending',
      });
    } catch (e) {
      print('Error registering: $e');
      throw Exception('Registration failed');
    }
  }

  Future<String?> uploadPhoto(String filePath, String matricStaffNumber) async {
    try {
      File file = File(filePath);
      TaskSnapshot snapshot = await _storage
          .ref('VehiclePhotos')
          .child('$matricStaffNumber.jpg')
          .putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }
}
