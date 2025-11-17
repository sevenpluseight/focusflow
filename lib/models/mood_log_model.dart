import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLogModel {
  final String? id;
  final String moodChosen;
  final String? notes;
  final DateTime createdAt;
  final String sessionId;

  MoodLogModel({
    this.id,
    required this.moodChosen,
    this.notes,
    required this.createdAt,
    required this.sessionId,
  });

  factory MoodLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodLogModel(
      id: doc.id,
      moodChosen: data['moodChosen'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sessionId: data['sessionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moodChosen': moodChosen,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'sessionId': sessionId,
    };
  }
}
