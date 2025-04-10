import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create controllers for the text fields
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.blue)), // Set title color to blue
        backgroundColor: Colors.white, // Set AppBar background to white
        iconTheme: const IconThemeData(color: Colors.blue), // Set icon color to blue
      ),
      body: Container(
        color: Colors.white, // Set background to white
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            const Icon(
              Icons.lock,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
                Navigator.pushNamed(context, '/pin'); // Navigate to PIN code screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set button background to blue
                foregroundColor: Colors.white, // Set button text color to white
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
