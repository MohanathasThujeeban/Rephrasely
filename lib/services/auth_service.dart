import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Convert Firebase user to UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Get current user as UserModel
  UserModel? get currentUserModel {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // User stream
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await _updateUserDocument(result.user!);
        return AuthResult.success;
      }
      return AuthResult.unknown;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await result.user!.updateDisplayName(displayName);
        }

        // Send email verification
        await result.user!.sendEmailVerification();

        // Create user document in Firestore
        await _createUserDocument(result.user!);

        return AuthResult.success;
      }
      return AuthResult.unknown;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.cancelled;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        await _updateUserDocument(result.user!);
        return AuthResult.success;
      }
      return AuthResult.unknown;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Sign in with Facebook
  Future<AuthResult> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await _facebookAuth.login();

      if (loginResult.status == LoginStatus.cancelled) {
        return AuthResult.cancelled;
      }

      if (loginResult.status != LoginStatus.success) {
        return AuthResult.unknown;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      UserCredential result = await _auth.signInWithCredential(
        facebookAuthCredential,
      );

      if (result.user != null) {
        await _updateUserDocument(result.user!);
        return AuthResult.success;
      }
      return AuthResult.unknown;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult.success;
      }
      return AuthResult.unknown;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      // Sign out from Google (if signed in)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Google sign out can fail if user wasn't signed in with Google
        // This is not a critical error, so we continue
      }
      
      // Sign out from Facebook (if signed in)
      try {
        await _facebookAuth.logOut();
      } catch (e) {
        // Facebook sign out can fail if user wasn't signed in with Facebook
        // This is not a critical error, so we continue
      }
      
      // Sign out from Firebase (this is the most important one)
      await _auth.signOut();
      
      return AuthResult.success;
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete the user account
        await user.delete();
        return AuthResult.success;
      }
      return AuthResult.userNotFound;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult.unknown;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userModel = UserModel.fromFirebaseUser(user);
    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
  }

  // Update user document in Firestore
  Future<void> _updateUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Update existing document
      await userDoc.update({
        'lastSignIn': DateTime.now().toIso8601String(),
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'isEmailVerified': user.emailVerified,
      });
    } else {
      // Create new document
      await _createUserDocument(user);
    }
  }

  // Handle Firebase Auth exceptions
  AuthResult _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthResult.emailAlreadyInUse;
      case 'weak-password':
        return AuthResult.weakPassword;
      case 'user-not-found':
        return AuthResult.userNotFound;
      case 'wrong-password':
        return AuthResult.wrongPassword;
      case 'invalid-email':
        return AuthResult.invalidEmail;
      case 'user-disabled':
        return AuthResult.userDisabled;
      case 'too-many-requests':
        return AuthResult.tooManyRequests;
      case 'operation-not-allowed':
        return AuthResult.operationNotAllowed;
      case 'network-request-failed':
        return AuthResult.networkError;
      default:
        return AuthResult.unknown;
    }
  }

  // Get user-friendly error message
  String getErrorMessage(AuthResult result) {
    switch (result) {
      case AuthResult.success:
        return 'Success';
      case AuthResult.emailAlreadyInUse:
        return 'An account with this email already exists.';
      case AuthResult.weakPassword:
        return 'The password is too weak. Please choose a stronger password.';
      case AuthResult.userNotFound:
        return 'No account found with this email address.';
      case AuthResult.wrongPassword:
        return 'Incorrect password. Please try again.';
      case AuthResult.invalidEmail:
        return 'Please enter a valid email address.';
      case AuthResult.userDisabled:
        return 'This account has been disabled.';
      case AuthResult.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case AuthResult.operationNotAllowed:
        return 'This operation is not allowed.';
      case AuthResult.networkError:
        return 'Network error. Please check your connection.';
      case AuthResult.cancelled:
        return 'Sign-in was cancelled.';
      case AuthResult.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
