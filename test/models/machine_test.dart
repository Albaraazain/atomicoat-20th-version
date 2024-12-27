// test/models/machine_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/machine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {
  group('Machine Model Tests', () {
    final DateTime testDate = DateTime(2024, 1, 1);
    final testMachine = Machine(
      id: 'test-id',
      serialNumber: 'SN123',
      location: 'Lab 1',
      model: 'ALD-2000',
      installDate: testDate,
      lastMaintenance: testDate,
      adminUsers: {'user1': 'admin', 'user2': 'engineer'},
    );

    test('should create Machine instance with correct values', () {
      expect(testMachine.id, equals('test-id'));
      expect(testMachine.serialNumber, equals('SN123'));
      expect(testMachine.location, equals('Lab 1'));
      expect(testMachine.model, equals('ALD-2000'));
      expect(testMachine.installDate, equals(testDate));
      expect(testMachine.status, equals(MachineStatus.offline));
      expect(testMachine.currentOperator, isNull);
      expect(testMachine.lastMaintenance, equals(testDate));
      expect(testMachine.adminUsers, equals({'user1': 'admin', 'user2': 'engineer'}));
      expect(testMachine.isActive, isTrue);
    });

    test('should convert to JSON correctly', () {
      final json = testMachine.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['serialNumber'], equals('SN123'));
      expect(json['location'], equals('Lab 1'));
      expect(json['model'], equals('ALD-2000'));
      expect(json['status'], equals('offline'));
      expect(json['adminUsers'], equals({'user1': 'admin', 'user2': 'engineer'}));
      expect(json['isActive'], isTrue);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'serialNumber': 'SN123',
        'location': 'Lab 1',
        'model': 'ALD-2000',
        'installDate': Timestamp.fromDate(testDate),
        'status': 'offline',
        'currentOperator': null,
        'lastMaintenance': Timestamp.fromDate(testDate),
        'adminUsers': {'user1': 'admin', 'user2': 'engineer'},
        'isActive': true,
      };

      final machine = Machine.fromJson(json);

      expect(machine.id, equals('test-id'));
      expect(machine.serialNumber, equals('SN123'));
      expect(machine.location, equals('Lab 1'));
      expect(machine.model, equals('ALD-2000'));
      expect(machine.status, equals(MachineStatus.offline));
      expect(machine.adminUsers, equals({'user1': 'admin', 'user2': 'engineer'}));
    });

    test('should copy with new values correctly', () {
      final newDate = DateTime(2024, 2, 1);
      final copiedMachine = testMachine.copyWith(
        location: 'Lab 2',
        status: MachineStatus.running,
        lastMaintenance: newDate,
      );

      expect(copiedMachine.id, equals(testMachine.id));
      expect(copiedMachine.location, equals('Lab 2'));
      expect(copiedMachine.status, equals(MachineStatus.running));
      expect(copiedMachine.lastMaintenance, equals(newDate));
      expect(copiedMachine.serialNumber, equals(testMachine.serialNumber));
    });
  });
}