import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({Key? key}) : super(key: key);

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  String pin = '';
  bool isVerifying = false;

  void _addNumber(String number) {
    if (pin.length < 4) {
      setState(() {
        pin += number;
      });
      if (pin.length == 4) {
        // Show verification animation
        setState(() {
          isVerifying = true;
        });

        // Simulate PIN verification
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushNamed(context, '/profile');
        });
      }
    }
  }

  void _removeNumber() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isVerifying)
            // Show verification animation
            Lottie.asset(
              'assets/animations/loading.json',
              width: 150,
              height: 150,
            )
          else
            Column(
              children: [
                const Text(
                  'Enter your 4-digit PIN',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < pin.length ? Colors.blue : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ],
            ),
          const SizedBox(height: 40),

          // Only show the keypad if not verifying
          if (!isVerifying)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink();
                  }
                  if (index == 10) {
                    return NumberButton(
                      number: '0',
                      onTap: () => _addNumber('0'),
                    );
                  }
                  if (index == 11) {
                    return IconButton(
                      icon: const Icon(Icons.backspace),
                      onPressed: _removeNumber,
                    );
                  }
                  return NumberButton(
                    number: '${index + 1}',
                    onTap: () => _addNumber('${index + 1}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  const NumberButton({
    Key? key,
    required this.number,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(
        number,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
