import 'package:flutter/material.dart';
import 'package:projectcar/Utils/router.dart';
import 'package:projectcar/View/Home/user_home.dart';
import 'package:projectcar/View/Home/driver_home.dart';
import 'package:projectcar/View/Home/admin_home.dart';
import 'AccReg/reg_options_view.dart';
import 'package:projectcar/Model/user.dart';
import 'package:projectcar/Model/driver.dart';
import 'package:projectcar/ViewModel/login_viewmodel.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                final loginViewModel = LoginViewModel();
                final user = await loginViewModel.loginUser(
                  context: context,
                  email: _emailController.text,
                  password: _passwordController.text,
                );

                if (user is UserModel) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserHome(user: user),
                    ),
                  );
                } else if (user is DriverModel) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverHome(driver: user),
                    ),
                  );
                } else if (user == 'admin') {
                  nextPage(context, AdminHome(key: UniqueKey()));
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
    );
  }
}
