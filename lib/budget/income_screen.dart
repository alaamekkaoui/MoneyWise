import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final CollectionReference _monthlySalaryCollection =
      FirebaseFirestore.instance.collection('monthlySalary');

  late TextEditingController _incomeNameController;
  late TextEditingController _incomeAmountController;
  late int _currentIncome;

  @override
  void initState() {
    super.initState();
    _incomeNameController = TextEditingController();
    _incomeAmountController = TextEditingController();
    _currentIncome = 0;
    _fetchCurrentIncome();
  }

  Future<void> _fetchCurrentIncome() async {
    DocumentSnapshot totalIncomeSnapshot =
        await _monthlySalaryCollection.doc('totalIncome').get();
    setState(() {
      _currentIncome = totalIncomeSnapshot.exists
          ? (totalIncomeSnapshot['value'] as int?) ?? 0
          : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _incomeNameController,
                    decoration: InputDecoration(
                      labelText: 'Income Name',
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: TextField(
                    controller: _incomeAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Income Amount',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_incomeNameController.text.isNotEmpty &&
                    _incomeAmountController.text.isNotEmpty) {
                  String incomeName = _incomeNameController.text;
                  int incomeAmount = int.parse(_incomeAmountController.text);
                  await addIncome(incomeName, incomeAmount);
                  _incomeNameController.clear();
                  _incomeAmountController.clear();
                  _fetchCurrentIncome();
                }
              },
              child: Text('Add Income'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Current Income: \$$_currentIncome',
              style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _monthlySalaryCollection
                    .doc('incomeList')
                    .collection('incomes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var incomeDocs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: incomeDocs.length,
                      itemBuilder: (context, index) {
                        var income = incomeDocs[index];

                        return ListTile(
                          title: Text(income['name'] ?? ''),
                          subtitle: Text(
                            'Amount: \$${income['amount'] ?? 0}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () async {
                              await subtractIncome(
                                income.id,
                                income['amount'],
                              );
                              _fetchCurrentIncome();
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addIncome(String incomeName, int incomeAmount) async {
    CollectionReference incomeCollection =
        _monthlySalaryCollection.doc('incomeList').collection('incomes');

    await incomeCollection.add({
      'name': incomeName,
      'amount': incomeAmount,
    });

    await _monthlySalaryCollection.doc('totalIncome').set({
      'value': FieldValue.increment(incomeAmount),
    }, SetOptions(merge: true));
  }

  Future<void> subtractIncome(String incomeId, int incomeAmount) async {
    CollectionReference incomeCollection =
        _monthlySalaryCollection.doc('incomeList').collection('incomes');

    await incomeCollection.doc(incomeId).delete();

    await _monthlySalaryCollection.doc('totalIncome').set({
      'value': FieldValue.increment(-incomeAmount),
    }, SetOptions(merge: true));
  }
}
