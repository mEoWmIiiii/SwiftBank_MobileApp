import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

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

Future<UserProfile> fetchUserProfile(String userId) async {
  final doc = await FirebaseFirestore.instance.collection('user-data').doc(userId).get();
  if (!doc.exists) throw Exception('User not found');
  return UserProfile.fromMap(doc.data()!);
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

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
      body: FutureBuilder<UserProfile>(
        future: fetchUserProfile(userId),
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
                    leading: Icon(Icons.email, color: Colors.blue),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  // Add more fields as needed
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            userId: userId,
                            currentName: user.name,
                            currentEmail: user.email,
                          ),
                        ),
                      );
                      if (result == true) {
                        // Optionally show a snackbar or refresh the profile
                        (context as Element).reassemble(); // Quick way to refresh FutureBuilder
                      }
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
