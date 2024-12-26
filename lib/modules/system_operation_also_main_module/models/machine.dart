// lib/modules/system_operation_also_main_module/models/machine.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MachineStatus {
  offline,    // Machine is not connected
  idle,       // Machine is connected but not running
  running,    // Machine is running an experiment
  error,      // Machine has encountered an error
  maintenance // Machine is under maintenance
}

class Machine {
  final String id;               // Unique identifier for the machine
  final String serialNumber;     // Physical serial number
  final String location;         // Lab/location identifier
  final String model;           // Model number/name
  final DateTime installDate;    // Installation date
  final MachineStatus status;    // Current operational status
  final String? currentOperator; // ID of current operator (if any)
  final DateTime lastMaintenance;// Last maintenance date
  final Map<String, String> adminUsers; // Map of user IDs to their roles for this machine
  final bool isActive;          // Whether the machine is active in the system

  Machine({
    required this.id,
    required this.serialNumber,
    required this.location,
    required this.model,
    required this.installDate,
    this.status = MachineStatus.offline,
    this.currentOperator,
    required this.lastMaintenance,
    required this.adminUsers,
    this.isActive = true,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'] as String,
      serialNumber: json['serialNumber'] as String,
      location: json['location'] as String,
      model: json['model'] as String,
      installDate: (json['installDate'] as Timestamp).toDate(),
      status: MachineStatus.values.firstWhere(
        (e) => e.toString() == 'MachineStatus.${json['status']}',
        orElse: () => MachineStatus.offline,
      ),
      currentOperator: json['currentOperator'] as String?,
      lastMaintenance: (json['lastMaintenance'] as Timestamp).toDate(),
      adminUsers: Map<String, String>.from(json['adminUsers'] as Map),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serialNumber': serialNumber,
    'location': location,
    'model': model,
    'installDate': Timestamp.fromDate(installDate),
    'status': status.toString().split('.').last,
    'currentOperator': currentOperator,
    'lastMaintenance': Timestamp.fromDate(lastMaintenance),
    'adminUsers': adminUsers,
    'isActive': isActive,
  };

  Machine copyWith({
    String? id,
    String? serialNumber,
    String? location,
    String? model,
    DateTime? installDate,
    MachineStatus? status,
    String? currentOperator,
    DateTime? lastMaintenance,
    Map<String, String>? adminUsers,
    bool? isActive,
  }) {
    return Machine(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      model: model ?? this.model,
      installDate: installDate ?? this.installDate,
      status: status ?? this.status,
      currentOperator: currentOperator ?? this.currentOperator,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      adminUsers: adminUsers ?? Map.from(this.adminUsers),
      isActive: isActive ?? this.isActive,
    );
  }
}