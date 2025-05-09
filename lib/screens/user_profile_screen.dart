import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}

Future<http.Response> _fakeHttpGet(String path) async {
  final data = await rootBundle.loadString(path);
  return http.Response(data, 200);
}

Future<User> fetchUser() async {
  final response = await _fakeHttpGet('assets/Lottie/userdata.json');

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    return User.fromJson(jsonData);
  } else {
    throw Exception('Failed to load local user data');
  }
}

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
      body: FutureBuilder<User>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icons/user.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: Image.asset(
                      'assets/icons/home.png',
                      width: 24,
                      height: 24,
                    ),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/icons/telephone.png',
                      width: 24,
                      height: 24,
                    ),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/icons/transfer.png',
                      width: 24,
                      height: 24,
                    ),
                    title: const Text('Address'),
                    subtitle: Text(user.address),
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
            );
          }
        },
      ),
    );
  }
}
