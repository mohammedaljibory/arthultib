import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';

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
  Timer? _cooldownTimer;
  Duration? _remainingCooldown;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _checkCooldownStatus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkCooldownStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cooldown = await authProvider.getRemainingCooldownTime(widget.phoneNumber);

    if (cooldown != null) {
      setState(() {
        _remainingCooldown = cooldown;
        _canResend = false;
      });
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingCooldown != null && _remainingCooldown!.inSeconds > 0) {
          _remainingCooldown = Duration(seconds: _remainingCooldown!.inSeconds - 1);
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
    } else {
      authProvider.verifyOTPAndSignIn(
        smsCode: _currentOTP,
        onSuccess: () {
          Navigator.pushNamedAndRemoveUntil(context, '/store', (route) => false);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
    }
  }

  void _resendOTP() {
    if (!_canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى الانتظار ${_formatDuration(_remainingCooldown!)} قبل إعادة الإرسال'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
        _checkCooldownStatus();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        _checkCooldownStatus();
      },
    );
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
            // Main Content
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Color(0xFF004080)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF004080).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.sms_outlined,
                            size: 40,
                            color: Color(0xFF004080),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Title
                      Text(
                        'التحقق من الهاتف',
                        style: TextStyle(
                          fontSize: isDesktop ? 32 : 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'أرسلنا رمز التحقق إلى',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),

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
                            borderRadius: BorderRadius.circular(8),
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
                      SizedBox(height: 40),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _verifyOTP,
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
                              : Text('تحقق', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('لم تستلم الرمز؟ ', style: TextStyle(color: Colors.grey[600])),
                          if (!_canResend && _remainingCooldown != null)
                            Text(
                              'انتظر ${_formatDuration(_remainingCooldown!)}',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            TextButton(
                              onPressed: authProvider.isLoading || !_canResend ? null : _resendOTP,
                              child: Text('إعادة الإرسال'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right Side (Desktop only)
            if (isDesktop)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF004080), Color(0xFF0066CC)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_outlined,
                          size: 120,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(height: 32),
                        Text(
                          'تحقق آمن',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'نحمي حسابك بأعلى معايير الأمان',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
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
}