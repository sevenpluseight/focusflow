import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

enum NotificationFilter { all, week, month, year }

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  NotificationFilter _selectedFilter = NotificationFilter.all;
  NotificationFilter get selectedFilter => _selectedFilter;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void updateFilter(NotificationFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

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

  // no filter for role
  Stream<List<AppNotification>> getAllNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((d) => AppNotification.fromFirestore(d))
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
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendNotification({
    required String title,
    required String message,
    required String target,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'target': target,
        'sentAt': FieldValue.serverTimestamp(), // Use server time
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error sending notification: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
