import 'package:flutter/material.dart';

class UserModel {
  final String email;
  final String fullName;
  final String matricStaffNumber;
  final String icNumber;
  final String telephoneNumber;
  final String college;

  UserModel({
    required this.email,
    required this.fullName,
    required this.matricStaffNumber,
    required this.icNumber,
    required this.telephoneNumber,
    required this.college,
  });
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
