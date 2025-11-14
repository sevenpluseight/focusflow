import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { cheer, guide }

class MessageModel {
  final String id;
  final String coachId;
  final String userId;
  final String text;
  final MessageType type;
  final Timestamp createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.coachId,
    required this.userId,
    required this.text,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'userId': userId,
      'text': text,
      'type': type.toString().split('.').last, // 'cheer' or 'guide'
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}