import 'package:app/expenses/expenses_screen.dart';
import 'package:app/goals/goals_screen.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_database.dart';
import '../home_screen.dart'; // Import your home screen file

class SalaryScreen extends StatefulWidget {
  @override
  _SalaryScreenState createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _salaryController = TextEditingController();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  int _currentSalary = 0;
  int _remainingBudget = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentSalary();
    _calculateRemainingBudget();
  }

  void _loadCurrentSalary() {
    _databaseService.getMonthlySalary().then((int salary) {
      setState(() {
        _currentSalary = salary;
      });
    });
  }

  void _calculateRemainingBudget() {
    _databaseService.getExpenses().then((List<Map<String, dynamic>> expenses) {
      int totalExpenses =
          expenses.fold(0, (sum, expense) => sum + (expense['amount'] as int));
      setState(() {
        _remainingBudget = _currentSalary - totalExpenses;
      });
    });
  }

  void _updateSalary() {
    int newSalary = int.tryParse(_salaryController.text) ?? 0;

    if (newSalary > 0) {
      _databaseService.updateMonthlySalary(newSalary).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Salary updated successfully!'),
        ));
        _loadCurrentSalary();
        _calculateRemainingBudget();
        Navigator.pop(
            context); // Go back to the home screen after updating salary
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid salary input. Please enter a valid amount.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Monthly Salary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Monthly Salary',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      '\$$_currentSalary',
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter New Salary'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _updateSalary();
              },
              child: Text('Update Salary'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen to update expenses
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpensesScreen(),
                  ),
                );
              },
              child: Text('Update Expenses'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen to update goals
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalsScreen(),
                  ),
                );
              },
              child: Text('Update Goals'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the home screen
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
