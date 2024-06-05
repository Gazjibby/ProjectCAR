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
  final String carBrand;
  final String carModel;
  final String carColor;
  final String carPlate;

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
    required this.carBrand,
    required this.carModel,
    required this.carColor,
    required this.carPlate,
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
