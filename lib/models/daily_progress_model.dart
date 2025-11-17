import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgressModel {
  final String date; // e.g., "2025-11-16"
  final int focusedMinutes;
  final DateTime updatedAt;
  final Map<String, dynamic>? moods; // Added moods map

  DailyProgressModel({
    required this.date,
    required this.focusedMinutes,
    required this.updatedAt,
    this.moods, // Added to constructor
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
      moods: data['moods'] as Map<String, dynamic>?, // Read moods from data
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'focusedMinutes': focusedMinutes,
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (moods != null) 'moods': moods, // Include moods if not null
    };
  }
}
