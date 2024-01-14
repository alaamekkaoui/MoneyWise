import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDatabaseService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');
  final CollectionReference _monthlySalaryCollection =
      FirebaseFirestore.instance.collection('monthlySalary');
  final CollectionReference _goalsCollection =
      FirebaseFirestore.instance.collection('goals');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addExpense(String name, int amount, String description) async {
    await _expensesCollection.add({
      'name': name,
      'amount': amount,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMonthlySalary(int newSalary) async {
    await _monthlySalaryCollection
        .doc('monthlySalary')
        .set({'value': newSalary});
  }

  Future<int> getMonthlySalary() async {
    DocumentSnapshot snapshot =
        await _monthlySalaryCollection.doc('monthlySalary').get();

    return snapshot.exists ? (snapshot['value'] as int?) ?? 0 : 0;
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    QuerySnapshot snapshot = await _expensesCollection.get();
    List<Map<String, dynamic>> expensesList = [];

    snapshot.docs.forEach((document) {
      expensesList.add({
        'key': document.id,
        ...document.data() as Map<String, dynamic>,
      });
    });

    return expensesList;
  }

  Future<void> deleteExpense(String name, int amount) async {
    QuerySnapshot querySnapshot = await _expensesCollection
        .where('name', isEqualTo: name)
        .where('amount', isEqualTo: amount)
        .get();

    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  Future<void> updateExpense(String name, int amount, String newName,
      int newAmount, String newDescription) async {
    QuerySnapshot querySnapshot = await _expensesCollection
        .where('name', isEqualTo: name)
        .where('amount', isEqualTo: amount)
        .get();

    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.update({
          'name': newName,
          'amount': newAmount,
          'description': newDescription,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> addGoal(
      String name, int amount, double monthlyContribution) async {
    await _goalsCollection.add({
      'name': name,
      'amount': amount,
      'monthlyContribution': monthlyContribution,
      'progressAmount': 0.0, // Initial progress amount
    });
  }

  Future<void> updateGoal(String goalId, String newName, int newAmount,
      double newMonthlyContribution, double newProgressAmount) async {
    await _goalsCollection.doc(goalId).update({
      'name': newName,
      'amount': newAmount,
      'monthlyContribution': newMonthlyContribution,
      'progressAmount': newProgressAmount,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    QuerySnapshot snapshot = await _goalsCollection.get();
    List<Map<String, dynamic>> goalsList = [];

    snapshot.docs.forEach((document) {
      goalsList.add({
        'key': document.id,
        ...document.data() as Map<String, dynamic>,
      });
    });

    return goalsList;
  }

  Future<Map<dynamic, dynamic>?> getGoalDetails(String goalId) async {
    DocumentSnapshot snapshot = await _goalsCollection.doc(goalId).get();

    if (snapshot.exists) {
      return {
        'key': snapshot.id,
        ...snapshot.data() as Map<String, dynamic>,
      };
    } else {
      return null;
    }
  }

  Future<void> updateGoalProgress(
      String goalId, double newProgressAmount) async {
    await _goalsCollection.doc(goalId).update({
      'progressAmount': newProgressAmount,
    });
  }

  Future<void> increaseAmountManually(
      String goalId, int manualAmount, double currentProgress) async {
    DocumentReference goalReference = _goalsCollection.doc(goalId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot goalSnapshot = await transaction.get(goalReference);

        if (!goalSnapshot.exists) {
          throw Exception('Goal does not exist!');
        }

        int currentAmount = goalSnapshot['amount'] ?? 0;

        // Update goal amount
        transaction.update(goalReference, {
          'amount': currentAmount + manualAmount,
        });

        // Update progress amount
        transaction.update(goalReference, {
          'progressAmount': currentProgress + manualAmount,
        });
      });
    } catch (e) {
      print('Error increasing amount manually: $e');
      rethrow;
    }
  }

  Future<void> resetGoal(String goalId) async {
    try {
      await _goalsCollection.doc(goalId).update({
        'progressAmount': 0.0,
      });
    } catch (error) {
      // Handle error, e.g., log or throw
      print('Error resetting goal: $error');
      throw error;
    }
  }

  Future<double> getGoalProgress(String goalId) async {
    DocumentSnapshot snapshot = await _goalsCollection.doc(goalId).get();

    if (snapshot.exists) {
      return snapshot['progressAmount']?.toDouble() ?? 0.0;
    } else {
      return 0.0;
    }
  }

  // Authentication methods

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<num> getTotalExpenses() {
    return _expensesCollection.snapshots().map((snapshot) {
      num total = 0;
      for (var document in snapshot.docs) {
        total += (document['amount'] ?? 0) as num;
      }
      return total;
    });
  }
}
