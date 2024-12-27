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
  final String location;         // Lab location identifier
  final String labName;          // Name of the lab
  final String labInstitution;   // Institution/Organization name
  final String model;            // Model number/name
  final String machineType;      // Type of ALD machine
  final DateTime installDate;    // Installation date
  final MachineStatus status;    // Current operational status
  final String? currentOperator; // ID of current operator (if any)
  final String? currentExperiment; // ID of current running experiment (if any)
  final DateTime lastMaintenance;// Last maintenance date
  final String adminId;         // ID of the machine admin
  final bool isActive;          // Whether the machine is active in the system
  final Map<String, dynamic> specifications; // Machine specifications

  Machine({
    required this.id,
    required this.serialNumber,
    required this.location,
    required this.labName,
    required this.labInstitution,
    required this.model,
    required this.machineType,
    required this.installDate,
    this.status = MachineStatus.offline,
    this.currentOperator,
    this.currentExperiment,
    required this.lastMaintenance,
    required this.adminId,
    this.isActive = true,
    this.specifications = const {},
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'] as String,
      serialNumber: json['serialNumber'] as String,
      location: json['location'] as String,
      labName: json['labName'] as String? ?? '',
      labInstitution: json['labInstitution'] as String? ?? '',
      model: json['model'] as String,
      machineType: json['machineType'] as String? ?? '',
      installDate: (json['installDate'] as Timestamp).toDate(),
      status: MachineStatus.values.firstWhere(
        (e) => e.toString() == 'MachineStatus.${json['status']}',
        orElse: () => MachineStatus.offline,
      ),
      currentOperator: json['currentOperator'] as String?,
      currentExperiment: json['currentExperiment'] as String?,
      lastMaintenance: (json['lastMaintenance'] as Timestamp).toDate(),
      adminId: json['adminId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serialNumber': serialNumber,
    'location': location,
    'labName': labName,
    'labInstitution': labInstitution,
    'model': model,
    'machineType': machineType,
    'installDate': Timestamp.fromDate(installDate),
    'status': status.toString().split('.').last,
    'currentOperator': currentOperator,
    'currentExperiment': currentExperiment,
    'lastMaintenance': Timestamp.fromDate(lastMaintenance),
    'adminId': adminId,
    'isActive': isActive,
    'specifications': specifications,
  };

  Machine copyWith({
    String? id,
    String? serialNumber,
    String? location,
    String? labName,
    String? labInstitution,
    String? model,
    String? machineType,
    DateTime? installDate,
    MachineStatus? status,
    String? currentOperator,
    String? currentExperiment,
    DateTime? lastMaintenance,
    String? adminId,
    bool? isActive,
    Map<String, dynamic>? specifications,
  }) {
    return Machine(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      labName: labName ?? this.labName,
      labInstitution: labInstitution ?? this.labInstitution,
      model: model ?? this.model,
      machineType: machineType ?? this.machineType,
      installDate: installDate ?? this.installDate,
      status: status ?? this.status,
      currentOperator: currentOperator ?? this.currentOperator,
      currentExperiment: currentExperiment ?? this.currentExperiment,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      adminId: adminId ?? this.adminId,
      isActive: isActive ?? this.isActive,
      specifications: specifications ?? Map<String, dynamic>.from(this.specifications),
    );
  }
}