import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _init();
  }
  
  void _init() {
    // Listen to auth state changes
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Register with email and password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.signInWithFacebook();
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.sendPasswordResetEmail(email);
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.sendEmailVerification();
      
      if (result == AuthResult.success) {
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign out
  Future<bool> signOut() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.signOut();
      
      if (result == AuthResult.success) {
        // Don't manually set _user to null here, let the auth state stream handle it
        // This prevents race conditions and ensures proper state management
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign out. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during sign out');
      _setLoading(false);
      return false;
    }
  }
  
  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.deleteAccount();
      
      if (result == AuthResult.success) {
        _user = null;
        _setLoading(false);
        return true;
      } else {
        _setError(_authService.getErrorMessage(result));
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }
}