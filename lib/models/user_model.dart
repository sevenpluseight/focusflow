import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  final String signInMethod;
  final Timestamp createdAt;
  final double? dailyTargetHours;
  final int? workInterval;
  final int? breakInterval;
  final String? focusType;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.signInMethod,
    required this.createdAt,
    this.dailyTargetHours,
    this.workInterval,
    this.breakInterval,
    this.focusType,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      signInMethod: data['signInMethod'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      dailyTargetHours: _toDouble(data['dailyTargetHours']),
      workInterval: _toInt(data['workInterval']),
      breakInterval: _toInt(data['breakInterval']),
      focusType: data['focusType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'signInMethod': signInMethod,
      'createdAt': createdAt,
      'dailyTargetHours': dailyTargetHours,
      'workInterval': workInterval,
      'breakInterval': breakInterval,
      'focusType': focusType,
    };
  }

  /// Add copyWith for safe updates
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    String? signInMethod,
    Timestamp? createdAt,
    double? dailyTargetHours,
    int? workInterval,
    int? breakInterval,
    String? focusType,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      signInMethod: signInMethod ?? this.signInMethod,
      createdAt: createdAt ?? this.createdAt,
      dailyTargetHours: dailyTargetHours ?? this.dailyTargetHours,
      workInterval: workInterval ?? this.workInterval,
      breakInterval: breakInterval ?? this.breakInterval,
      focusType: focusType ?? this.focusType,
    );
  }

  // Helpers to handle type safety for Firestore data
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}
