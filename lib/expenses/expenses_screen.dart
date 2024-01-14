import 'package:app/expenses/expense_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_database.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Expenses'),
            StreamBuilder<num>(
              stream: _databaseService.getTotalExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return Text(
                  'Total Expenses: \$${snapshot.data}',
                  style: TextStyle(fontSize: 14.0),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Expense',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Expense Name'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _addExpense();
              },
              child: Text('Add Expense'),
            ),
            SizedBox(height: 20.0),
            Text(
              'List of Expenses',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            _buildExpenseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _expensesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<Map<String, dynamic>> expensesList = [];

          snapshot.data?.docs.forEach((document) {
            expensesList.add({
              'name': document['name'],
              'amount': document['amount'],
              'description': document['description'],
            });
          });

          return ListView.builder(
            itemCount: expensesList.length,
            itemBuilder: (context, index) {
              var expense = expensesList[index];
              return ListTile(
                title: Text('${expense['name']} - \$${expense['amount'] ?? 0}'),
                subtitle: Text('Description: ${expense['description'] ?? ''}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showExpenseDetails(
                      expense['name'] ?? '',
                      expense['amount'] ?? 0,
                      expense['description'] ?? '',
                    );
                  },
                  child: Text('Details'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addExpense() async {
    String name = _nameController.text;
    int amount = int.tryParse(_amountController.text) ?? 0;
    String description = _descriptionController.text;

    if (name.isNotEmpty && amount > 0) {
      await _databaseService.addExpense(name, amount, description);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Expense added successfully!'),
      ));

      _clearInputFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid input. Please enter a valid name and amount.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _clearInputFields() {
    _nameController.clear();
    _amountController.clear();
    _descriptionController.clear();
  }

  void _showExpenseDetails(String name, int amount, String description) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(
          name: name,
          amount: amount,
          description: description,
        ),
      ),
    );
  }
}
