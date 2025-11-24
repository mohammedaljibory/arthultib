import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'otp_verification_screen.dart';
import 'address_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _phoneNumber = '';
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _proceedToOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool userExists = await authProvider.checkUserExists(_phoneNumber);
      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يوجد حساب مسجل بهذا الرقم. الرجاء تسجيل الدخول.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      authProvider.sendOTP(
        phoneNumber: _phoneNumber,
        onCodeSent: (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: _phoneNumber,
                isSignUp: true,
                name: _nameController.text,
                address: _selectedAddress,
                latitude: _latitude,
                longitude: _longitude,
              ),
            ),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            // Left side - Form
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 450),
                  padding: EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFF004080).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person_add_outlined,
                                    size: 40,
                                    color: Color(0xFF004080),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: isDesktop ? 32 : 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'انضم إلينا للحصول على أفضل العروض',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الكامل',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال الاسم';
                              }
                              if (value.length < 3) {
                                return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Phone Field
                          IntlPhoneField(
                            decoration: InputDecoration(
                              labelText: 'رقم الهاتف',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            initialCountryCode: 'IQ',
                            onChanged: (phone) {
                              _phoneNumber = phone.completeNumber;
                            },
                            validator: (value) {
                              if (value == null || value.number.isEmpty) {
                                return 'الرجاء إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Address (Optional)
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressSelectionScreen(),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _selectedAddress = result['address'];
                                  _latitude = result['latitude'];
                                  _longitude = result['longitude'];
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: _selectedAddress != null
                                        ? Color(0xFF004080)
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedAddress ?? 'إضافة عنوان التوصيل (اختياري)',
                                      style: TextStyle(
                                        color: _selectedAddress != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _proceedToOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF004080),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text('متابعة', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('لديك حساب بالفعل؟ '),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/sign-in');
                                },
                                child: Text('تسجيل الدخول'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right side - Decorative (Desktop only)
            if (isDesktop)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF004080), Color(0xFF0066CC)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 120,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(height: 32),
                        Text(
                          'مميزات الحساب',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 32),
                        _buildFeature(Icons.local_offer_outlined, 'عروض حصرية'),
                        _buildFeature(Icons.history_outlined, 'متابعة الطلبات'),
                        _buildFeature(Icons.favorite_outline, 'حفظ المفضلات'),
                        _buildFeature(Icons.flash_on_outlined, 'شحن سريع'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}