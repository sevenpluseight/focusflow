import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgressModel {
  final String date;
  final int focusedMinutes;
  final int dailyTargetMinutes;
  final double progress;
  final Timestamp updatedAt;

  DailyProgressModel({
    required this.date,
    required this.focusedMinutes,
    required this.dailyTargetMinutes,
    required this.progress,
    required this.updatedAt,
  });

  factory DailyProgressModel.fromMap(Map<String, dynamic> data) {
    return DailyProgressModel(
      date: data['date'] ?? '',
      focusedMinutes: (data['focusedMinutes'] ?? 0).toInt(),
      dailyTargetMinutes: (data['dailyTargetMinutes'] ?? 0).toInt(),
      progress: (data['progress'] ?? 0.0).toDouble(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'focusedMinutes': focusedMinutes,
      'dailyTargetMinutes': dailyTargetMinutes,
      'progress': progress,
      'updatedAt': updatedAt,
    };
  }
}
