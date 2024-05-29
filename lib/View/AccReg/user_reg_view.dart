import 'package:flutter/material.dart';
import 'package:projectcar/View/login_view.dart';
import 'package:projectcar/ViewModel/user_reg_viewmodel.dart';

class UserRegView extends StatefulWidget {
  UserRegView({Key? key}) : super(key: key);

  @override
  State<UserRegView> createState() => _UserRegViewState();
  final UserRegViewModel _viewModel = UserRegViewModel();
}

class _UserRegViewState extends State<UserRegView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _matricStaffNumberController =
      TextEditingController();
  final TextEditingController _icNumberController = TextEditingController();
  final TextEditingController _telephoneNumberController =
      TextEditingController();
  String _selectedCollege = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _matricStaffNumberController,
              decoration:
                  const InputDecoration(labelText: 'Matric/Staff Number'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _icNumberController,
              decoration: const InputDecoration(labelText: 'IC Number'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _telephoneNumberController,
              decoration: const InputDecoration(labelText: 'Telephone Number'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCollege.isNotEmpty ? _selectedCollege : null,
              onChanged: (String? value) {
                setState(() {
                  _selectedCollege = value ?? '';
                });
              },
              items: <String>[
                if (_selectedCollege.isEmpty)
                  'Select College', // hint or default value
                'KRP',
                'KTR',
                'KTHO',
                'KTDI',
              ]
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value == 'Select College' ? '' : value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'College',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _registerUser();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      await widget._viewModel.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        matricStaffNumber: _matricStaffNumberController.text,
        icNumber: _icNumberController.text,
        telephoneNumber: _telephoneNumberController.text,
        college: _selectedCollege,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    } catch (e) {
      print('Error registering user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _matricStaffNumberController.dispose();
    _icNumberController.dispose();
    _telephoneNumberController.dispose();
    super.dispose();
  }
}
