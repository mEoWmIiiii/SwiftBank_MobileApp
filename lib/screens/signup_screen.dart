import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart'; // Correct import for the User class
import 'package:bankingapp/AuthService.dart';
import 'package:bankingapp/screens/login_screen.dart'; // Corrected import for LoginPage
import 'package:bankingapp/GoogleService.dart'; // Import GoogleService

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final GoogleService _googleService = GoogleService();

  // Create controllers for the text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to save user data
  Future<void> saveUserData(String username, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  // Function to retrieve user data
  Future<User> fetchUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('password');

    if (username != null && email != null && password != null) {
      // Simulate a delay like a real HTTP call (optional)
      await Future.delayed(const Duration(milliseconds: 300));
      return User(
        username: username,
        email: email,
        password: password,
      );
    } else {
      throw Exception('No user data found in SharedPreferences');
    }
  }

  // New signup function
  Future<void> _signupFunc() async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      if (user != null) {
        log("User Created Successfully");
        await _savedUserData(user.uid);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      log("Error: $e");
    }
  }
  // Saved function
  _savedUserData(String userid) async {
    FirebaseFirestore users = FirebaseFirestore.instance;
    FirebaseFirestore bankaccounts = FirebaseFirestore.instance;
    //check if a user with the same email already exists
    final existingUser = await users
        .collection('users-data')
        .where('email', isEqualTo: emailController.text)
        .limit(1)
        .get();
    if (existingUser.docs.isEmpty) {
      //no user with this email - safe to add
      users.collection('user-data')
          .doc(userid) // your custom ID here
          .set({
        'name': usernameController.text,
        'email': emailController.text,
        'pass': passwordController.text,
      });
      bankaccounts.collection('bank-account')
          .doc(userid) // your custom ID here
          .set({
        'account-number': '1000-1000',
        'balance': 1000,
      });

      print('User added.');
    } else {
      // a user with this email already exits.
      print('User with this email already exists.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 30),

                // Username Field
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

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

                // Sign Up Button
                ElevatedButton(
                  onPressed: () async {
                    await _signupFunc(); // Call the new signup function
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // Full width and height
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20), // Add spacing between buttons

                // Sign Up with Google Button
                OutlinedButton(
                  onPressed: () async {
                    final user = await _googleService.signInWithGoogle();
                    if (user != null) {
                      log("Google User Created Successfully");
                      await saveUserData(
                        user.displayName ?? usernameController.text,
                        user.email ?? '', // Fallback to empty string if null
                        '',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else {
                      log("Google Sign-In Failed");
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
                        'Sign Up with Google',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),

                // FutureBuilder to display user data
                // FutureBuilder<User>(
                //   future: fetchUserFromPrefs(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator(); // Show loading indicator
                //     } else if (snapshot.hasError) {
                //       return Text('Error: ${snapshot.error}'); // Show error message
                //     } else if (snapshot.hasData) {
                //       final user = snapshot.data!;
                //       return Text('User: ${user.username}, Email: ${user.email}'); // Display user data
                //     }
                //     return Container(); // Default case
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
