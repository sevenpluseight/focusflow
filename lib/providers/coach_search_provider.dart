import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/models.dart';

class CoachSearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _coachSubscription;

  List<CoachRequestModel> _approvedCoaches = [];
  bool _isLoading = true;

  List<CoachRequestModel> get approvedCoaches => _approvedCoaches;
  bool get isLoading => _isLoading;

  void listenToApprovedCoaches() {
    _isLoading = true;
    notifyListeners();

    _coachSubscription?.cancel();
    _coachSubscription = _firestore
        .collection('coachRequests')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((querySnapshot) {
      _approvedCoaches = querySnapshot.docs
          .map((doc) => CoachRequestModel.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error listening to coaches: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _coachSubscription?.cancel();
    super.dispose();
  }
}
