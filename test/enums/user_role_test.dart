// test/enums/user_role_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:experiment_planner/enums/user_role.dart';

void main() {
  group('UserRole Tests', () {
    test('superAdmin should have all permissions', () {
      expect(UserRole.superAdmin.canManageMachine(), isTrue);
      expect(UserRole.superAdmin.canOperateMachine(), isTrue);
      expect(UserRole.superAdmin.canMaintainMachine(), isTrue);
      expect(UserRole.superAdmin.canManageAllMachines(), isTrue);
    });

    test('admin should have machine-specific permissions', () {
      expect(UserRole.admin.canManageMachine(), isTrue);
      expect(UserRole.admin.canOperateMachine(), isTrue);
      expect(UserRole.admin.canMaintainMachine(), isTrue);
      expect(UserRole.admin.canManageAllMachines(), isFalse);
    });

    test('engineer should have maintenance permissions', () {
      expect(UserRole.engineer.canManageMachine(), isFalse);
      expect(UserRole.engineer.canOperateMachine(), isTrue);
      expect(UserRole.engineer.canMaintainMachine(), isTrue);
      expect(UserRole.engineer.canManageAllMachines(), isFalse);
    });

    test('operator should only have operation permissions', () {
      expect(UserRole.operator.canManageMachine(), isFalse);
      expect(UserRole.operator.canOperateMachine(), isTrue);
      expect(UserRole.operator.canMaintainMachine(), isFalse);
      expect(UserRole.operator.canManageAllMachines(), isFalse);
    });

    test('user should have no machine permissions', () {
      expect(UserRole.user.canManageMachine(), isFalse);
      expect(UserRole.user.canOperateMachine(), isFalse);
      expect(UserRole.user.canMaintainMachine(), isFalse);
      expect(UserRole.user.canManageAllMachines(), isFalse);
    });
  });
}