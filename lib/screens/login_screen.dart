import 'package:flutter/material.dart';
import 'package:bankingapp/GoogleService.dart';
import 'package:bankingapp/screens/home_screen.dart'; // Ensure HomeScreen is imported
import 'package:bankingapp/AuthService.dart'; // Import AuthService
import 'dart:developer';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Create controllers for the text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleService _googleService = GoogleService();
  final AuthService _auth = AuthService(); // Use AuthService instance
  String? errorMessage; // Variable to hold error messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.blue)), // Set title color to blue
        backgroundColor: Colors.white, // Set AppBar background to white
        iconTheme: const IconThemeData(color: Colors.blue), // Set icon color to blue
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Container(
          color: Colors.white, // Set background to white
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0, // Adjust for keyboard
          ),
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

              // Error Message
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),

              // Login Button
              SizedBox(
                width: double.infinity, // Make the button take full width
                child: ElevatedButton(
                  onPressed: _login, // Call the _login method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set button background to blue
                    foregroundColor: Colors.white, // Set button text color to white
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Space between buttons

              // Sign In with Google Button
              SizedBox(
                width: double.infinity, // Make the button take full width
                child: OutlinedButton(
                  onPressed: () async {
                    final user = await _googleService.signInWithGoogle();
                    if (user != null) {
                      // Navigate to home screen with userId
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(userId: user.uid), // Pass user ID here
                        ),
                      );
                    } else {
                      // Handle sign-in failure
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue), // Blue border
                    backgroundColor: Colors.white, // White background
                    foregroundColor: Colors.blue, // Blue text
                    minimumSize: const Size(double.infinity, 50), // Full width
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.webp', // Path to your Google icon
                        height: 24, // Adjust height as needed
                        width: 24, // Adjust width as needed
                      ),
                      const SizedBox(width: 8), // Space between icon and text
                      const Text(
                        'Sign In with Google',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    // Use the AuthService instance to call the login method
    final user = await _auth.loginUserWithEmailAndPassword(
      emailController.text,
      passwordController.text,
    );

    if (user != null) {
      log("User Logged In");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userId: user.uid)), // Ensure HomeScreen is imported
      );
    } else {
      // Handle login failure (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
