// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store confirmation result for web
  ConfirmationResult? _webConfirmationResult;

  // Stream to track authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      if (kIsWeb) {
        _webConfirmationResult = null;
        print('Starting web phone authentication for: $phoneNumber');

        try {
          // Firebase SDK will use the recaptchaVerifier from index.html automatically
          _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);

          if (_webConfirmationResult == null) {
            throw Exception('Failed to initiate phone authentication');
          }

          print('SMS sent successfully');
          onCodeSent(_webConfirmationResult!.verificationId);
        } catch (e) {
          if (e.toString().contains('captcha-check-failed')) {
            throw Exception('التحقق من reCAPTCHA فشل. حاول مرة أخرى');
          }
          throw e;
        }
      } else {
        // Mobile implementation stays the same
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              onError('رقم الهاتف غير صحيح');
            } else if (e.code == 'too-many-requests') {
              onError('تم تجاوز عدد المحاولات المسموح. حاول لاحقاً');
            } else {
              onError(e.message ?? 'فشل التحقق');
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      String errorMessage = 'خطأ في إرسال رمز التحقق';

      if (e.toString().contains('reCAPTCHA')) {
        errorMessage = 'يرجى تحديث الصفحة والمحاولة مرة أخرى';
      } else if (e.toString().contains('invalid-phone-number')) {
        errorMessage = 'رقم الهاتف غير صحيح';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'تم تجاوز عدد المحاولات. حاول بعد قليل';
      } else if (e.toString().contains('captcha')) {
        errorMessage = 'فشل التحقق الأمني. يرجى تحديث الصفحة';
      }

      onError(errorMessage);
      print('Send OTP error: $e');
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (kIsWeb && _webConfirmationResult != null) {
        return await _webConfirmationResult!.confirm(smsCode);
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('رمز التحقق غير صحيح');
      } else if (e.code == 'invalid-verification-id') {
        throw Exception('معرف التحقق غير صحيح. حاول مرة أخرى');
      } else if (e.code == 'session-expired') {
        throw Exception('انتهت صلاحية الجلسة. حاول مرة أخرى');
      }
      throw Exception('خطأ في التحقق: ${e.message}');
    } catch (e) {
      throw Exception('خطأ: ${e.toString()}');
    }
  }

  // Create new user in Firestore
  Future<void> createUser({
    required String uid,
    required String name,
    required String phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        latitude: latitude,
        longitude: longitude,
        savedItems: [],
        userType: 'public', // Default user type
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
    } catch (e) {
      throw Exception('فشل إنشاء المستخدم: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('فشل جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('فشل تحديث آخر تسجيل دخول: $e');
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _webConfirmationResult = null; // Clear web confirmation on sign out
  }
}