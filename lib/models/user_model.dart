
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> savedItems; // Favorite product IDs
  final String userType; // 'public', 'wholesale', 'vip', 'special'
  final String authProvider; // 'email', 'google', 'phone'
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    required this.savedItems,
    this.userType = 'public',
    this.authProvider = 'email',
    required this.createdAt,
    required this.lastLogin,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'savedItems': savedItems,
      'userType': userType,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      savedItems: List<String>.from(map['savedItems'] ?? []),
      userType: map['userType'] ?? 'public',
      authProvider: map['authProvider'] ?? 'email',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? savedItems,
    DateTime? lastLogin,
    String? userType,
    String? authProvider,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      savedItems: savedItems ?? this.savedItems,
      userType: userType ?? this.userType,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
