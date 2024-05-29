import 'package:flutter/material.dart';
import 'user_reg_view.dart';
import 'driver_reg_view.dart';

class RegOptView extends StatelessWidget {
  const RegOptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserRegView()),
                );
              },
              child: const Text('Register as Normal User'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriverRegView()),
                );
              },
              child: const Text('Register as Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
