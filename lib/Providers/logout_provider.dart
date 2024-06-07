import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcar/Utils/router.dart';
import 'package:projectcar/View/login_view.dart';

class LogoutProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    nextPage(context, LoginView());
  }
}
