import 'package:flutter/material.dart';

class AdminModel {
  final String username;
  final String password;

  AdminModel({
    required this.username,
    required this.password,
  });
}

class AdminProvider with ChangeNotifier {
  AdminModel? _admin;

  AdminModel? get admin => _admin;

  void setDriver(AdminModel admin) {
    _admin = admin;
    notifyListeners();
  }
}
