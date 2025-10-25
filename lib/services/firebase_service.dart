// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:focusflow/firebase_options.dart';

// class FirebaseService {
//   static Future<void> initializeFirebase() async {
//     await dotenv.load(fileName: ".env");
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:focusflow/firebase_options.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await dotenv.load(fileName: ".env");

    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
