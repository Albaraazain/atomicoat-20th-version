// test/repositories/machine_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/machine.dart';
import 'package:experiment_planner/repositories/machine_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase/firebase_test_helper.dart';
import '../firebase_mock_helper.dart';

void main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('MachineRepository Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MachineRepository repository;
    late Machine testMachine;

    setUp(() async {
      await FirebaseTestHelper.setupFirebaseForTest();
      fakeFirestore = FirebaseTestHelper.getFirebaseInstance();
      repository = MachineRepository(firestore: fakeFirestore);
      testMachine = Machine(
        id: 'test-id',
        serialNumber: 'SN123',
        location: 'Lab 1',
        model: 'ALD-2000',
        installDate: DateTime(2024, 1, 1),
        lastMaintenance: DateTime(2024, 1, 1),
        adminUsers: {'user1': 'admin'},
      );
    });

    test('should add machine to collection', () async {
      await repository.add(testMachine.id, testMachine);

      final doc = await fakeFirestore
          .collection('machines')
          .doc(testMachine.id)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['serialNumber'], equals('SN123'));
    });

    test('should retrieve machine by id', () async {
      await repository.add(testMachine.id, testMachine);

      final retrieved = await repository.get(testMachine.id);

      expect(retrieved?.serialNumber, equals(testMachine.serialNumber));
      expect(retrieved?.location, equals(testMachine.location));
    });

    test('should update machine status', () async {
      await repository.add(testMachine.id, testMachine);
      await repository.updateMachineStatus(
        testMachine.id,
        MachineStatus.running,
      );

      final updated = await repository.get(testMachine.id);
      expect(updated?.status, equals(MachineStatus.running));
    });

    test('should get machines for user', () async {
      final machine1 = testMachine;
      final machine2 = testMachine.copyWith(
        id: 'test-id-2',
        serialNumber: 'SN124',
        adminUsers: {'user1': 'admin', 'user2': 'engineer'},
      );

      await repository.add(machine1.id, machine1);
      await repository.add(machine2.id, machine2);

      final userMachines = await repository.getMachinesForUser('user1');
      expect(userMachines.length, equals(2));

      final user2Machines = await repository.getMachinesForUser('user2');
      expect(user2Machines.length, equals(1));
    });

    test('should get machines by location', () async {
      final machine1 = testMachine;
      final machine2 = testMachine.copyWith(
        id: 'test-id-2',
        serialNumber: 'SN124',
        location: 'Lab 2',
      );

      await repository.add(machine1.id, machine1);
      await repository.add(machine2.id, machine2);

      final lab1Machines = await repository.getMachinesByLocation('Lab 1');
      expect(lab1Machines.length, equals(1));
      expect(lab1Machines.first.serialNumber, equals('SN123'));

      final lab2Machines = await repository.getMachinesByLocation('Lab 2');
      expect(lab2Machines.length, equals(1));
      expect(lab2Machines.first.serialNumber, equals('SN124'));
    });
  });
}

// Mock setup helper
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup mock Firebase Core
  setupFirebaseCoreMocks();
}