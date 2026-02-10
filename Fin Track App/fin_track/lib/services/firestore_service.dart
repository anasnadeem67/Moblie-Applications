import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Required for using debugPrint

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // --- ADD TRANSACTION METHOD ---
  // Stores a new financial record in the user's specific sub-collection
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
  }) async {
    // Ensuring the user is authenticated before attempting to write data
    if (uid == null) return;

    try {
      // Data is structured as: users -> {uid} -> transactions -> {auto-id doc}
      await _db.collection('users').doc(uid).collection('transactions').add({
        'title': title,
        'amount': amount,
        'type': type, // Categorized as 'income' or 'expense'
        'category': category,
        'date': FieldValue.serverTimestamp(), // Captures the exact server-side timestamp
      });
    } catch (e) {
      // debugPrint is preferred over print for production-level logging
      debugPrint("Error adding transaction: $e");
    }
  }

  // --- REAL-TIME TRANSACTION STREAM ---
  // Retrieves a live stream of transactions, sorted by the most recent date
  Stream<QuerySnapshot> getTransactions() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true) // Ensuring the latest entries appear first
        .snapshots();
  }
}