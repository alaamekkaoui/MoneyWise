import 'package:flutter/material.dart';
import '../firebase/firebase_database.dart'; 

class ExpenseDetailsScreen extends StatefulWidget {
  String name;
  int amount;
  String description;

  ExpenseDetailsScreen({
    required this.name,
    required this.amount,
    required this.description,
  });

  @override
  _ExpenseDetailsScreenState createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  final TextEditingController _modifiedNameController = TextEditingController();
  final TextEditingController _modifiedAmountController =
      TextEditingController();
  final TextEditingController _modifiedDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial values in text fields
    _modifiedNameController.text = widget.name;
    _modifiedAmountController.text = widget.amount.toString();
    _modifiedDescriptionController.text = widget.description;
  }

  void _updateExpense() {
    String modifiedName = _modifiedNameController.text;
    int modifiedAmount = int.tryParse(_modifiedAmountController.text) ?? 0;
    String modifiedDescription = _modifiedDescriptionController.text;

    _databaseService
        .updateExpense(
      widget.name,
      widget.amount,
      modifiedName,
      modifiedAmount,
      modifiedDescription,
    )
        .then((_) {
      // Show updated values in the UI
      setState(() {
        widget.name = modifiedName;
        widget.amount = modifiedAmount;
        widget.description = modifiedDescription;
      });

      // Clear input fields
      _clearInputFields();

      // Show a snackbar or any other notification about the update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense updated successfully!')),
      );
    }).catchError((error) {
      // Handle error, show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating expense: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _deleteExpense() {
    _databaseService.deleteExpense(widget.name, widget.amount).then((_) {
      // Go back to the previous screen after deleting
      Navigator.pop(context);

      // Show a snackbar or any other notification about the delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense deleted successfully!')),
      );
    }).catchError((error) {
      // Handle error, show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting expense: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _clearInputFields() {
    _modifiedNameController.clear();
    _modifiedAmountController.clear();
    _modifiedDescriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Details',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text('Name: ${widget.name}'),
            Text('Amount: \$ ${widget.amount}'),
            Text('Description: ${widget.description}'),
            SizedBox(height: 20.0),
            Text(
              'Update Expense',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _modifiedNameController,
              decoration: InputDecoration(labelText: 'Modified Expense Name'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _modifiedAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Modified Amount'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _modifiedDescriptionController,
              decoration: InputDecoration(labelText: 'Modified Description'),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateExpense();
                  },
                  child: Text('Update Expense'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteExpense();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Text('Delete Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
