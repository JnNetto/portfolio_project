import 'dart:io';

void main() {
  final apiKey = Platform.environment['FIREBASE_API_KEY'];
  final appId = Platform.environment['FIREBASE_APP_ID'];
  final mensagingSenderId =
      Platform.environment['FIREBASE_MENSSAGING_SENDER_ID'];
  final databaseUrl = Platform.environment['FIREBASE_DATABASE_URL'];
  final projectId = Platform.environment['FIREBASE_PROJECT_ID'];
  final authDomain = Platform.environment['FIREBASE_AUTH_DOMAIN'];
  final storageBucket = Platform.environment['FIREBASE_STORAGE_BUCKET'];
  final measurementId = Platform.environment['FIREBASE_MEASUREMENT_ID'];

  final content = '''
  import 'package:firebase_core/firebase_core.dart';
  
  class DefaultFirebaseOptions {
    static FirebaseOptions get currentPlatform {
      return const FirebaseOptions(
        apiKey: '$apiKey',
        appId: '$appId',
        messagingSenderId: '$mensagingSenderId',
        databaseURL: "$databaseUrl",
        projectId: '$projectId',
        authDomain: '$authDomain',
        storageBucket: '$storageBucket',
        measurementId: '$measurementId',
      );
    }
  }
  ''';

  File('lib/firebase_options.dart').writeAsStringSync(content);
}
