import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionRequestModel {
  final String id;
  final String userId;
  final String username;
  final String coachId;
  final String status; // 'pending'
  final Timestamp createdAt;

  ConnectionRequestModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.coachId,
    this.status = 'pending',
    required this.createdAt,
  });
  
  factory ConnectionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConnectionRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      coachId: data['coachId'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}