import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projectcar/Model/admin.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<dynamic> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Check for admin login
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

      // Check for regular user or driver login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? fcmToken = await _firebaseMessaging.getToken();

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
          userTokenFCM: userDoc.data()?['userTokenFCM'] ?? '',
        );

        Provider.of<UserProvider>(context, listen: false).setUser(userModel);

        await _updateTokenFCM(userCredential.user!.uid, fcmToken,
            isDriver: false);

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
            driverTokenFCM: driverDoc.data()?['driverTokenFCM'] ?? '',
          );

          Provider.of<DriverProvider>(context, listen: false)
              .setDriver(driverModel);

          await _updateTokenFCM(userCredential.user!.uid, fcmToken,
              isDriver: true);

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

  Future<void> _updateTokenFCM(String userId, String? fcmToken,
      {required bool isDriver}) async {
    if (fcmToken != null) {
      String collection = isDriver ? 'drivers' : 'users';
      String tokenField = isDriver ? 'driverTokenFCM' : 'userTokenFCM';
      await _firestore
          .collection(collection)
          .doc(userId)
          .update({tokenField: fcmToken});
    }
  }

  void initTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      bool isDriver = true;
      if (userId != null) {
        _updateTokenFCM(userId, newToken, isDriver: isDriver);
      }
    });
  }
}
