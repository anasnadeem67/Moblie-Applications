import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class TransactionListScreen extends StatelessWidget {
  final String filterType;
  final String currencySymbol; 
  final double exchangeRate;   

  const TransactionListScreen({
    super.key, 
    required this.filterType, 
    required this.currencySymbol, 
    required this.exchangeRate
  });

  // --- DELETE TRANSACTION LOGIC ---
  // Removes a specific record from the user's transaction sub-collection in Firestore
  void _deleteTransaction(BuildContext context, String docId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(docId)
        .delete();
    
    // Safety check to ensure the context is still valid after the async database call
    if (!context.mounted) return; 
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry deleted successfully")),
    );
  }

  // --- UPDATE / EDIT TRANSACTION DIALOG ---
  // Provides a UI interface to modify existing transaction details
  void _showEditDialog(BuildContext context, String docId, String oldTitle, double oldAmount) {
    final TextEditingController titleEdit = TextEditingController(text: oldTitle);
    final TextEditingController amountEdit = TextEditingController(text: oldAmount.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Edit ${filterType.toUpperCase()}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleEdit, 
              decoration: const InputDecoration(labelText: "Description")
            ),
            TextField(
              controller: amountEdit, 
              decoration: const InputDecoration(labelText: "Amount (in Base Currency)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () async {
              String uid = FirebaseAuth.instance.currentUser!.uid;
              
              // Updating the transaction document with new validated data
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('transactions')
                  .doc(docId)
                  .update({
                'title': titleEdit.text,
                'amount': double.tryParse(amountEdit.text) ?? 0.0,
              });

              // Closing the dialog after a successful update
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("${filterType.toUpperCase()} History"),
        backgroundColor: filterType == 'income' ? Colors.green : Colors.red,
        foregroundColor: Colors.white, 
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Streaming filtered data based on transaction type (income/expense)
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .where('type', isEqualTo: filterType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text("No $filterType records found."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id;

              // Currency conversion logic for real-time display
              double rawAmount = (data['amount'] ?? 0.0).toDouble();
              double convertedAmount = rawAmount * exchangeRate;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                elevation: 2,
                child: ListTile(
                  // Triggering the edit dialog on tapping the list item
                  onTap: () => _showEditDialog(context, docId, data['title'] ?? "", rawAmount),
                  leading: CircleAvatar(
                    backgroundColor: filterType == 'income' ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      filterType == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: filterType == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    data['title'] ?? "No Title", 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    data['date'] != null 
                      ? (data['date'] as Timestamp).toDate().toString().split(' ')[0] 
                      : ""
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Displaying the converted currency amount with appropriate symbol
                      Text(
                        "$currencySymbol ${convertedAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Button to initiate the deletion of a transaction record
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteTransaction(context, docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}