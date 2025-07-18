// lib/screens/auth/simple_test_auth.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class SimpleTestAuth extends StatefulWidget {
  @override
  _SimpleTestAuthState createState() => _SimpleTestAuthState();
}

class _SimpleTestAuthState extends State<SimpleTestAuth> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  // Predefined test users
  final List<Map<String, String>> testUsers = [
    {'name': 'أحمد محمد', 'email': 'ahmed@test.com', 'phone': '+9647701234567'},
    {'name': 'فاطمة علي', 'email': 'fatima@test.com', 'phone': '+9647707654321'},
    {'name': 'محمد سالم', 'email': 'mohammed@test.com', 'phone': '+9647709876543'},
  ];

  int _selectedUserIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = testUsers[_selectedUserIndex]['name']!;
  }

  Future<void> _signInWithTestUser() async {
    setState(() => _isLoading = true);

    try {
      final selectedUser = testUsers[_selectedUserIndex];

      // Create anonymous user
      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      if (userCredential.user != null) {
        // Create user data in Firestore
        final userData = UserModel(
          uid: userCredential.user!.uid,
          name: _nameController.text,
          phoneNumber: selectedUser['phone']!,
          savedItems: [],
          userType: 'public',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData.toMap());

        // Load user data in provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.initializeAuth();

        // Navigate to store
        Navigator.pushReplacementNamed(context, '/store');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF004080),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'أ',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                Text(
                  'دخول تجريبي سريع',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اختر مستخدم تجريبي للدخول بدون رقم هاتف',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 32),

                // Test users selection
                ...testUsers.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> user = entry.value;
                  bool isSelected = _selectedUserIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUserIndex = index;
                        _nameController.text = user['name']!;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF004080).withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Color(0xFF004080) : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Color(0xFF004080) : Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  user['email']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),

                SizedBox(height: 32),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithTestUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF004080),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'دخول تجريبي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'هذا وضع تجريبي للتطوير. لا يتطلب رقم هاتف حقيقي.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}