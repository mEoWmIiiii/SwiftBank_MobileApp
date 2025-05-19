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
      appBar: AppBar(
        title: const Text('Transaction'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // StreamBuilder to listen for balance changes
            Consumer<BalanceProvider>(
              builder: (context, balanceProvider, child) {
                return Text(
                  'Current Balance: ₱${balanceProvider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _depositAmountController,
              decoration: InputDecoration(
                labelText: 'Deposit Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => _deposit(context),
              child: const Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
