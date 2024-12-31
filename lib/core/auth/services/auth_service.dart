import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../enums/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signIn({required String email, required String password}) async {
    try {
      _logger.i('Attempting sign in for user: $email');

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        _logger.i('Sign in successful for user: ${user.uid}');

        // Check if user document exists
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          _logger.w('User document not found, creating new document');
          // Create user document if it doesn't exist
          await _createUserDocument(user, UserRole.user);
        }

        return user;
      } else {
        _logger.w('Sign in failed: No user returned');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Sign in error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      _logger.i('Attempting sign up for user: $email');

      // Validate machine serial
      if (!await _validateMachineSerial(machineSerial)) {
        throw Exception('Invalid machine serial number');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        _logger.i('Sign up successful for user: ${user.uid}');

        // Create user document
        await _createUserDocument(
          user,
          UserRole.user,
          name: name,
          machineSerial: machineSerial,
        );

        return user;
      } else {
        _logger.w('Sign up failed: No user returned');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Sign up error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Attempting sign out');
      await _auth.signOut();
      _logger.i('Sign out successful');
    } catch (e, stackTrace) {
      _logger.e('Sign out error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user role
  Future<UserRole> getUserRole(String userId) async {
    try {
      _logger.d('Getting user role for: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        _logger.w('User document not found, defaulting to user role');
        return UserRole.user;
      }

      final roleStr = doc.get('role') as String? ?? 'user';
      _logger.d('User role found: $roleStr');

      return _parseUserRole(roleStr);
    } catch (e, stackTrace) {
      _logger.e('Error getting user role', error: e, stackTrace: stackTrace);
      return UserRole.user; // Default to user role on error
    }
  }

  // Get user status
  Future<String?> getUserStatus(String userId) async {
    try {
      _logger.d('Getting user status for: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        _logger.w('User document not found');
        return null;
      }

      final status = doc.get('status') as String?;
      _logger.d('User status found: $status');

      return status;
    } catch (e, stackTrace) {
      _logger.e('Error getting user status', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      _logger.i('Updating status for user $userId to: $status');
      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Status update successful');
    } catch (e, stackTrace) {
      _logger.e('Error updating user status', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      _logger.i('Updating role for user $userId to: $role');
      await _firestore.collection('users').doc(userId).update({
        'role': role.toString().split('.').last.toLowerCase(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Role update successful');
    } catch (e, stackTrace) {
      _logger.e('Error updating user role', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent successfully');
    } catch (e, stackTrace) {
      _logger.e('Error sending password reset email', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _createUserDocument(
    User user,
    UserRole role, {
    String? name,
    String? machineSerial,
  }) async {
    try {
      final userData = {
        'email': user.email,
        'role': role.toString().split('.').last.toLowerCase(),
        'status': role == UserRole.admin ? 'approved' : 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) userData['name'] = name;
      if (machineSerial != null) userData['machineSerial'] = machineSerial;

      await _firestore.collection('users').doc(user.uid).set(userData);
      _logger.i('User document created successfully');
    } catch (e, stackTrace) {
      _logger.e('Error creating user document', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> _validateMachineSerial(String serial) async {
    // TODO: Implement actual machine serial validation
    _logger.w('Machine serial validation not implemented, returning true for testing');
    return true;
  }

  UserRole _parseUserRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}