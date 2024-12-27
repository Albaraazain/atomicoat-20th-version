import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebasePlatform extends FirebasePlatform with MockPlatformInterfaceMixin {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
  }

  @override
  List<FirebaseAppPlatform> get apps => <FirebaseAppPlatform>[];
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform with MockPlatformInterfaceMixin {
  MockFirebaseAppPlatform() : super(defaultFirebaseAppName, FirebaseOptions(
    apiKey: '123',
    appId: '123',
    messagingSenderId: '123',
    projectId: '123',
  ));

  @override
  String get name => '[DEFAULT]';

  @override
  Future<void> delete() async {}

  @override
  bool get isAutomaticDataCollectionEnabled => true;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  FirebaseOptions get options => FirebaseOptions(
    apiKey: '123',
    appId: '123',
    messagingSenderId: '123',
    projectId: '123',
  );
}

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MockFirebasePlatform();
  FirebasePlatform.instance = platform;
}
