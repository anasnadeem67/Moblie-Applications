import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _transactionType = 'income'; // Default type set to income
  bool _isTaxApplied = false; // Toggle for GST calculation logic
  final double _taxRate = 18.0; // Standard tax rate for the application

  void _saveToFirebase() async {
    // Validation to ensure all required fields are provided
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    double baseAmount = double.parse(_amountController.text);
    // Calculation logic for applying 18% GST if the toggle is enabled
    double finalAmount = _isTaxApplied 
        ? baseAmount + (baseAmount * (_taxRate / 100)) 
        : baseAmount;

    try {
      // Fetching the unique ID of the currently logged-in user
      String uid = FirebaseAuth.instance.currentUser!.uid; 

      // Saving the transaction details under the specific user's collection in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
        'title': _titleController.text,
        'amount': finalAmount, 
        'type': _transactionType,
        'category': 'General',
        'date': DateTime.now(),
        'taxIncluded': _isTaxApplied,
      });

      if (mounted) {
        Navigator.pop(context); // Return to previous screen after successful save
      }
    } catch (e) {
      // Changed print to debugPrint to comply with Flutter production standards
      debugPrint("Error saving: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Sale / Expense"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Transaction Title (e.g. Shop Sale)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "Rs. ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Selection chips for Transaction Type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Income / Sale"),
                  selected: _transactionType == 'income',
                  onSelected: (val) => setState(() => _transactionType = 'income'),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Expense / Kharcha"),
                  selected: _transactionType == 'expense',
                  onSelected: (val) => setState(() => _transactionType = 'expense'),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),

            // GST Toggle Switch
            SwitchListTile(
              title: const Text("Apply 18% GST (Tax)"),
              subtitle: const Text("Calculate tax automatically"),
              value: _isTaxApplied,
              onChanged: (val) => setState(() => _isTaxApplied = val),
              activeThumbColor: Colors.blueAccent,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("SAVE TRANSACTION", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}