import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String name;
  final int durationDays;
  final int focusGoalHours;
  final String description;
  final String coachId;
  final Timestamp createdAt;
  final String status; // "pending", "approved", "rejected"

  ChallengeModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.focusGoalHours,
    required this.description,
    required this.coachId,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'durationDays': durationDays,
      'focusGoalHours': focusGoalHours,
      'description': description,
      'coachId': coachId,
      'createdAt': createdAt,
      'status': status,
    };
  }
}