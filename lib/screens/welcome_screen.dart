import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/hand-wave.png',
                height: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to Swift Bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Sign Up', style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
