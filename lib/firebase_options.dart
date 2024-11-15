// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6yuNHqEJwrjkRfsOu_hx6WFALdz3xG2o',
    appId: '1:311835153173:web:b790e32121f21f219e4f1c',
    messagingSenderId: '311835153173',
    projectId: 'taskcw6-d1f51',
    authDomain: 'taskcw6-d1f51.firebaseapp.com',
    storageBucket: 'taskcw6-d1f51.firebasestorage.app',
    measurementId: 'G-TS06HZ7YLD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdUQmC9IWP7pNFJoxGrKTmmfHP0khpWdk',
    appId: '1:311835153173:android:4f7299d22156d3ff9e4f1c',
    messagingSenderId: '311835153173',
    projectId: 'taskcw6-d1f51',
    storageBucket: 'taskcw6-d1f51.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxMLbvn_XRX_zR2CsU557ZmyITgJQ9Tgo',
    appId: '1:311835153173:ios:aa5d78d04cab5f0f9e4f1c',
    messagingSenderId: '311835153173',
    projectId: 'taskcw6-d1f51',
    storageBucket: 'taskcw6-d1f51.firebasestorage.app',
    iosBundleId: 'com.example.taskcw6',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxMLbvn_XRX_zR2CsU557ZmyITgJQ9Tgo',
    appId: '1:311835153173:ios:aa5d78d04cab5f0f9e4f1c',
    messagingSenderId: '311835153173',
    projectId: 'taskcw6-d1f51',
    storageBucket: 'taskcw6-d1f51.firebasestorage.app',
    iosBundleId: 'com.example.taskcw6',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6yuNHqEJwrjkRfsOu_hx6WFALdz3xG2o',
    appId: '1:311835153173:web:c017c837e39c7eff9e4f1c',
    messagingSenderId: '311835153173',
    projectId: 'taskcw6-d1f51',
    authDomain: 'taskcw6-d1f51.firebaseapp.com',
    storageBucket: 'taskcw6-d1f51.firebasestorage.app',
    measurementId: 'G-6JEMN8B8L4',
  );
}
