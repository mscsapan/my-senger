import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_provider/database_config.dart';
import '../../../data/models/auth/auth_state_model.dart';
import '../../../data/models/auth/user_response_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthStateModel> {
  AuthCubit() : super(AuthStateModel());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addUserInfo(UserResponse Function(UserResponse existing) updateFn) {

    final existing = state.users ?? UserResponse();

    final updated = updateFn(existing);

    emit(state.copyWith(users: updated,authState: AuthInitial()));
  }

  void storeExistingInfo(UserResponse? updateFn) {

    final existing = state.users ?? UserResponse();

    emit(state.copyWith(users: existing));
  }

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  UserResponse? _userResponse;

  UserResponse? get userInformation => _userResponse;

  // set saveUserData(UserResponseModel usersData) => _users = usersData;


  Future<void> checkAuthStatus() async {
    emit(state.copyWith(authState: AuthLoading()));

    await Future.delayed(const Duration(seconds: 1));

    if (_auth.currentUser != null) {

      await _fetchUserData();

     emit(state.copyWith(authState: AuthAuthenticated(_auth.currentUser)));
    } else {
      emit(state.copyWith(authState: AuthUnauthenticated()));
    }
  }


  Future<void> _fetchUserData() async {
    try {
      final doc = await _db.collection(DatabaseConfig.userCollection).doc(_auth.currentUser?.uid).get();

      if (doc.exists) {
        final userData = UserResponse.fromMap(doc.data()??{});
        _userResponse = userData;
        storeExistingInfo(userData);
        emit(state.copyWith(users: userData));
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> signUp() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _auth.createUserWithEmailAndPassword(
        email: state.users?.signUpEmail?? '',
        password: state.users?.signUpPassword ?? '',
      ).whenComplete(() {
        // debugPrint('id-uid-1 ${state.users?.id} - ${_auth.currentUser?.uid}');
        // addUserInfo((info)=>info.copyWith(id: _auth.currentUser?.uid,status: true));
        // debugPrint('id-uid-2 ${state.users?.id} - ${_auth.currentUser?.uid}');
        //
        // debugPrint('User registered successful with UID ${_auth.currentUser?.uid}.');
      /*    final updatedUser = (state.users ?? UserResponse()).copyWith(
            id: _auth.currentUser?.uid,
            loginEmail: state.loginEmail,
            loginPassword: state.loginPassword,
          );
          emit(state.copyWith(users: updatedUser));*/
      });

      // debugPrint('User registered successful with user object ${state.users}');
      emit(state.copyWith(authState: AuthSuccess('Successfully registered',AuthType.signUp)));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> signIn() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: state.users?.loginEmail ?? '',
        password: state.users?.loginPassword ?? '',
      );

      if (userCredential.user != null) {
        emit(state.copyWith(authState: AuthSuccess('Successfully login', AuthType.login)));
      }

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    } catch (e) {
      debugPrint('Error: $e');
      emit(state.copyWith(authState: AuthError('Something went wrong', null)));
    }
  }

  // Future<void> forgotPassword() async {
  //   try {
  //     emit(state.copyWith(authState: AuthLoading()));
  //     await _auth.sendPasswordResetEmail (email: state.loginEmail);
  //     emit(state.copyWith(authState: AuthSuccess('Successfully sent password reset email')));
  //   } on FirebaseAuthException catch (e) {
  //     debugPrint('FirebaseAuthException: ${e.code}');
  //     emit(state.copyWith(authState: AuthError(e.message, e.code)));
  //   }
  // }

  Future<void> storeNewUser() async {
    try {
      //emit(state.copyWith(authState: AuthLoading()));
      // Future.delayed(const Duration(seconds: 1));
      // debugPrint('user-map ${state.users?.toMap()}');
      // debugPrint('user-newly-created-id ${_auth.currentUser?.uid}');
      debugPrint('id-uid-33 ${state.users?.id} - ${_auth.currentUser?.uid}');
      await _db.collection(DatabaseConfig.userCollection).doc(_auth.currentUser?.uid).set(state.users?.toMap() ?? <String, dynamic>{});
      // emit(state.copyWith(authState: AuthSuccess('Successfully login')));
      // debugPrint('successfully store');
    } on FirebaseException catch (e,t) {
      debugPrint('FirebaseAuthException: ${e.message} - ${e.stackTrace} - $t');
      //emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> updateUser() async {
    try {
      //emit(state.copyWith(authState: AuthLoading()));
      // Future.delayed(const Duration(seconds: 1));
      // debugPrint('user-map ${state.users?.toMap()}');
      // debugPrint('user-newly-created-id ${_auth.currentUser?.uid}');
      await _db.collection(DatabaseConfig.userCollection).doc(_auth.currentUser?.uid).update(state.users?.toMap() ?? <String, dynamic>{});
      // emit(state.copyWith(authState: AuthSuccess('Successfully login')));
      // debugPrint('successfully store');
    } on FirebaseException catch (e,t) {
      debugPrint('FirebaseAuthException: ${e.message} - ${e.stackTrace} - $t');
      //emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  void clear() => emit(state.clear());

}

enum AuthType {login,signUp}
