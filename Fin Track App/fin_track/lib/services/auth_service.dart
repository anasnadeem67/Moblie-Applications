import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to monitor real-time authentication state changes
  Stream<User?> get user => _auth.authStateChanges();

  // SIGN UP method to create a new user account with extended profile data
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String businessName,
    required String phone,
    required String baseCurrency,
  }) async {
    try {
      // 1. Authenticate and create user credentials in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // 2. Synchronize the user's name with the Firebase Auth DisplayName property
        await user.updateDisplayName(name);

        // 3. Create a comprehensive User Profile document in Cloud Firestore
        // This data is utilized for generating business reports and setting dashboard preferences
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'businessName': businessName,
          'email': email,
          'phone': phone,
          'baseCurrency': baseCurrency, // Stores default preference (e.g., PKR, AED, INR)
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Handling specific Firebase Authentication exceptions
      debugPrint("Auth Error: ${e.message}");
      return null;
    } catch (e) {
      // Catch-all for general logic or connection errors
      debugPrint("General Error: ${e.toString()}");
      return null;
    }
  }

  // SIGN IN method to authenticate existing users
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      debugPrint("Login Error: ${e.toString()}");
      return null;
    }
  }

  // SIGN OUT method to terminate the current session
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Logout Error: ${e.toString()}");
    }
  }

  // HELPER: Fetches specific user profile details from Firestore
  // Used for displaying personalized business info on the dashboard and reports
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
}