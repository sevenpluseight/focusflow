import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgressModel {
  final String date; // e.g., "2025-11-16"
  final int focusedMinutes;
  final DateTime updatedAt;

  DailyProgressModel({
    required this.date,
    required this.focusedMinutes,
    required this.updatedAt,
  });

  factory DailyProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle updatedAt as Timestamp or String
    final updatedAtRaw = data['updatedAt'];
    DateTime updatedAtDate;

    if (updatedAtRaw is Timestamp) {
      updatedAtDate = updatedAtRaw.toDate();
    } else if (updatedAtRaw is String) {
      updatedAtDate = DateTime.tryParse(updatedAtRaw) ?? DateTime.now();
    } else {
      updatedAtDate = DateTime.now();
    }

    return DailyProgressModel(
      date: data['date'] ?? doc.id,
      focusedMinutes: (data['focusedMinutes'] ?? data['minutes'] ?? 0).toInt(),
      updatedAt: updatedAtDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'focusedMinutes': focusedMinutes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
