import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcar/View/login_view.dart';
import 'package:projectcar/View/Home/admin_home.dart';
import 'package:projectcar/View/Home/driver_home.dart';
import 'package:projectcar/View/Home/user_home.dart';
import 'package:projectcar/ViewModel/login_viewmodel.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/Model/admin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final loginViewModel = LoginViewModel();
      try {
        final fetchedUser = await loginViewModel.loginUser(
          context: context,
          email: user.email!,
          password: '',
        );

        if (fetchedUser is UserModel) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => UserHome(user: fetchedUser)),
          );
        } else if (fetchedUser is DriverModel) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => DriverHome(driver: fetchedUser)),
          );
        } else if (fetchedUser is AdminModel) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => AdminHome(admin: fetchedUser)),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()),
          );
        }
      } catch (e) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
