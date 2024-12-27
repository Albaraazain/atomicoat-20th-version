import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';
import 'base_repository.dart';
import 'machine_repository.dart';

enum UserRequestStatus { pending, approved, denied }

class UserRequest {
  final String userId;
  final String email;
  final String name;
  final String machineSerial;
  final String? machineId;
  final String? machineAdminId;
  final UserRequestStatus status;
  final DateTime createdAt;
  final String? message;

  UserRequest({
    required this.userId,
    required this.email,
    required this.name,
    required this.machineSerial,
    this.machineId,
    this.machineAdminId,
    this.status = UserRequestStatus.pending,
    DateTime? createdAt,
    this.message,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'machineSerial': machineSerial,
    'machineId': machineId,
    'machineAdminId': machineAdminId,
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
    'message': message,
  };

  factory UserRequest.fromJson(Map<String, dynamic> json) => UserRequest(
    userId: json['userId'],
    email: json['email'],
    name: json['name'],
    machineSerial: json['machineSerial'],
    machineId: json['machineId'],
    machineAdminId: json['machineAdminId'],
    status: UserRequestStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => UserRequestStatus.pending),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    message: json['message'],
  );
}

class UserRequestRepository extends BaseRepository<UserRequest> {
  final MachineRepository _machineRepository;
  final FirebaseFirestore _firestore;
  late final CollectionReference _collection;

  UserRequestRepository({FirebaseFirestore? firestore})
      : _machineRepository = MachineRepository(firestore: firestore),
        _firestore = firestore ?? FirebaseFirestore.instance,
        super('user_requests', firestore: firestore) {
    _collection = _firestore.collection('user_requests');
  }

  @override
  UserRequest fromJson(Map<String, dynamic> json) => UserRequest.fromJson(json);

  Future<void> createUserRequest(UserRequest request) async {
    // Get machine ID from serial
    final machineId = await _machineRepository.getMachineIdBySerial(request.machineSerial);
    if (machineId == null) {
      throw Exception('Invalid machine serial number');
    }

    // Get machine admin
    final adminId = await _machineRepository.getMachineAdmin(machineId);
    if (adminId == null) {
      throw Exception('Machine has no admin assigned');
    }

    // Create request with machine and admin info
    final updatedRequest = UserRequest(
      userId: request.userId,
      email: request.email,
      name: request.name,
      machineSerial: request.machineSerial,
      machineId: machineId,
      machineAdminId: adminId,
      message: request.message,
    );

    await add(request.userId, updatedRequest);
  }

  Future<void> approveRequest(String userId, UserRole role) async {
    final request = await get(userId);
    if (request == null) {
      throw Exception('Request not found');
    }

    if (request.machineId == null) {
      throw Exception('Request has no machine ID');
    }

    await _firestore.runTransaction((transaction) async {
      // Update request status
      transaction.update(
        _collection.doc(userId),
        {'status': UserRequestStatus.approved.toString()}
      );

      // Update user's role and status
      transaction.update(
        _firestore.collection('users').doc(userId),
        {
          'role': role.toString().split('.').last,
          'isActive': true,
        }
      );

      // Add user to machine
      await _machineRepository.addApprovedUserToMachine(
        request.machineId!,
        userId,
        role.toString().split('.').last,
      );
    });
  }

  Future<void> denyRequest(String userId) async {
    await _collection.doc(userId).update({'status': UserRequestStatus.denied.toString()});
  }

  Future<int> getPendingRequestCount() async {
    QuerySnapshot snapshot = await _collection
        .where('status', isEqualTo: UserRequestStatus.pending.toString())
        .get();
    return snapshot.size;
  }

  Future<List<UserRequest>> getPendingRequests() async {
    final querySnapshot = await getCollection()
        .where('status', isEqualTo: UserRequestStatus.pending.toString())
        .get();
    return querySnapshot.docs
        .map((doc) => UserRequest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserRequest>> getPendingRequestsForAdmin(String adminId) async {
    final querySnapshot = await getCollection()
        .where('machineAdminId', isEqualTo: adminId)
        .where('status', isEqualTo: UserRequestStatus.pending.toString())
        .get();

    return querySnapshot.docs
        .map((doc) => UserRequest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}