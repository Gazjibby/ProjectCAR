import 'package:flutter/material.dart';

class UserModel {
  final String email;
  final String fullName;
  final String matricStaffNumber;
  final String icNumber;
  final String telephoneNumber;
  final String college;
  final String userTokenFCM;

  UserModel({
    required this.email,
    required this.fullName,
    required this.matricStaffNumber,
    required this.icNumber,
    required this.telephoneNumber,
    required this.college,
    required this.userTokenFCM,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      fullName: data['fullname'] ?? '',
      matricStaffNumber: data['MatricStaffNo'] ?? '',
      icNumber: data['ICNO'] ?? '',
      telephoneNumber: data['telNo'] ?? '',
      college: data['collegeAddress'] ?? '',
      userTokenFCM: data['userTokenFCM'] ?? '',
    );
  }
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
