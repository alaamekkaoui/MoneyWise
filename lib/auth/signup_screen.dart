import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService authService = FirebaseAuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    Color buttonTextColor = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                size: 100.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 20.0),
              Text(
                'Welcome to Money Wise',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _errorMessage = '';
                    _successMessage = '';
                  });

                  String username = _usernameController.text.trim();
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (username.isNotEmpty &&
                      email.isNotEmpty &&
                      password.isNotEmpty) {
                    User? user = await authService.signUpWithEmailAndPassword(
                      email,
                      password,
                      username,
                    );

                    if (user != null) {
                      // Successful account creation
                      setState(() {
                        _successMessage =
                            'Your account has been created successfully!';
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Account Created'),
                            content: Text(_successMessage),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  // Redirect to the home screen or any other screen
                                  // You can use Navigator.pushReplacement or similar methods
                                },
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Text('OK',
                                    style: TextStyle(color: buttonTextColor)),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Sign-up failed
                      setState(() {
                        _errorMessage =
                            'Sign-up failed. Check your credentials or try a different email.';
                      });
                    }
                  } else {
                    // Username, email, or password is empty
                    setState(() {
                      _errorMessage =
                          'Please enter username, email, and password.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
                child:
                    Text('Sign Up', style: TextStyle(color: buttonTextColor)),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _successMessage,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
