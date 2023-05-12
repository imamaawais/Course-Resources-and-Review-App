import 'package:flutter/material.dart';
//import 'admin_dashboard.dart';
//import 'student_dashboard.dart';
import 'main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _adminEmail = ''; // replace with your admin email
  String _adminPassword = ''; // replace with your admin password
  String _studentEmail = ''; // replace with your student email
  String _studentPassword = ''; // replace with your student password
  var db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _adminData = [];
  List<Map<String, dynamic>> _studentData = [];
  bool isAdminEmail = false;
  bool isStudentEmail = false;

  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
  final String _emailFormatHint = 'ID@example.com';

  @override
  void initState() {
    super.initState();
    // Get adminEmail and adminPassword from Firebase database
    final adminCollectionRef = db.collection("admin");
    adminCollectionRef.get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final adminEmail = data['email'];
          final adminPassword = data['password'];
          _adminData.add({'email': adminEmail, 'password': adminPassword});
        });
      },
      onError: (e) => print("Error getting documents: $e"),
    );

    final studentCollectionRef = db.collection("student");
    studentCollectionRef.get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final studentEmail = data['email'];
          final studentPassword = data['password'];
          _studentData
              .add({'email': studentEmail, 'password': studentPassword});
        });
      },
      onError: (e) => print("Error getting documents: $e"),
    );
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // convert password to bytes
    var digest = sha256.convert(bytes); // compute hash value
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    //bool isAdminEmail = false;
    //bool isStudentEmail = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: _emailFormatHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }

                  if (!_emailRegExp.hasMatch(value)) {
                    return 'Invalid email format';
                  }

                  _adminData.forEach((admin) {
                    if (admin['email'] == value) {
                      isAdminEmail = true;
                      isStudentEmail = false;
                      _adminEmail = admin['email'];
                      _adminPassword = admin['password'];
                    }
                  });
                  _studentData.forEach((student) {
                    if (student['email'] == value) {
                      isStudentEmail = true;
                      isAdminEmail = false;
                      _studentEmail = student['email'];
                      _studentPassword = student['password'];
                    }
                  });
                  if (!isAdminEmail && !isStudentEmail) {
                    isAdminEmail = false;
                    isStudentEmail = false;
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  isAdminEmail = false;
                  isStudentEmail = false;
                  if (_emailController.text == _adminEmail &&
                      hashPassword(value) == _adminPassword) {
                    isAdminEmail = true;
                    isStudentEmail = false;
                    GlobalData.userEmail = _emailController.text;
                    return null;
                  } else if (_emailController.text == _studentEmail &&
                      hashPassword(value) == _studentPassword) {
                    isStudentEmail = true;
                    isAdminEmail = false;
                    GlobalData.userEmail = _emailController.text;
                    return null;
                  } else if (_emailController.text == _studentEmail ||
                      _emailController.text == _adminEmail) {
                    return 'Invalid password';
                  }
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    if (email.isEmpty || password.isEmpty) {
                      return; // Prevent login if either field is empty
                    }

                    if (isAdminEmail == true) {
                      Navigator.pushNamed(context, '/adminDashboard');
                    } else if (isStudentEmail == true) {
                      Navigator.pushNamed(
                        context,
                        '/studentDashboard',
                        arguments: _emailController.text,
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 8.0),
              TextButton(
                child: Text('Forgot password?'),
                onPressed: () {
                  Navigator.pushNamed(context, '/forgotPassword');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
