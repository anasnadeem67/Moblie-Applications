import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinanceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // --- Real-time Financial Calculation Logic ---
  // This stream calculates Total Income, Total Expense, and Net Balance in real-time
  Stream<Map<String, double>> getFinancialSummary() {
    // Accessing current user's UID for data security and isolation
    String uid = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots() // Listening for real-time updates in the database
        .map((snapshot) {
      double totalIncome = 0;
      double totalExpense = 0;

      // Iterating through all transaction documents to categorize and sum amounts
      for (var doc in snapshot.docs) {
        double amount = (doc['amount'] as num).toDouble();
        if (doc['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      // Returning a mapped summary of the business's financial health
      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    });
  }
}