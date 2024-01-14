import 'package:flutter/material.dart';
import '../firebase/firebase_database.dart';
import 'goal_details_screen.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _monthlyContributionController =
      TextEditingController();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  List<Map<dynamic, dynamic>> _goalsList = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    List<Map<dynamic, dynamic>> goalsList = await _databaseService.getGoals();
    setState(() {
      _goalsList = goalsList;
    });
  }

  Future<void> _addGoal() async {
    String name = _nameController.text;
    int amount = int.tryParse(_amountController.text) ?? 0;
    double monthlyContribution =
        double.tryParse(_monthlyContributionController.text) ?? 0;

    if (name.isNotEmpty && amount > 0 && monthlyContribution >= 0) {
      await _databaseService.addGoal(name, amount, monthlyContribution);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Goal added successfully!'),
      ));
      _clearInputFields();
      await _loadGoals();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Invalid input. Please enter a valid name, amount (as a number), and monthly contribution.',
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    await _databaseService.deleteGoal(goalId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Goal deleted successfully!'),
    ));
    await _loadGoals();
  }

  void _clearInputFields() {
    _nameController.clear();
    _amountController.clear();
    _monthlyContributionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddGoalForm(),
            const SizedBox(height: 20.0),
            Text(
              'List of Goals',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            _buildGoalsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGoalForm() {
    return Column(
      children: [
        Text(
          'Add Goal',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Goal Name'),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: _monthlyContributionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Monthly Contribution'),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: () async {
            await _addGoal();
          },
          child: Text('Add Goal'),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    return _goalsList.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              itemCount: _goalsList.length,
              itemBuilder: (context, index) {
                return GoalListItem(
                  goal: _goalsList[index],
                  onDelete: () async {
                    await _deleteGoal(_goalsList[index]['key']);
                  },
                  onDetails: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalDetailsScreen(
                          goal: _goalsList[index],
                        ),
                      ),
                    );
                    await _loadGoals(); // Reload goals when navigating back
                  },
                );
              },
            ),
          )
        : const Text('No goals available');
  }
}

class GoalListItem extends StatelessWidget {
  final Map<dynamic, dynamic> goal;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  GoalListItem({
    required this.goal,
    required this.onDelete,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    int goalAmount = goal['amount'] ?? 0;
    double progressAmount = goal['progressAmount'] ?? 0.0;
    double progress = (progressAmount / goalAmount).clamp(0.0, 1.0);
    bool goalComplete = progress >= 1.0;

    return ListTile(
      title: Text(goal['name']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount: \$${goal['amount']}'),
          Text(
            goalComplete
                ? 'Goal Completed!'
                : 'Completion: ${(progress * 100).toStringAsFixed(2)}%',
            style: TextStyle(
              color: goalComplete ? Colors.green : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: onDetails,
          ),
        ],
      ),
    );
  }
}
