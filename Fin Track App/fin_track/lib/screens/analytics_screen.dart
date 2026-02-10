import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class AnalyticsScreen extends StatelessWidget {
  // Parameters to handle multi-currency display and real-time conversion
  final String currency;
  final double rate;

  const AnalyticsScreen({super.key, required this.currency, required this.rate});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Analytics ($currency)"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listening to real-time transaction updates from Firestore
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double income = 0;
          double expense = 0;

          for (var doc in snapshot.data!.docs) {
            // Applying exchange rate multiplication for currency conversion
            double amt = (doc['amount'] as num).toDouble() * rate;
            if (doc['type'] == 'income') {
              income += amt;
            } else {
              expense += amt;
            }
          }

          double total = income + expense;
          
          // Determining the correct currency symbol based on selection
          String symbol = currency == "USD" ? "\$" : "$currency ";

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Income vs Expense", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        // Visual representation of Income percentage
                        PieChartSectionData(
                          value: income,
                          title: total > 0 ? '${((income / total) * 100).toStringAsFixed(1)}%' : '0%',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        // Visual representation of Expense percentage
                        PieChartSectionData(
                          value: expense,
                          title: total > 0 ? '${((expense / total) * 100).toStringAsFixed(1)}%' : '0%',
                          color: Colors.red,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Legend with Dynamic Currency values based on live rates
                _buildStatTile("Total Income", "$symbol${income.toStringAsFixed(2)}", Colors.green),
                _buildStatTile("Total Expense", "$symbol${expense.toStringAsFixed(2)}", Colors.red),
                _buildStatTile("Net Savings", "$symbol${(income - expense).toStringAsFixed(2)}", const Color(0xFF673AB7)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reusable widget to display financial statistics in a list format
  Widget _buildStatTile(String label, String value, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 10),
        title: Text(label),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ),
    );
  }
}