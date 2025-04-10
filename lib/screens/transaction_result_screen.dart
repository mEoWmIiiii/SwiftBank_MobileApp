import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TransactionResultScreen extends StatelessWidget {
  const TransactionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You can pass transaction status as a parameter
    final bool isSuccess = true; // This should ideally be passed as a parameter

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Lottie animations for success/error
            Lottie.asset(
              isSuccess
                  ? 'assets/Lottie/success.json' // Ensure this path is correct
                  : 'assets/Lottie/error.json', // Optional: add error animation
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              isSuccess ? 'Transaction Successful!' : 'Transaction Failed!', // Added error message
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'), // Ensure this route is defined
              child: const Text('Back to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}