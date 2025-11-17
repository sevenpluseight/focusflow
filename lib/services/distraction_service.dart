import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/distraction_log_model.dart';

class DistractionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveDistractionLog({
    required String category,
    String? note,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final newLogRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('distractionLogs')
        .doc();

    final newLog = DistractionLogModel(
      id: newLogRef.id,
      category: category,
      note: (note?.trim().isEmpty ?? true) ? 'none' : note,
      imageUrl: imageUrl,
      createdAt: Timestamp.now(),
    );

    await newLogRef.set(newLog.toMap());
  }
}
