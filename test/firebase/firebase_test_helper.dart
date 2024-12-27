import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class FirebaseTestHelper {
  static Future<void> setupFirebaseForTest() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  static FakeFirebaseFirestore getFirebaseInstance() {
    return FakeFirebaseFirestore();
  }
}