import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../expenses/expenses_screen.dart';
import '../goals/goals_screen.dart';
import '../budget/salary_screen.dart';
import '../budget/income_screen.dart';
import 'firebase/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _monthlySalaryCollection =
      FirebaseFirestore.instance.collection('monthlySalary');
  final CollectionReference _incomeCollection =
      FirebaseFirestore.instance.collection('income');
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  late int _monthlySalary;
  late int _totalIncome;
  late int _currentIncome;
  late int _totalExpenses;
  late User? _user;
  late String _username;

  @override
  void initState() {
    super.initState();
    _getUser();
    _monthlySalary = 0;
    _totalIncome = 0;
    _currentIncome = 0;
    _totalExpenses = 0;
    _loadMonthlySalary();
    _loadTotalIncome();
    _fetchCurrentIncome();
    _fetchTotalExpenses();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = _auth.currentUser;

    if (_user != null) {
      // Fetch username from the database based on user's uid
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userSnapshot.exists) {
        _username = userSnapshot['username'] ?? '';
      } else {
        // If user data doesn't exist in the database, use email
        _username = _user?.email?.split('@').first ?? '';
      }

      setState(() {});
    }
  }

  void _loadMonthlySalary() {
    _monthlySalaryCollection
        .doc('monthlySalary')
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        _monthlySalary = snapshot.exists ? (snapshot['value'] as int?) ?? 0 : 0;
      });
    });
  }

  void _loadTotalIncome() {
    _monthlySalaryCollection
        .doc('totalIncome')
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        _totalIncome = snapshot.exists ? (snapshot['value'] as int?) ?? 0 : 0;
      });
    });
  }

  void _fetchCurrentIncome() {
    _monthlySalaryCollection
        .doc('totalIncome')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      setState(() {
        _currentIncome = snapshot.exists ? (snapshot['value'] as int?) ?? 0 : 0;
      });
    });
  }

  void _fetchTotalExpenses() {
    FirebaseDatabaseService().getTotalExpenses().listen((num totalExpenses) {
      setState(() {
        _totalExpenses = totalExpenses.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/small_money_icon.png',
            //   height: 10.0,
            //   width: 10.0,
            // ),
            const SizedBox(width: 20.0),
            const Text('MoneyWise'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome, $_username',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await _auth.signOut();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          icon: const Icon(Icons.logout),
                          tooltip: 'Logout',
                        ),
                        const Text('Logout'),
                      ],
                    ),
                  ],
                ),
              ),
            Card(
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Salary',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10.0,
                      width: 500.0,
                    ),
                    Text(
                      '\$${_monthlySalary + _totalIncome}',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Salary : \$$_monthlySalary',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalaryScreen(),
                          ),
                        );
                        _loadMonthlySalary();
                        _loadTotalIncome();
                        _fetchCurrentIncome();
                      },
                      child: const Text('Update Monthly Salary'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Card(
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Income',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10.0,
                      width: 500.00,
                    ),
                    Text(
                      '\$$_currentIncome',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the screen to view income
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IncomeScreen(),
                          ),
                        ).then((value) {
                          _loadTotalIncome();
                          _fetchCurrentIncome();
                        });
                      },
                      child: const Text('View Income History'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Card(
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10.0,
                      width: 500.0,
                    ),
                    Text(
                      '\$$_totalExpenses',
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the screen to view expenses
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpensesScreen(),
                              ),
                            );
                          },
                          child: const Text('View Expenses'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the screen to view goals
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoalsScreen(),
                              ),
                            );
                          },
                          child: const Text('View Goals'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
