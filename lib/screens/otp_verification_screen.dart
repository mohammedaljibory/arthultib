
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isSignUp;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.isSignUp,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  String _currentOTP = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() {
    if (_currentOTP.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال رمز التحقق المكون من 6 أرقام'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.isSignUp) {
      // Sign up flow
      authProvider.verifyOTPAndSignUp(
        smsCode: _currentOTP,
        name: widget.name!,
        phoneNumber: widget.phoneNumber,
        address: widget.address,
        latitude: widget.latitude,
        longitude: widget.longitude,
        onSuccess: () {
          Navigator.pushNamedAndRemoveUntil(context, '/store', (route) => false);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } else {
      // Sign in flow
      authProvider.verifyOTPAndSignIn(
        smsCode: _currentOTP,
        onSuccess: () {
          Navigator.pushNamedAndRemoveUntil(context, '/store', (route) => false);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  void _resendOTP() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.sendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال رمز التحقق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'التحقق من الهاتف',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أرسلنا رمز التحقق إلى',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    onChanged: (value) {
                      setState(() {
                        _currentOTP = value;
                      });
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 50,
                      activeFillColor: Colors.grey[50],
                      inactiveFillColor: Colors.grey[50],
                      selectedFillColor: Colors.grey[50],
                      activeColor: Color(0xFF004080),
                      inactiveColor: Colors.grey[300],
                      selectedColor: Color(0xFF004080),
                    ),
                    animationType: AnimationType.fade,
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 48),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF004080),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'تحقق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم تستلم الرمز؟ ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: authProvider.isLoading ? null : _resendOTP,
                      child: const Text(
                        'إعادة الإرسال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
