import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Model/admin.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<dynamic> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> adminQuerySnapshot = await _firestore
          .collection('Admin')
          .where('Username', isEqualTo: email)
          .where('Password', isEqualTo: password)
          .limit(1)
          .get();

      if (adminQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> adminDoc =
            adminQuerySnapshot.docs.first;
        AdminModel adminModel = AdminModel(
          username: adminDoc.data()?['Username'] ?? '',
          password: adminDoc.data()?['Password'] ?? '',
        );

        Provider.of<AdminProvider>(context, listen: false).setAdmin(adminModel);
        return adminModel;
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
          fullName: userDoc.data()?['fullname'] ?? '',
          matricStaffNumber: userDoc.data()?['MatricStaffNo'] ?? '',
          icNumber: userDoc.data()?['ICNO'] ?? '',
          telephoneNumber: userDoc.data()?['telNo'] ?? '',
          college: userDoc.data()?['collegeAddress'] ?? '',
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
            fullName: driverDoc.data()?['fullName'] ?? '',
            matricStaffNumber: driverDoc.data()?['matricStaffNumber'] ?? '',
            icNumber: driverDoc.data()?['icNumber'] ?? '',
            telephoneNumber: driverDoc.data()?['telephoneNumber'] ?? '',
            college: driverDoc.data()?['college'] ?? '',
            photoUrl: driverDoc.data()?['Car Details']['photoUrl'] ?? '',
            status: driverDoc.data()?['status'] ?? '',
            voteFlag: driverDoc.data()?['Car Details']['voteFlag'] ?? '',
            carBrand: driverDoc.data()?['Car Details']['carBrand'],
            carModel: driverDoc.data()?['Car Details']['carModel'],
            carColor: driverDoc.data()?['Car Details']['carColor'],
            carPlate: driverDoc.data()?['Car Details']['plateNumber'],
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
