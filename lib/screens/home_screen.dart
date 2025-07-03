import 'package:bankingapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:bankingapp/screens/transaction.dart'; // Import the new TransactionScreen
import 'package:provider/provider.dart';
import 'package:bankingapp/BalanceProvider.dart'; // Update this import
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bankingapp/screens/send_screen.dart';
import 'package:bankingapp/screens/analytics_screen.dart';

class UserData {
  final String name;
  final String email;

  UserData({required this.name, required this.email});

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'],
      email: map['email'],
    );
  }
}


class BankAccount {
  final String accountNumber;
  final double balance;

  BankAccount({required this.accountNumber, required this.balance});

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      accountNumber: map['account-number'],
      balance: (map['balance']).toDouble(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserData? userData;
  BankAccount? bankAccount;
  bool isLoading = true;
  String? error;
  int _selectedIndex = 0;
  final List<String> imagePaths = [
    'assets/images/shopee.jpg',
    'assets/images/steam.jpg',
    'assets/images/globe.jpg',
  ];
  int _currentAdIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserAndBankData();
  }

  Future<void> fetchUserAndBankData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('user-data').doc(widget.userId).get();
      final bankDoc = await firestore.collection('bank-account').doc(widget.userId).get();

      if (!userDoc.exists || !bankDoc.exists) {
        throw Exception("User or Bank account not found.");
      }

      setState(() {
        userData = UserData.fromMap(userDoc.data()!);
        bankAccount = BankAccount.fromMap(bankDoc.data()!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('user_id', isEqualTo: widget.userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date_time'] as Timestamp?;
      final formattedDate = timestamp != null
          ? DateFormat('MMM d yyyy').format(timestamp.toDate())
          : "Unknown Date";

      return {
        "type": data['transaction_type'] ?? "N/A",
        "date": formattedDate,
        "amount": "₱${(data['amount'] ?? 0).toStringAsFixed(2)}",
      };
    }).toList();
  }

  Future<void> _deposit(double amount) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    final double newBalance = (bankAccount?.balance ?? 0.0) + amount;
    await updateBalance(
      collectionPath: 'bank-account',
      docId: widget.userId,
      dataToUpdate: {'balance': newBalance},
    );
    await _saveTransaction(widget.userId, "Deposit", amount);
  }

  Future<void> _saveTransaction(String uid, String transtype, double amount) async {
    CollectionReference transaction = FirebaseFirestore.instance.collection('transaction');
    try {
      await transaction.add({
        'date_time': FieldValue.serverTimestamp(),
        'transaction_type': transtype,
        'amount': amount,
        'user_id': uid,
      });
      print("Transaction added successfully!");
    } catch (e) {
      print("Failed to add transaction: $e");
    }
  }

  Future<void> updateBalance({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> dataToUpdate,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(docId)
          .update(dataToUpdate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update document: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> onRefresh() async {
    await fetchUserAndBankData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _homepage(userData?.name ?? '', widget.userId),
      _transferpage(),
      _historypage(),
      _settingsPage(),
    ];

    return ChangeNotifierProvider(
      create: (context) => BalanceProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFFF7F3FB),
          elevation: 0,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0 ? Color(0xFFE7E1F7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.home, color: Color(0xFF3A3A3A), size: 24),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3A3A3A),
                          fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Color(0xFFE7E1F7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.compare_arrows_outlined, color: Color(0xFF3A3A3A), size: 24),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Transfer',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3A3A3A),
                          fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SendScreen(userId: widget.userId)));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/icons/payment.png',
                          width: 24,
                          height: 24,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3A3A3A),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 2 ? Color(0xFFE7E1F7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.history, color: Color(0xFF3A3A3A), size: 24),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3A3A3A),
                          fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 3 ? Color(0xFFE7E1F7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.settings, color: Color(0xFF3A3A3A), size: 24),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3A3A3A),
                          fontWeight: _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homepage(String name, String userId) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: widget.userId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Real-time account number display
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bank-account')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No account found.'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String accNum = (data['account-number'] ?? '').toString().isEmpty ? 'Not assigned' : data['account-number'];
                final double currentBalance = (data['balance'] ?? 0.0).toDouble();
                Provider.of<BalanceProvider>(context, listen: false).updateBalance(currentBalance);
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6D5FFD), Color(0xFF46A8E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Optional: Card chip or logo
                          Icon(Icons.credit_card, color: Colors.white70, size: 32),
                          // Optional: Bank or app name
                      Text(
                            'MyBank',
                        style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Account Number',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accNum,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                            'Available Balance',
                              style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              ),
                            ),
                            Text(
                              'PHP ${currentBalance.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              ),
                            ),
                          ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Special Deals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CarouselSlider(
                    items: imagePaths.map((path) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 160,
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentAdIndex = index;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imagePaths.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentAdIndex == entry.key ? 16 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentAdIndex == entry.key ? Colors.deepPurple : Colors.grey[300],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transferpage() {
    final TextEditingController _depositController = TextEditingController();
    final TextEditingController _transferAmountController = TextEditingController();

    return DefaultTabController(
      length: 2,
      child: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      labelColor: Colors.deepPurple,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.deepPurple,
                      tabs: const [
                        Tab(text: 'Deposit'),
                        Tab(text: 'Transfer'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildDepositTab(_depositController),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildTransferTab(_transferAmountController),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepositTab(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<BalanceProvider>(
          builder: (context, balanceProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  'PHP ${balanceProvider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Deposit Amount', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final input = controller.text.trim();
            if (input.isEmpty || double.tryParse(input) == null || double.parse(input) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }
            final double deposit = double.parse(input);
            final userId = widget.userId;
            final doc = await FirebaseFirestore.instance
                .collection('bank-account')
                .doc(userId)
                .get();
            final double currentBalance = (doc.data()?['balance'] ?? 0.0).toDouble();
            final double newBalance = currentBalance + deposit;
            await FirebaseFirestore.instance
                .collection('bank-account')
                .doc(userId)
                .update({'balance': newBalance});
            Provider.of<BalanceProvider>(context, listen: false).updateBalance(newBalance);
            // Add transaction record
            await FirebaseFirestore.instance.collection('transaction').add({
              'date_time': FieldValue.serverTimestamp(),
              'transaction_type': 'Deposit',
              'amount': deposit,
              'user_id': userId,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deposit successful!')),
            );
            controller.clear();
          },
          child: const Text('Deposit', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildTransferTab(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Consumer<BalanceProvider>(
          builder: (context, balanceProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  'PHP ${balanceProvider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Transfer Amount', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final input = controller.text.trim();
            if (input.isEmpty || double.tryParse(input) == null || double.parse(input) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }
            final double amount = double.parse(input);
            final userId = widget.userId;
            final senderDoc = await FirebaseFirestore.instance
                .collection('bank-account')
                .doc(userId)
                .get();
            final double senderBalance = (senderDoc.data()?['balance'] ?? 0.0).toDouble();
            if (senderBalance < amount) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insufficient balance')),
              );
              return;
            }
            await FirebaseFirestore.instance
                .collection('bank-account')
                .doc(userId)
                .update({'balance': senderBalance - amount});
            Provider.of<BalanceProvider>(context, listen: false).updateBalance(senderBalance - amount);
            // Add transaction record
            await FirebaseFirestore.instance.collection('transaction').add({
              'date_time': FieldValue.serverTimestamp(),
              'transaction_type': 'Transfer',
              'amount': amount,
              'user_id': userId,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transfer successful!')),
            );
            controller.clear();
          },
          child: const Text('Transfer', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _historypage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          final transactions = snapshot.data!;

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isDeposit = tx["type"] == "Deposit";
              final isTransfer = tx["type"] == "Transfer";
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDeposit ? Colors.green[100] : Colors.blue[100],
                    child: Icon(
                      isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isDeposit ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(
                    isDeposit ? 'Deposit' : 'Transfer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDeposit ? Colors.green : Colors.blue,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx["date"],
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      if (isTransfer)
                        const Text('Transferred to another account', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      if (isDeposit)
                        const Text('Deposited to your account', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                  trailing: Text(
                    tx["amount"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _settingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Profile section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, color: Colors.blue, size: 32),
                radius: 28,
              ),
              title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('View and edit your profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.pushNamed(context, '/profile', arguments: widget.userId);
              },
            ),
          ),
          const SizedBox(height: 24),
          // Settings options
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.deepPurple),
              title: const Text('Change PIN'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.pushNamed(context, '/pin');
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.teal),
              title: const Text('View Analytics'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalyticsScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Logout button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required bool isExpense,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isExpense ? Colors.red.shade100 : Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}