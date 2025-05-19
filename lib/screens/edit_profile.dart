import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentEmail;

  const EditProfileScreen({
    Key? key,
    required this.userId,
    required this.currentName,
    required this.currentEmail,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('user-data')
        .doc(widget.userId)
        .update({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    });

    // Update Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update display name
      await user.updateDisplayName(_nameController.text.trim());

      // Update email (may require re-authentication)
      if (user.email != _emailController.text.trim()) {
        try {
          await user.updateEmail(_emailController.text.trim());
        } catch (e) {
          // Handle error (e.g., re-authentication required)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update email: $e')),
          );
        }
      }
    }

    setState(() => _isSaving = false);
    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 40),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
