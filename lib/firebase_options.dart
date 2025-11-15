// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: dotenv.env['WEB_API_KEY'] ?? '',
        appId: dotenv.env['WEB_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['WEB_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['WEB_PROJECT_ID'] ?? '',
        authDomain: dotenv.env['WEB_AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['WEB_STORAGE_BUCKET'] ?? '',
        measurementId: dotenv.env['WEB_MEASUREMENT_ID'] ?? '',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['ANDROID_API_KEY'] ?? '',
          appId: dotenv.env['ANDROID_APP_ID'] ?? '',
          messagingSenderId: dotenv.env['ANDROID_MESSAGING_SENDER_ID'] ?? '',
          projectId: dotenv.env['ANDROID_PROJECT_ID'] ?? '',
          storageBucket: dotenv.env['ANDROID_STORAGE_BUCKET'] ?? '',
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: dotenv.env['IOS_API_KEY'] ?? '',
          appId: dotenv.env['IOS_APP_ID'] ?? '',
          messagingSenderId: dotenv.env['IOS_MESSAGING_SENDER_ID'] ?? '',
          projectId: dotenv.env['IOS_PROJECT_ID'] ?? '',
          storageBucket: dotenv.env['IOS_STORAGE_BUCKET'] ?? '',
          iosClientId: dotenv.env['IOS_CLIENT_ID'] ?? '',
          iosBundleId: dotenv.env['IOS_BUNDLE_ID'] ?? '',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
