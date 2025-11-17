import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { cheer, guide, text }

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

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      coachId: data['coachId'] ?? '',
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      type: _stringToMessageType(data['type']),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  static MessageType _stringToMessageType(String? typeStr) {
    switch (typeStr) {
      case 'cheer':
        return MessageType.cheer;
      case 'guide':
        return MessageType.guide;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'userId': userId,
      'text': text,
      'type': type.toString().split('.').last,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}
