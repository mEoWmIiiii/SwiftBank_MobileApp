import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendScreen extends StatefulWidget {
  final String userId;
  const SendScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiverAccountController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  double? _currentBalance;

  @override
  void initState() {
    super.initState();
    _fetchCurrentBalance();
  }

  Future<void> _fetchCurrentBalance() async {
    final doc = await FirebaseFirestore.instance.collection('bank-account').doc(widget.userId).get();
    setState(() {
      _currentBalance = (doc.data()?['balance'] ?? 0.0).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
        backgroundColor: Color(0xFFF7F3FB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3A3A3A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF3A3A3A),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Center(
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
                      _currentBalance != null ? 'PHP ${_currentBalance!.toStringAsFixed(2)}' : 'Loading...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Enter Transfer Amount',
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                        filled: true,
                        fillColor: Color(0xFFF3F1F8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Receiver's Account Number",
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receiverAccountController,
                      decoration: InputDecoration(
                        hintText: 'Account Number',
                        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                        filled: true,
                        fillColor: Color(0xFFF3F1F8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Receiver's Name",
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receiverNameController,
                      decoration: InputDecoration(
                        hintText: "Receiver's Name",
                        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                        filled: true,
                        fillColor: Color(0xFFF3F1F8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Purpose',
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        hintText: 'Purpose of Transfer',
                        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                        filled: true,
                        fillColor: Color(0xFFF3F1F8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontSize: 18, color: Color(0xFF222222)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4AB6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Trasfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendTransfer() async {
    final amountText = _amountController.text.trim();
    final receiverAccount = _receiverAccountController.text.trim();
    final receiverName = _receiverNameController.text.trim();
    final purpose = _purposeController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final double amount = double.parse(amountText);

    // 1. Get sender's balance, account number, and name
    final senderDoc = await FirebaseFirestore.instance.collection('bank-account').doc(widget.userId).get();
    final senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();
    final senderAccountNumber = senderDoc.data()?['account-number'];

    // Fetch sender's name from user-data
    final senderUserDoc = await FirebaseFirestore.instance.collection('user-data').doc(widget.userId).get();
    final senderName = senderUserDoc.data()?['name'] ?? '';

    if (senderBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    // 2. Find receiver by account number
    final receiverQuery = await FirebaseFirestore.instance
        .collection('bank-account')
        .where('account-number', isEqualTo: receiverAccount)
        .limit(1)
        .get();

    if (receiverQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receiver not found')),
      );
      return;
    }

    final receiverDoc = receiverQuery.docs.first;
    final receiverId = receiverDoc.id;
    final receiverBalance = (receiverDoc.data()['balance'] ?? 0.0).toDouble();

    // Fetch receiver's name from user-data
    final receiverUserDoc = await FirebaseFirestore.instance.collection('user-data').doc(receiverId).get();
    final receiverNameFromDb = receiverUserDoc.data()?['name'] ?? receiverName;

    // 3. Firestore transaction: update balances and add history
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Update sender
      transaction.update(senderDoc.reference, {'balance': senderBalance - amount});
      // Update receiver
      transaction.update(receiverDoc.reference, {'balance': receiverBalance + amount});

      // Add transaction for sender (history)
      final senderHistory = FirebaseFirestore.instance.collection('transaction').doc();
      transaction.set(senderHistory, {
        'user_id': widget.userId,
        'transaction_type': 'Transfer',
        'amount': amount,
        'date_time': FieldValue.serverTimestamp(),
        'receiver_account_number': receiverAccount,
        'receiver_name': receiverNameFromDb,
        'purpose': purpose,
      });

      // Add transaction for receiver (history)
      final receiverHistory = FirebaseFirestore.instance.collection('transaction').doc();
      transaction.set(receiverHistory, {
        'user_id': receiverId,
        'transaction_type': 'Received',
        'amount': amount,
        'date_time': FieldValue.serverTimestamp(),
        'sender_account_number': senderAccountNumber,
        'sender_name': senderName,
        'purpose': purpose,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer successful!')),
    );
    Navigator.pop(context); // Go back after success
  }
} 