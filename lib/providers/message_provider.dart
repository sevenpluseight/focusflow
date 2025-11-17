import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/models.dart';

class MessageProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> messagesStream(String userId, String coachId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .where('coachId', isEqualTo: coachId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }
}
