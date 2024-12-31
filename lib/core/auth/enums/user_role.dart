enum UserRole {
  admin,
  operator,
  user;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  @override
  String toString() {
    return name.toLowerCase();
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isOperator => this == UserRole.operator;
  bool get isUser => this == UserRole.user;
}
