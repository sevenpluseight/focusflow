import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime sentAt;
  final String target; // all, coach, user

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.target,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Notification document ${doc.id} has no data.");
    }

    return AppNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      target: data['target']?.toString() ?? 'all',
    );
  }
}
