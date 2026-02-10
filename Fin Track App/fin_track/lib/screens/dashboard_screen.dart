import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/finance_service.dart';
import '../services/pdf_service.dart';
import '../services/currency_service.dart';
import '../services/auth_service.dart'; 
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCurrency = "PKR";
  double _exchangeRate = 1.0;
  bool _isLoadingRate = false;

  // Initializing AuthService and capturing the Current User's UID for data isolation
  final AuthService _authService = AuthService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Standard logout procedure to clear session and navigate to LoginScreen
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Triggered when the user selects a different currency from the dropdown
  void _handleCurrencyChange(String? newCurrency) async {
    if (newCurrency == null || newCurrency == _selectedCurrency) return;
    setState(() => _isLoadingRate = true);
    
    // Fetching live exchange rates from the CurrencyService API
    double rate = await CurrencyService.getLiveRate(newCurrency);
    setState(() {
      _selectedCurrency = newCurrency;
      _exchangeRate = rate;
      _isLoadingRate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String symbol = CurrencyService.getSymbol(_selectedCurrency);
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // Dynamic Title: Fetching and displaying the Business Name and User Name from Firestore
        title: FutureBuilder<DocumentSnapshot>(
          future: _authService.getUserProfile(_uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String bName = userData['businessName'] ?? "FinTrack Pro";
              String uName = userData['name'] ?? "User";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Hi, $uName", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              );
            }
            // Fallback text while data is loading or if it does not exist
            return const Text('FinTrack Business Pro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
          },
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _isLoadingRate
              ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
              : DropdownButton<String>(
                  value: _selectedCurrency,
                  dropdownColor: Colors.blueAccent,
                  underline: Container(),
                  icon: const Icon(Icons.currency_exchange, color: Colors.white),
                  items: ['PKR', 'USD', 'INR', 'AED'].map((val) => DropdownMenuItem(
                    value: val,
                    child: Text(val, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: _handleCurrencyChange,
                ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, double>>(
        // Real-time financial data streaming from Firestore
        stream: FinanceService().getFinancialSummary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rawData = snapshot.data!;
          // Applying live exchange rates to the base amounts for multi-currency support
          final double displayIncome = rawData['income']! * _exchangeRate;
          final double displayExpense = rawData['expense']! * _exchangeRate;
          final double displayBalance = rawData['balance']! * _exchangeRate;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMainBalanceCard(displayBalance, symbol),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard("Income", displayIncome, Colors.green, Icons.add_circle, symbol, context)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildSummaryCard("Expense", displayExpense, Colors.red, Icons.remove_circle, symbol, context)),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Visual Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Graphical representation of Income vs Expenses using a PieChart
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: PieChart(PieChartData(sections: [
                    PieChartSectionData(color: Colors.green, value: displayIncome, title: 'In', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.red, value: displayExpense, title: 'Out', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ])),
                ),
                const SizedBox(height: 30),
                // Button to trigger professional PDF report generation
                ElevatedButton.icon(
                  onPressed: () {
                    PdfService.generateInvoice(
                      "Business Summary Report",
                      displayBalance,
                      displayIncome,
                      displayExpense,
                      currentDate,
                      _selectedCurrency
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text("GENERATE PDF INVOICE", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
        label: const Text("Add Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Widget to display the primary Net Profit/Loss balance card
  Widget _buildMainBalanceCard(double amount, String symbol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.indigoAccent]),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          const Text("Net Profit/Loss", style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text("$symbol ${amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Generic card widget for Income and Expense summaries
  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon, String symbol, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionListScreen(
              filterType: title.toLowerCase(),
              currencySymbol: symbol,
              exchangeRate: _exchangeRate,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            Text("$symbol ${amount.toStringAsFixed(2)}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}