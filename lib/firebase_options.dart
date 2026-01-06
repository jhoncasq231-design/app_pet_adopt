/*
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDXvjQlALWAFXdF5_5mG7Y8z9z_9z9z9z9',
    appId: '1:123456789:web:abcdefghijklmnopqrst',
    messagingSenderId: '123456789',
    projectId: 'pet-adopt-project',
    authDomain: 'pet-adopt-project.firebaseapp.com',
    storageBucket: 'pet-adopt-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXvjQlALWAFXdF5_5mG7Y8z9z_9z9z9z9',
    appId: '1:123456789:android:abcdefghijklmnopqrst',
    messagingSenderId: '123456789',
    projectId: 'pet-adopt-project',
    storageBucket: 'pet-adopt-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXvjQlALWAFXdF5_5mG7Y8z9z_9z9z9z9',
    appId: '1:123456789:ios:abcdefghijklmnopqrst',
    messagingSenderId: '123456789',
    projectId: 'pet-adopt-project',
    storageBucket: 'pet-adopt-project.appspot.com',
    iosBundleId: 'com.example.appPetAdopt',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDXvjQlALWAFXdF5_5mG7Y8z9z_9z9z9z9',
    appId: '1:123456789:macos:abcdefghijklmnopqrst',
    messagingSenderId: '123456789',
    projectId: 'pet-adopt-project',
    storageBucket: 'pet-adopt-project.appspot.com',
    iosBundleId: 'com.example.appPetAdopt',
  );
}
*/

// DESACTIVADO: Firebase se habilitará cuando tengas configurado el proyecto
class DefaultFirebaseOptions {}
