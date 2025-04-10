import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/icons/user.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'John',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: Image.asset(
                'assets/icons/home.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Email'),
              subtitle: const Text('john.doe@example.com'),
            ),
            ListTile(
              leading: Image.asset(
                'assets/icons/telephone.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Phone'),
              subtitle: const Text('+1 234 567 890'),
            ),
            ListTile(
              leading: Image.asset(
                'assets/icons/transfer.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Account Number'),
              subtitle: const Text('**** **** **** 1234'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add edit profile functionality
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
