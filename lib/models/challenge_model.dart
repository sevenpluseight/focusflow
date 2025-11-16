import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String name;
  final int focusGoalHours;
  final String description;
  final String coachId;
  final Timestamp createdAt;
  final String status; // "pending", "approved", "rejected"
  final Timestamp? startDate;
  final Timestamp? endDate;
  final List<String> participants;

  ChallengeModel({
    required this.id,
    required this.name,
    required this.focusGoalHours,
    required this.description,
    required this.coachId,
    required this.createdAt,
    this.status = 'pending',
    this.startDate,
    this.endDate,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'focusGoalHours': focusGoalHours,
      'description': description,
      'coachId': coachId,
      'createdAt': createdAt,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'participants': participants,
    };
  }
  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChallengeModel(
      id: doc.id,
      name: data['name'] ?? '',
      focusGoalHours: (data['focusGoalHours'] as num? ?? 0).toInt(),
      description: data['description'] ?? '',
      coachId: data['coachId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      startDate: data['startDate'] as Timestamp?, 
      endDate: data['endDate'] as Timestamp?,
      participants: (data['participants'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

}
