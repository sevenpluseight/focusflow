import 'package:cloud_firestore/cloud_firestore.dart';

class DistractionLogModel {
  final String id;
  final String category;
  final String? note; 
  final String? imageUrl;
  final Timestamp createdAt;

  DistractionLogModel({
    required this.id,
    required this.category,
    this.note,
    this.imageUrl,
    required this.createdAt,
  });

  factory DistractionLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DistractionLogModel(
      id: doc.id,
      category: data['category'] ?? 'Unknown',
      note: data['note'],
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}