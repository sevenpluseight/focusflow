import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/models/models.dart';
import 'dart:developer' as developer;
import 'package:focusflow/services/admin_stat_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminStatService _statsService;

  CollectionReference get _users => _firestore.collection('users');

  UserService({AdminStatService? statsService})
    : _statsService = statsService ?? AdminStatService();

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // // ignore: avoid_print
      // print('Error getting user: $e');
      // return null;
      developer.log('Error fetching user', error: e, name: 'UserService');
      rethrow;
    }
  }

  // starts a live connection to users collection
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc))
              .toList();
        });
  }

  // change user role
  // but for now only used for promoting or demoting user/coach
  Future<void> updateUserRole(String uid, String newRole) async {
    final userDocRef = _users.doc(uid);
    final batch = _firestore.batch();
    try {
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      //user as default if left is null
      final oldRole =
          (userDoc.data() as Map<String, dynamic>)['role'] ?? 'user';

      if (oldRole == newRole) return;

      batch.update(userDocRef, {'role': newRole});
      _statsService.updateUserRoleCount(batch, oldRole, newRole);

      await batch.commit();
    } catch (e) {
      developer.log('Error updating user role', error: e, name: 'UserService');
      rethrow;
    }
  }

  // deactivate account
  Future<void> deleteUser(String uid) async {
    final userDocRef = _users.doc(uid);
    final batch = _firestore.batch();
    try {
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      // NOTe: IF LEFT SIDE DOES NOT HAVE ROLE FIELD A USER COUNT WILL BE REDUCED
      final role = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'user';

      batch.delete(userDocRef);
      _statsService.updateUserCount(batch, role, false);

      await batch.commit();
    } catch (e) {
      developer.log('Error deleting user: $e', error: e, name: 'UserService');
      rethrow;
    }
  }
}
