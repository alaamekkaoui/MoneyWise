import 'package:flutter/material.dart';
import '../firebase/firebase_database.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Map<dynamic, dynamic> goal;

  GoalDetailsScreen({required this.goal});

  @override
  _GoalDetailsScreenState createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _monthlyContributionController =
      TextEditingController();
  final TextEditingController _manualContributionController =
      TextEditingController();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  double progressAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.goal['name'] ?? '';
    _amountController.text = (widget.goal['amount'] ?? 0).toString();
    _monthlyContributionController.text =
        (widget.goal['monthlyContribution'] ?? 0).toString();
    progressAmount = widget.goal['progressAmount'] ?? 0.0;

    // Fetch progress amount from the database on page load
    _loadProgressFromDatabase();
  }

  Future<void> _loadProgressFromDatabase() async {
    // Fetch the latest progress amount from the database
    double latestProgress =
        await _databaseService.getGoalProgress(widget.goal['key']);

    // Update the UI with the latest progress amount
    setState(() {
      progressAmount = latestProgress;
      widget.goal['progressAmount'] = progressAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    int goalAmount = widget.goal['amount'] ?? 0;
    double progress = (progressAmount / goalAmount).clamp(0.0, 1.0);
    bool goalComplete = progress >= 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteGoal(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nameController,
                    labelText: 'Goal Name',
                    enabled: !goalComplete,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _buildTextField(
                    controller: _amountController,
                    labelText: 'Amount',
                    enabled: !goalComplete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              controller: _monthlyContributionController,
              labelText: 'Monthly Contribution',
              enabled: !goalComplete,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: goalComplete ? null : _updateGoal,
              child: Text('Update Goal'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: goalComplete ? null : _increaseAmountPopup,
              child: Text('Add Amount'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: goalComplete ? _resetGoal : null,
              child: Text('Reset Goal'),
            ),
            const SizedBox(height: 20.0),
            _buildProgressCard(progress, goalComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        isDense: true,
      ),
    );
  }

  Widget _buildProgressCard(double progress, bool goalComplete) {
    int goalAmount = widget.goal['amount'] ?? 0;

    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            if (goalComplete)
              Text(
                'Goal Completed!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
            else
              Text(
                'Current Progress:',
                style: TextStyle(fontSize: 18.0),
              ),
            if (!goalComplete)
              Text(
                '${progressAmount.toStringAsFixed(2)} / ${goalAmount.toString()}',
                style: TextStyle(fontSize: 18.0),
              ),
            const SizedBox(height: 10.0),
            if (!goalComplete)
              Text(
                '${(progress * 100).toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  void _updateGoal() async {
    String newName = _nameController.text;
    int newAmount = int.tryParse(_amountController.text) ?? 0;
    int newMonthlyContribution =
        int.tryParse(_monthlyContributionController.text) ?? 0;

    if (newName.isNotEmpty && newAmount >= 0 && newMonthlyContribution >= 0) {
      await _databaseService.updateGoal(
        widget.goal['key'],
        newName,
        newAmount,
        newMonthlyContribution.toDouble(),
        progressAmount,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Goal updated successfully!'),
      ));

      // Refresh the page
      setState(() {
        widget.goal['name'] = newName;
        widget.goal['amount'] = newAmount;
        widget.goal['monthlyContribution'] = newMonthlyContribution.toDouble();
      });
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid input. Please enter valid values.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _deleteGoal() async {
    await _databaseService.deleteGoal(widget.goal['key']);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Goal deleted successfully!'),
    ));

    // Navigate back after deleting the goal
    Navigator.pop(context);
  }

  void _increaseAmountPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Amount'),
          content: TextField(
            controller: _manualContributionController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Amount'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _increaseAmountManually();
              },
              child: Text('Add Amount'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _increaseAmountManually() async {
    int manualAmount = int.tryParse(_manualContributionController.text) ?? 0;

    // Update the progress amount in the database
    await _databaseService.increaseAmountManually(
      widget.goal['key'],
      manualAmount,
      progressAmount,
    );

    // Fetch the latest progress amount from the database
    await _loadProgressFromDatabase();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Amount added manually!'),
    ));
  }

  void _resetGoal() async {
    await _databaseService.resetGoal(widget.goal['key']);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Goal reset successfully!'),
    ));

    // Fetch the latest progress amount from the database after resetting
    await _loadProgressFromDatabase();
  }
}
