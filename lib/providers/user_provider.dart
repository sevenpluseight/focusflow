import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/services.dart';

class UserProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final AdminStatService _statsService;

  UserProvider({AdminStatService? statsService})
    : _statsService = statsService ?? AdminStatService();

  UserModel? _user;
  CoachRequestModel? _connectedCoach;
  bool _isLoading = false;
  StreamSubscription? _pendingRequestsSubscription;
  StreamSubscription? _userDocSubscription;
  List<String> _pendingCoachIds = [];

  UserModel? get user => _user;
  CoachRequestModel? get connectedCoach => _connectedCoach;
  bool get isLoading => _isLoading;
  List<String> get pendingCoachIds => _pendingCoachIds;

  @override
  void dispose() {
    _pendingRequestsSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    // Delay notifyListeners to avoid calling during build
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  Future<void> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _setLoading(true);
    try {
      listenToPendingRequests(); // Start listening
      _userDocSubscription?.cancel(); // Cancel previous subscription if any
      _userDocSubscription = _firestore.collection('users').doc(uid).snapshots().listen((doc) async {
        if (doc.exists) {
          _user = UserModel.fromFirestore(doc);
          // If user has a coach, fetch the coach's details
          if (_user?.coachId != null && _user!.coachId!.isNotEmpty) {
            final coachDoc = await _firestore
                .collection('coachRequests')
                .doc(_user!.coachId)
                .get();
            if (coachDoc.exists) {
              _connectedCoach = CoachRequestModel.fromFirestore(coachDoc);
            } else {
              _connectedCoach = null;
            }
          } else {
            _connectedCoach = null;
          }
          _safeNotifyListeners();
        }
      });
    } finally {
      _setLoading(false);
    }
  }

  void listenToPendingRequests() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _pendingRequestsSubscription?.cancel();
    _pendingRequestsSubscription = _firestore
        .collection('connectionRequests')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _pendingCoachIds = snapshot.docs.map((doc) => doc['coachId'] as String).toList();
      _safeNotifyListeners();
    });
  }

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
    required double dailyTargetHours,
    required int workInterval,
    required int breakInterval,
    required String focusType,
  }) async {
    final batch = _firestore.batch();
    final userDoc = _firestore.collection('users').doc(uid);

    final newUser = UserModel(
      uid: uid,
      username: username,
      email: email,
      role: 'user',
      signInMethod: 'email',
      createdAt: Timestamp.now(),
      dailyTargetHours: dailyTargetHours,
      workInterval: workInterval,
      breakInterval: breakInterval,
      focusType: focusType,
      currentStreak: 0,
      longestStreak: 0,
      lastFocusDate: null,
    );

    // create the new user
    batch.set(userDoc, newUser.toMap(), SetOptions(merge: true));
    _statsService.updateUserCount(batch, 'user', true);

    await batch.commit();

    // loca state update
    _user = newUser;
    _safeNotifyListeners();
  }

  Future<void> updateStreak() async {
    if (_user == null) return;
    final userRef = _firestore.collection('users').doc(_user!.uid);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastFocusDate = _user!.lastFocusDate?.toDate();
    int currentStreak = _user!.currentStreak ?? 0;
    int longestStreak = _user!.longestStreak ?? 0;

    if (lastFocusDate != null) {
      final diff = today.difference(lastFocusDate).inDays;
      if (diff == 1) {
        currentStreak += 1;
        longestStreak = currentStreak > longestStreak
            ? currentStreak
            : longestStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
      longestStreak = 1;
    }

    await userRef.update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastFocusDate': today,
    });

    await fetchUser();
  }

  Future<void> updateSettings({
    double? dailyTargetHours,
    int? workInterval,
    int? breakInterval,
    String? focusType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (dailyTargetHours != null)
      updates['dailyTargetHours'] = dailyTargetHours;
    if (workInterval != null) updates['workInterval'] = workInterval;
    if (breakInterval != null) updates['breakInterval'] = breakInterval;
    if (focusType != null) updates['focusType'] = focusType;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
      // No need to call fetchUser() here, as the listener will handle it
    }
  }

  Future<void> submitCoachApplication({
    required String fullName,
    required String expertise,
    required String bio,
    String? portfolioLink,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_user == null || uid == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      final newRequestRef = _firestore.collection('coachRequests').doc(uid);

      // Check if a request already exists
      final doc = await newRequestRef.get();
      if (doc.exists) {
        throw Exception('You already have a pending application.');
      }

      final newRequest = CoachRequestModel(
        id: newRequestRef.id,
        userId: uid,
        username: _user!.username,
        fullName: fullName,
        expertise: expertise,
        bio: bio,
        portfolioLink: portfolioLink,
        createdAt: Timestamp.now(),
      );

      await newRequestRef.set(newRequest.toMap());
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendConnectionRequest(String coachId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_user == null || uid == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);
    try {
      final requestQuery = await _firestore
          .collection('connectionRequests')
          .where('userId', isEqualTo: uid)
          .where('coachId', isEqualTo: coachId)
          .limit(1)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        throw Exception('You have already sent a request to this coach.');
      }

      final newRequestRef = _firestore.collection('connectionRequests').doc();
      await newRequestRef.set({
        'coachId': coachId,
        'userId': uid,
        'username': _user!.username,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (!_pendingCoachIds.contains(coachId)) {
        _pendingCoachIds.add(coachId);
        _safeNotifyListeners();
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String coachId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    // Canonical chat ID
    final ids = [uid, coachId]..sort();
    final chatId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }
}
