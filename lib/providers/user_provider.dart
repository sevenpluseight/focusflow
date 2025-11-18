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

  // 🔥 NEW: Tracks when first user snapshot is received
  Completer<bool>? _initialLoadCompleter;

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
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  // -------------------------------------------
  // 🔥 FIXED: fetchUser now WAITS for Firestore
  // -------------------------------------------
  Future<bool> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    _setLoading(true);

    // Reset completer every fetch
    _initialLoadCompleter = Completer<bool>();

    try {
      // Listen to connection requests
      listenToPendingRequests();

      // Cancel previous listener
      _userDocSubscription?.cancel();

      _userDocSubscription = _firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((doc) async {
        if (!doc.exists) return;

        // Parse user data
        _user = UserModel.fromFirestore(doc);

        // Fetch connected coach (if any)
        if (_user?.coachId != null && _user!.coachId!.isNotEmpty) {
          final coachDoc = await _firestore
              .collection('coachRequests')
              .doc(_user!.coachId)
              .get();

          _connectedCoach = coachDoc.exists
              ? CoachRequestModel.fromFirestore(coachDoc)
              : null;
        } else {
          _connectedCoach = null;
        }

        // FIRST snapshot received → complete!
        if (_initialLoadCompleter != null &&
            !_initialLoadCompleter!.isCompleted) {
          _initialLoadCompleter!.complete(true);
        }

        _safeNotifyListeners();
      });

      // Wait for first snapshot (or timeout)
      final result = await _initialLoadCompleter!.future;
      return result;
    } catch (e) {
      if (_initialLoadCompleter != null &&
          !_initialLoadCompleter!.isCompleted) {
        _initialLoadCompleter!.complete(false);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------------------------
  // Listen to Pending Connection Requests
  // -------------------------------------------
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
      _pendingCoachIds =
          snapshot.docs.map((doc) => doc['coachId'] as String).toList();

      _safeNotifyListeners();
    });
  }

  // -------------------------------------------
  // Create User
  // -------------------------------------------
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

    batch.set(userDoc, newUser.toMap(), SetOptions(merge: true));
    await batch.commit();

    _user = newUser;
    _safeNotifyListeners();
  }

  // -------------------------------------------
  // Update User Streak
  // -------------------------------------------
  Future<void> updateStreak() async {
    if (_user == null) return;

    final userRef = _firestore.collection('users').doc(_user!.uid);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastFocusDate = _user!.lastFocusDate?.toDate();
    int current = _user!.currentStreak ?? 0;
    int longest = _user!.longestStreak ?? 0;

    if (lastFocusDate != null) {
      final diff = today.difference(lastFocusDate).inDays;
      if (diff == 1) {
        current += 1;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    } else {
      current = 1;
      longest = 1;
    }

    await userRef.update({
      'currentStreak': current,
      'longestStreak': longest,
      'lastFocusDate': today,
    });
  }

  // -------------------------------------------
  // Update Settings
  // -------------------------------------------
  Future<void> updateSettings({
    double? dailyTargetHours,
    int? workInterval,
    int? breakInterval,
    String? focusType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (dailyTargetHours != null) updates['dailyTargetHours'] = dailyTargetHours;
    if (workInterval != null) updates['workInterval'] = workInterval;
    if (breakInterval != null) updates['breakInterval'] = breakInterval;
    if (focusType != null) updates['focusType'] = focusType;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }

  // -------------------------------------------
  // Submit Coach Application
  // -------------------------------------------
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

      if ((await newRequestRef.get()).exists) {
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
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------------------------
  // Send Connection Request
  // -------------------------------------------
  Future<void> sendConnectionRequest(String coachId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_user == null || uid == null) {
      throw Exception('User not logged in.');
    }

    _setLoading(true);

    try {
      final existing = await _firestore
          .collection('connectionRequests')
          .where('userId', isEqualTo: uid)
          .where('coachId', isEqualTo: coachId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('You already sent a request to this coach.');
      }

      await _firestore.collection('connectionRequests').add({
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
    } finally {
      _setLoading(false);
    }
  }

  // -------------------------------------------
  // Chat Messages Stream
  // -------------------------------------------
  Stream<List<MessageModel>> getMessagesStream(String coachId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    final ids = [uid, coachId]..sort();
    final chatId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }
}
