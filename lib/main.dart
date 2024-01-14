import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firebase_options.dart';
import 'home_screen.dart';
import '../budget/salary_screen.dart';
import 'expenses/expenses_screen.dart';
import '../goals/goals_screen.dart';
import '../auth/login_screen.dart'; // Import your login screen file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppWrapper(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/salary': (context) => SalaryScreen(),
        '/expenses': (context) => ExpensesScreen(),
        '/goals': (context) => GoalsScreen(),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginPage();
          }
        }
      },
    );
  }
}
