import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDV4JNug9XPo4aroNvSbNdKTjbMLnKipwE',
    appId: '1:794346908127:web:cd8af81940e63451817c6a',
    messagingSenderId: '794346908127',
    projectId: 'myvocabulary-623c8',
    authDomain: 'myvocabulary-623c8.firebaseapp.com',
    storageBucket: 'myvocabulary-623c8.firebasestorage.app',
    measurementId: 'G-4NZSJ3QPRB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDV4JNug9XPo4aroNvSbNdKTjbMLnKipwE',
    appId: '1:794346908127:android:cd8af81940e63451817c6a',
    messagingSenderId: '794346908127',
    projectId: 'myvocabulary-623c8',
    storageBucket: 'myvocabulary-623c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDV4JNug9XPo4aroNvSbNdKTjbMLnKipwE',
    appId: '1:794346908127:ios:cd8af81940e63451817c6a',
    messagingSenderId: '794346908127',
    projectId: 'myvocabulary-623c8',
    storageBucket: 'myvocabulary-623c8.firebasestorage.app',
    iosBundleId: 'com.myvocab.myVocabulary',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDV4JNug9XPo4aroNvSbNdKTjbMLnKipwE',
    appId: '1:794346908127:ios:cd8af81940e63451817c6a',
    messagingSenderId: '794346908127',
    projectId: 'myvocabulary-623c8',
    storageBucket: 'myvocabulary-623c8.firebasestorage.app',
    iosBundleId: 'com.myvocab.myVocabulary',
  );

  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}
