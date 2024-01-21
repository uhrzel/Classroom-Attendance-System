import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';
import 'package:http/http.dart' as http;
import 'package:qr_id_system/main.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late int _registrationId; // Declare _registrationId at the class level

  void _registerUser() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String username = _usernameController.text;
    String address = _addressController.text;

    String subject = _subjectController.text;
    String password = _passwordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        address.isEmpty ||
        subject.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Check if the user already exists based on the first name, last name, and username
    bool userExists = await RegistrationSQLHelper.checkUserExists(
      firstName,
      lastName,
      username,
    );

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data already exists')),
      );
      return;
    }

    // Assign the registrationId value
    _registrationId = await RegistrationSQLHelper.insertRegistration(
      firstName,
      lastName,
      username,
      address,
      subject,
      password,
    );

    if (_registrationId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Registration successful\n Please Navigate to Log in page')),
      );

      _firstNameController.clear();
      _lastNameController.clear();
      _usernameController.clear();
      _addressController.clear();

      _subjectController.clear();
      _passwordController.clear();

      // Perform any additional actions after successful registration, such as navigation or showing a success dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register')),
      );
    }

    // Make a request to the PHP script to get OTP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
              SizedBox(height: 16.0),
              Text(
                'Already have an account?',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () {
                  // Navigate to the login page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => HomePage(),
                  ));
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
