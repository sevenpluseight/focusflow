import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/models.dart';

class CoachProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _connectedUsers = [];
  bool _isLoading = false;

  List<UserModel> get connectedUsers => _connectedUsers;
  bool get isLoading => _isLoading;

  /// Fetches all users from Firestore where the 'coachId' matches the currently logged-in coach's UID.
  Future<void> fetchConnectedUsers(String coachId) async {
    if (coachId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // This is the query that uses the 'coachId' field
      final querySnapshot = await _firestore
          .collection('users')
          .where('coachId', isEqualTo: coachId)
          .get();
      
      _connectedUsers = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

    } catch (e) {
      print('Error fetching connected users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}