// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Stream to track authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile implementation
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null; // User cancelled
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بواسطة Google: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create new user in Firestore
  Future<void> createUser({
    required String uid,
    required String name,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String authProvider = 'email',
  }) async {
    try {
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        latitude: latitude,
        longitude: longitude,
        savedItems: [],
        userType: 'public',
        authProvider: authProvider,
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

  // Check if user exists by email
  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if user exists by UID
  Future<bool> checkUserExistsByUid(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions with Arabic messages
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
        break;
      case 'wrong-password':
        message = 'كلمة المرور غير صحيحة';
        break;
      case 'email-already-in-use':
        message = 'البريد الإلكتروني مستخدم بالفعل';
        break;
      case 'invalid-email':
        message = 'البريد الإلكتروني غير صالح';
        break;
      case 'weak-password':
        message = 'كلمة المرور ضعيفة جداً. يجب أن تكون 6 أحرف على الأقل';
        break;
      case 'too-many-requests':
        message = 'تم تجاوز عدد المحاولات. حاول لاحقاً';
        break;
      case 'user-disabled':
        message = 'تم تعطيل هذا الحساب';
        break;
      case 'operation-not-allowed':
        message = 'هذه العملية غير مسموحة';
        break;
      case 'account-exists-with-different-credential':
        message = 'يوجد حساب بنفس البريد الإلكتروني بطريقة تسجيل مختلفة';
        break;
      case 'invalid-credential':
        message = 'بيانات الاعتماد غير صالحة';
        break;
      case 'network-request-failed':
        message = 'فشل الاتصال بالشبكة. تحقق من اتصالك بالإنترنت';
        break;
      default:
        message = e.message ?? 'حدث خطأ غير متوقع';
    }
    return Exception(message);
  }
}
