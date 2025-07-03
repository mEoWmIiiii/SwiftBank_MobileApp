import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:provider/provider.dart';
import 'package:bankingapp/BalanceProvider.dart'; // Update this import

class TransactionScreen extends StatelessWidget {
  final String userId;
  final TextEditingController _depositAmountController = TextEditingController(); // Define the controller

  TransactionScreen({Key? key, required this.userId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date_time'] as Timestamp?;
      final formattedDate = timestamp != null
          ? DateFormat('MMM d yyyy').format(timestamp.toDate())
          : "Unknown Date";

      return {
        "type": data['transaction_type'] ?? "N/A",
        "date": formattedDate,
        "amount": "₱${(data['amount']?.toDouble() ?? 0.0).toStringAsFixed(2)}",
      };
    }).toList();
  }

  Future<void> _deposit(BuildContext context) async {
    final String input = _depositAmountController.text.trim(); // Use the defined controller
    if (input.isEmpty || double.tryParse(input) == null || double.parse(input) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final double deposit = double.parse(input);
    final double newBalance = (await _getCurrentBalance(userId)) + deposit;

    await updateBalance(userId, newBalance, context);
    
    // Update the provider with the new balance
    Provider.of<BalanceProvider>(context, listen: false).updateBalance(newBalance);
  }

  Future<double> _getCurrentBalance(String userId) async {
    // Fetch the current balance from Firestore
    final doc = await FirebaseFirestore.instance.collection('bank-account').doc(userId).get();
    return (doc.data()?['balance'] ?? 0.0).toDouble();
  }

  Future<void> updateBalance(String userId, double newBalance, BuildContext context) async {
    await FirebaseFirestore.instance.collection('bank-account').doc(userId).update({
      'balance': newBalance,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Balance updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaction'),
        backgroundColor: Color(0xFFF7F3FB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3A3A3A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF3A3A3A),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer<BalanceProvider>(
                  builder: (context, balanceProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Color(0xFF6C6C6C),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PHP ${balanceProvider.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Deposit Amount',
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _depositAmountController,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                    filled: true,
                    fillColor: Color(0xFFF3F1F8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _deposit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4AB6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Deposit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
