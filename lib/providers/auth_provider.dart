import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        _user = User.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        // Create new user document if it doesn't exist
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          _user = User(
            id: uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            preferences: UserPreferences(),
          );
          await _firestore.collection('users').doc(uid).set(_user!.toFirestore());
        }
      }
      
      _error = '';
    } catch (e) {
      _error = 'Failed to load user data: ${e.toString()}';
      debugPrint(_error);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      firebase_auth.UserCredential credential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document in Firestore
        _user = User(
          id: credential.user!.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          preferences: UserPreferences(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(_user!.toFirestore());

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      debugPrint('Sign up error: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      debugPrint('Sign in error: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      debugPrint('Reset password error: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      User updatedUser = _user!.copyWith(
        name: name ?? _user!.name,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        profileImage: profileImage ?? _user!.profileImage,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toFirestore());

      // Update Firebase Auth display name if name changed
      if (name != null && name != _user!.name) {
        await _auth.currentUser?.updateDisplayName(name);
      }

      _user = updatedUser;
      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> addAddress(Address address) async {
    if (_user == null) return false;

    try {
      List<Address> updatedAddresses = [..._user!.addresses, address];
      
      // If this is the first address, make it default
      if (updatedAddresses.length == 1) {
        updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      }

      User updatedUser = _user!.copyWith(
        addresses: updatedAddresses,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toFirestore());

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add address: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(Address updatedAddress) async {
    if (_user == null) return false;

    try {
      List<Address> addresses = _user!.addresses
          .map((addr) => addr.id == updatedAddress.id ? updatedAddress : addr)
          .toList();

      User updatedUser = _user!.copyWith(
        addresses: addresses,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toFirestore());

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update address: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    if (_user == null) return false;

    try {
      List<Address> addresses = _user!.addresses
          .where((addr) => addr.id != addressId)
          .toList();

      // If we deleted the default address and there are other addresses,
      // make the first one default
      if (addresses.isNotEmpty && 
          !addresses.any((addr) => addr.isDefault)) {
        addresses[0] = addresses[0].copyWith(isDefault: true);
      }

      User updatedUser = _user!.copyWith(
        addresses: addresses,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toFirestore());

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete address: ${e.toString()}';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthState() async {
    // This method is called during app initialization
    // The auth state is already being handled by _init()
    // Just wait a moment to ensure everything is loaded
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    return await signIn(email: email, password: password);
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final fullName = '$firstName $lastName';
    return await signUp(email: email, password: password, name: fullName);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    return await resetPassword(email);
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // TODO: Implement Google Sign In
      // For now, return false with an appropriate error message
      _error = 'Google Sign In is not yet implemented';
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _getAuthErrorMessage(e);
      debugPrint('Google sign in error: ${e.toString()}');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
}
