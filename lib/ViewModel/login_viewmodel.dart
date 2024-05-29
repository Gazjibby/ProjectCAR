import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'; // Import flutter material package for BuildContext

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<dynamic> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email == 'SuperAdmin' && password == '5004705146') {
        return 'admin';
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        UserModel userModel = UserModel(
          email: userCredential.user!.email ?? '',
          fullName: userDoc['fullname'] ?? '',
          matricStaffNumber: userDoc['MatricStaffNo'] ?? '',
          icNumber: userDoc['ICNO'] ?? '',
          telephoneNumber: userDoc['telNo'] ?? '',
          college: userDoc['collegeAddress'] ?? '',
        );

        Provider.of<UserProvider>(context, listen: false).setUser(userModel);

        return userModel;
      } else {
        DocumentSnapshot<Map<String, dynamic>> driverDoc = await _firestore
            .collection('drivers')
            .doc(userCredential.user!.uid)
            .get();

        if (driverDoc.exists) {
          DriverModel driverModel = DriverModel(
            email: userCredential.user!.email ?? '',
            fullName: driverDoc['fullName'] ?? '',
            matricStaffNumber: driverDoc['matricStaffNumber'] ?? '',
            icNumber: driverDoc['icNumber'] ?? '',
            telephoneNumber: driverDoc['telephoneNumber'] ?? '',
            college: driverDoc['college'] ?? '',
            photoUrl: driverDoc['photoUrl'] ?? '',
            status: driverDoc['status'] ?? '',
            voteFlag: driverDoc['voteFlag'] ?? '',
          );

          Provider.of<DriverProvider>(context, listen: false)
              .setDriver(driverModel);

          return driverModel;
        } else {
          throw Exception('User not found in both collections');
        }
      }
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }
}
