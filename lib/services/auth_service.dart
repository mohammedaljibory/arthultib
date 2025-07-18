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
        // For web platform - simple approach
        try {
          _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
          onCodeSent('web-verification');
        } catch (e) {
          onError('خطأ في إرسال رمز التحقق: ${e.toString()}');
        }
      } else {
        // For mobile platforms (iOS/Android)
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-sign in on Android devices
            try {
              await _auth.signInWithCredential(credential);
            } catch (e) {
              print('Auto sign-in error: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              onError('رقم الهاتف غير صحيح');
            } else if (e.code == 'too-many-requests') {
              onError('تم تجاوز عدد المحاولات المسموح. حاول لاحقاً');
            } else if (e.code == 'missing-client-identifier') {
              onError('يرجى التحقق من إعدادات Firebase');
            } else if (e.code == 'app-not-authorized') {
              onError('التطبيق غير مصرح له باستخدام Firebase Authentication');
            } else {
              onError(e.message ?? 'فشل التحقق');
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-retrieval timeout
            print('Auto retrieval timeout');
          },
        );
      }
    } catch (e) {
      onError('خطأ: ${e.toString()}');
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (kIsWeb && _webConfirmationResult != null) {
        // For web, use the stored confirmation result
        return await _webConfirmationResult!.confirm(smsCode);
      } else {
        // For mobile platforms
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
    _webConfirmationResult = null;
  }
}