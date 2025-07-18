
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Get user-specific pricing based on user type
  double getUserPrice(Map<String, dynamic> pricing) {
    if (_currentUser == null) return pricing['public']?.toDouble() ?? 0;

    switch (_currentUser!.userType) {
      case 'wholesale':
        return pricing['wholesale']?.toDouble() ?? pricing['public']?.toDouble() ?? 0;
      case 'vip':
        return pricing['vip']?.toDouble() ?? pricing['public']?.toDouble() ?? 0;
      case 'special':
        return pricing['special']?.toDouble() ?? pricing['public']?.toDouble() ?? 0;
      default:
        return pricing['public']?.toDouble() ?? 0;
    }
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  // Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _isLoading = false;
        notifyListeners();
        onCodeSent(verificationId);
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        onError(error);
      },
    );
  }

  // Verify OTP for sign up
  Future<void> verifyOTPAndSignUp({
    required String smsCode,
    required String name,
    required String phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    if (_verificationId == null) {
      onError('معرف التحقق غير موجود');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      if (credential?.user != null) {
        // Create user in Firestore
        await _authService.createUser(
          uid: credential!.user!.uid,
          name: name,
          phoneNumber: phoneNumber,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );

        // Load user data
        await _loadUserData(credential.user!.uid);

        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  // Verify OTP for sign in
  Future<void> verifyOTPAndSignIn({
    required String smsCode,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    if (_verificationId == null) {
      onError('معرف التحقق غير موجود');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      if (credential?.user != null) {
        // Update last login
        await _authService.updateLastLogin(credential!.user!.uid);

        // Load user data
        await _loadUserData(credential.user!.uid);

        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    return await _authService.checkUserExists(phoneNumber);
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _verificationId = null;
    notifyListeners();
  }

  // Update user in provider after profile changes
  void updateCurrentUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Add item to favorites
  Future<void> addToFavorites(String itemId) async {
    if (_currentUser == null) return;

    final updatedFavorites = [..._currentUser!.savedItems, itemId];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'savedItems': updatedFavorites});

    _currentUser = _currentUser!.copyWith(savedItems: updatedFavorites);
    notifyListeners();
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String itemId) async {
    if (_currentUser == null) return;

    final updatedFavorites = _currentUser!.savedItems
        .where((id) => id != itemId)
        .toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'savedItems': updatedFavorites});

    _currentUser = _currentUser!.copyWith(savedItems: updatedFavorites);
    notifyListeners();
  }

  // Check if item is favorite
  bool isFavorite(String itemId) {
    return _currentUser?.savedItems.contains(itemId) ?? false;
  }
}
