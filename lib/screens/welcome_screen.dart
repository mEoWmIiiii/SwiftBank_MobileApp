// import 'package:flutter/material.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/hand-wave.png',
//                 height: 200,
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 'Welcome to Bank App',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () => Navigator.pushNamed(context, '/login'),
//                 child: const Text('Login'),
//               ),
//               const SizedBox(height: 20),
//               OutlinedButton(
//                 onPressed: () => Navigator.pushNamed(context, '/signup'),
//                 child: const Text('Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }