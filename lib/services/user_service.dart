import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/screens/main_navigation_controller.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get(const GetOptions(source: Source.server));
      if (doc.exists && doc.data()!.containsKey('role')) {
        final roleString = doc.data()!['role'] as String;
        return UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString,
          orElse: () => UserRole.user,
        );
      }
      return UserRole.user;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user role: $e');
      return UserRole.user;
    }
  }
}
