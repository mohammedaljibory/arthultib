import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Update user address
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

  // Create temporary user with address
  UserModel? createTemporaryUserWithAddress({
    required String address,
    double? latitude,
    double? longitude,
  }) {
    if (_currentUser == null) return null;

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

  // Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update last login
        await _authService.updateLastLogin(credential.user!.uid);

        // Load user data
        await _loadUserData(credential.user!.uid);

        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user in Firestore
        await _authService.createUser(
          uid: credential.user!.uid,
          name: name,
          email: email,
          address: address,
          latitude: latitude,
          longitude: longitude,
          authProvider: 'email',
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
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle({
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential == null) {
        // User cancelled
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (credential.user != null) {
        final user = credential.user!;

        // Check if user exists in Firestore
        bool userExists = await _authService.checkUserExistsByUid(user.uid);

        if (!userExists) {
          // Create new user in Firestore
          await _authService.createUser(
            uid: user.uid,
            name: user.displayName ?? 'مستخدم جديد',
            email: user.email,
            authProvider: 'google',
          );
        } else {
          // Update last login
          await _authService.updateLastLogin(user.uid);
        }

        // Load user data
        await _loadUserData(user.uid);

        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Check if user exists by email
  Future<bool> checkUserExistsByEmail(String email) async {
    return await _authService.checkUserExistsByEmail(email);
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
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
