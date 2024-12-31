// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/user_role.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
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

  User? _user;
  UserModel? _userModel;
  UserRole? _userRole;
  String? _userStatus;
  bool _isLoading = true;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get userId => _user?.uid;
  UserRole? get userRole => _userRole;
  String? get userStatus => _userStatus;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userRole == UserRole.admin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isApproved() {
    return _userStatus == 'approved' || _userStatus == 'active';
  }

  AuthProvider(this._authService) {
    _logger.d('Initializing AuthProvider');
    _init();
  }

  Future<void> _init() async {
    try {
      _logger.i('Initializing authentication state');
      _setLoading(true);

      _user = _authService.currentUser;
      if (_user != null) {
        _logger.i('Current user found during initialization: ${_user?.uid}');
        await _loadUserData();
      } else {
        _logger.i('No current user found during initialization');
      }

      _authService.authStateChanges.listen(_handleAuthStateChange);
    } catch (e, stackTrace) {
      _handleError('Failed to initialize auth provider', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleAuthStateChange(User? user) async {
    try {
      _user = user;
      if (_user != null) {
        _logger.i('Auth state changed: User logged in: ${_user?.uid}');
        await _loadUserData();
      } else {
        _logger.i('Auth state changed: User logged out');
        _clearUserData();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _handleError('Error handling auth state change', e, stackTrace);
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_user == null) return;

      _userRole = await _authService.getUserRole(_user!.uid);
      _userStatus = await _authService.getUserStatus(_user!.uid);

      // Create UserModel
      _userModel = UserModel(
        uid: _user!.uid,
        email: _user!.email!,
        role: _userRole,
        status: _userStatus,
      );

      _logger.i('User data loaded successfully: ${_user?.uid}, role: $_userRole, status: $_userStatus');
    } catch (e, stackTrace) {
      _handleError('Failed to load user data', e, stackTrace);
    }
  }

  void _clearUserData() {
    _user = null;
    _userModel = null;
    _userRole = null;
    _userStatus = null;
    _error = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(String message, dynamic error, StackTrace stackTrace) {
    _logger.e('$message: $error', error: error, stackTrace: stackTrace);
    _error = error.toString();
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _error = null;

      final user = await _authService.signIn(email: email, password: password);
      if (user == null) {
        throw Exception('Sign in failed');
      }

      _logger.i('Sign in successful: ${user.uid}');

      return true;
    } catch (e, stackTrace) {
      _handleError('Sign in failed', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        machineSerial: machineSerial,
      );

      if (user == null) {
        throw Exception('Sign up failed');
      }

      _logger.i('Sign up successful: ${user.uid}');

      return true;
    } catch (e, stackTrace) {
      _handleError('Sign up failed', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.signOut();
      _clearUserData();

      _logger.i('User signed out successfully');
    } catch (e, stackTrace) {
      _handleError('Sign out failed', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.sendPasswordResetEmail(email);
      _logger.i('Password reset email sent to: $email');
    } catch (e, stackTrace) {
      _handleError('Failed to send password reset email', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.updateUserRole(userId, role);
      if (userId == _user?.uid) {
        _userRole = role;
      }
      _logger.i('User role updated: $userId to $role');
    } catch (e, stackTrace) {
      _handleError('Failed to update user role', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      _setLoading(true);
      _error = null;

      await _authService.updateUserStatus(userId, status);
      if (userId == _user?.uid) {
        _userStatus = status;
      }
      _logger.i('User status updated: $userId to $status');
    } catch (e, stackTrace) {
      _handleError('Failed to update user status', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
