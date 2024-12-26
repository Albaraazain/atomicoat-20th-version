// lib/enums/user_role.dart

enum UserRole {
  user,          // Basic user role
  operator,      // Can operate a specific machine
  engineer,      // Can maintain/calibrate a specific machine
  admin,         // Admin for a specific machine
  superAdmin     // Can manage all machines and create new machine entries
}

extension UserRoleExtension on UserRole {
  bool canManageMachine() {
    return this == UserRole.admin || this == UserRole.superAdmin;
  }

  bool canOperateMachine() {
    return this == UserRole.operator ||
           this == UserRole.engineer ||
           this == UserRole.admin ||
           this == UserRole.superAdmin;
  }

  bool canMaintainMachine() {
    return this == UserRole.engineer ||
           this == UserRole.admin ||
           this == UserRole.superAdmin;
  }

  bool canManageAllMachines() {
    return this == UserRole.superAdmin;
  }
}