import 'package:flutter/material.dart';

class DriverModel {
  final String email;
  final String fullName;
  final String matricStaffNumber;
  final String icNumber;
  final String telephoneNumber;
  final String college;
  final String photoUrl;
  final String status;
  final String voteFlag;

  DriverModel({
    required this.email,
    required this.fullName,
    required this.matricStaffNumber,
    required this.icNumber,
    required this.telephoneNumber,
    required this.college,
    required this.photoUrl,
    required this.status,
    required this.voteFlag,
  });
}

class DriverProvider with ChangeNotifier {
  DriverModel? _driver;

  DriverModel? get driver => _driver;

  void setDriver(DriverModel driver) {
    _driver = driver;
    notifyListeners();
  }
}
