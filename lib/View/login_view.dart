import 'package:flutter/material.dart';
import 'package:projectcar/Model/admin.dart';
import 'package:projectcar/View/Home/admin_home.dart';
import 'package:projectcar/View/Home/driver_home.dart';
import 'package:projectcar/View/Home/user_home.dart';
import 'package:projectcar/ViewModel/login_viewmodel.dart';
import 'AccReg/reg_options_view.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel viewModel = LoginViewModel();

  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/Asset/images/Logo.png',
                width: 200.0,
                height: 200.0,
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final user = await viewModel.loginUser(
                    context: context,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (user != null) {
                    if (user is UserModel) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserHome(user: user),
                        ),
                      );
                    } else if (user is DriverModel) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverHome(driver: user),
                        ),
                      );
                    } else if (user is AdminModel) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminHome(admin: user),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegOptView()),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
