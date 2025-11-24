import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Rate limiting constants
  static const int MAX_OTP_ATTEMPTS = 3;
  static const Duration OTP_COOLDOWN_PERIOD = Duration(minutes: 15);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Add this method to auth_provider.dart
  Future<void> updateUserAddress({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'lastAddressUpdate': FieldValue.serverTimestamp(),
      });

      // Update local user object
      _currentUser = _currentUser!.copyWith(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      notifyListeners();
    } catch (e) {
      print('Error updating address: $e');
      throw e;
    }
  }

  // Add this method to auth_provider.dart (after line 50)
  UserModel? createTemporaryUserWithAddress({
    required String address,
    double? latitude,
    double? longitude,
  }) {
    if (_currentUser == null) return null;

    // Create a temporary user model with new address without saving to database
    return _currentUser!.copyWith(
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

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

  // Check rate limit before sending OTP
  Future<bool> _checkRateLimit(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved attempts
    final attempts = prefs.getInt('otp_attempts_$phoneNumber') ?? 0;
    final lastTimeString = prefs.getString('otp_last_time_$phoneNumber');
    DateTime? lastTime;

    if (lastTimeString != null) {
      lastTime = DateTime.parse(lastTimeString);
    }

    // Check if in cooldown period
    if (lastTime != null && attempts >= MAX_OTP_ATTEMPTS) {
      final timeSinceLastAttempt = DateTime.now().difference(lastTime);
      if (timeSinceLastAttempt < OTP_COOLDOWN_PERIOD) {
        final remainingTime = OTP_COOLDOWN_PERIOD - timeSinceLastAttempt;
        throw Exception(
            'تم تجاوز عدد المحاولات المسموح. حاول مرة أخرى بعد ${remainingTime.inMinutes} دقيقة'
        );
      } else {
        // Reset attempts after cooldown
        await prefs.setInt('otp_attempts_$phoneNumber', 0);
      }
    }

    return true;
  }

  // Update OTP attempts
  Future<void> _updateOtpAttempts(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();

    final attempts = prefs.getInt('otp_attempts_$phoneNumber') ?? 0;
    await prefs.setInt('otp_attempts_$phoneNumber', attempts + 1);
    await prefs.setString('otp_last_time_$phoneNumber', DateTime.now().toIso8601String());
  }

  // Send OTP with rate limiting
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check rate limit
      await _checkRateLimit(phoneNumber);

      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) async {
          _verificationId = verificationId;

          // Update attempts count
          await _updateOtpAttempts(phoneNumber);

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
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
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

  // Reset rate limit for a phone number
  Future<void> resetRateLimit(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp_attempts_$phoneNumber');
    await prefs.remove('otp_last_time_$phoneNumber');
  }

  // Get remaining cooldown time
  Future<Duration?> getRemainingCooldownTime(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();

    final attempts = prefs.getInt('otp_attempts_$phoneNumber') ?? 0;
    final lastTimeString = prefs.getString('otp_last_time_$phoneNumber');

    if (attempts >= MAX_OTP_ATTEMPTS && lastTimeString != null) {
      final lastTime = DateTime.parse(lastTimeString);
      final timeSinceLastAttempt = DateTime.now().difference(lastTime);

      if (timeSinceLastAttempt < OTP_COOLDOWN_PERIOD) {
        return OTP_COOLDOWN_PERIOD - timeSinceLastAttempt;
      }
    }

    return null;
  }
}