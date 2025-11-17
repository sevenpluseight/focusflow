import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/mood_log_model.dart';
import 'package:intl/intl.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper: Today key in 'yyyy-MM-dd' format
  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> saveMoodLog(MoodLogModel moodLog) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final todayKey = _todayKey();
    final dailyDocRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('dailyProgress')
        .doc(todayKey);

    // Use the sessionId as the key in a nested map
    final moodData = {
      'moods.${moodLog.sessionId}': {
        'moodChosen': moodLog.moodChosen,
        'notes': moodLog.notes,
        'createdAt': moodLog.createdAt,
      }
    };

    // Use SetOptions(merge: true) to update the document without overwriting
    await dailyDocRef.set(moodData, SetOptions(merge: true));
  }
}
