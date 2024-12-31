import '../enums/user_role.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final UserRole? role;
  final String? status;
  final String? machineSerial;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.status,
    this.machineSerial,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      role: json['role'] != null ? UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.values.first,
      ) : null,
      status: json['status'],
      machineSerial: json['machineSerial'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role?.name,
      'status': status,
      'machineSerial': machineSerial,
    };
  }
}
