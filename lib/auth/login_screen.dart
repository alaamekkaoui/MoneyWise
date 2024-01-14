import 'package:app/auth/signup_screen.dart';
import 'package:app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService authService = FirebaseAuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Wise App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on,
              size: 80.0,
              color: buttonColor,
            ),
            Text(
              'Login to Money Wise',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text.trim();
                String password = _passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  User? user = await authService.signInWithUsernameAndPassword(
                    username,
                    password,
                  );

                  if (user != null) {
                    // Successfully signed in
                    print('User signed in: ${user.email}');
                  } else {
                    // Sign-in failed
                    setState(() {
                      _errorMessage = 'Sign-in failed. Check your credentials.';
                    });

                    // Show error message on the screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );

                    // Print error message to the console
                    print('Error: $_errorMessage');
                  }
                } else {
                  // Username or password is empty
                  setState(() {
                    _errorMessage = 'Please enter username and password.';
                  });

                  // Show error message on the screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );

                  // Print error message to the console
                  print('Error: $_errorMessage');
                }
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
