import 'package:cloud_firestore/cloud_firestore.dart';

class CoachRequestModel {
  final String id;
  final String userId;
  final String username;
  final String fullName;
  final String expertise;
  final String bio;
  final String? portfolioLink;
  final String status; // 'pending'
  final Timestamp createdAt;

  CoachRequestModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.expertise,
    required this.bio,
    this.portfolioLink,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'expertise': expertise,
      'bio': bio,
      'portfolioLink': portfolioLink,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory CoachRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachRequestModel(
      id: doc.id, // Use doc.id for the document ID
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      expertise: data['expertise'] ?? '',
      bio: data['bio'] ?? '',
      portfolioLink: data['portfolioLink'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}