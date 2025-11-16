import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Fetch notifications based on user role (user / coach)
  Stream<List<AppNotification>> getNotificationsStream(String role) {
    return _firestore
        .collection('notifications')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => AppNotification.fromFirestore(d))
          .where((n) => n.target == 'all' || n.target == role)
          .toList();
    });
  }

  /// One-time fetch (if needed)
  Future<void> fetchNotifications(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = await _firestore
          .collection('notifications')
          .orderBy('sentAt', descending: true)
          .get();

      _notifications = query.docs
          .map((d) => AppNotification.fromFirestore(d))
          .where((n) => n.target == 'all' || n.target == role)
          .toList();

    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
