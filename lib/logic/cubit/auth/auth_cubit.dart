import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';
import '../../../data/models/auth/user_response_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthStateModel> {
  AuthCubit() : super(AuthStateModel());


  void addEmail(String text) =>emit(state.copyWith(email: text,authState: AuthInitial()));

  void addPassword(String text) =>emit(state.copyWith(password: text,authState: AuthInitial()));

  void addIsActive() =>emit(state.copyWith(isActive: !state.isActive,authState: AuthInitial()));

  void showPassword() =>emit(state.copyWith(show: !state.show,authState: AuthInitial()));

  void showConfirmPassword() =>emit(state.copyWith(showConfirm: !state.showConfirm,authState: AuthInitial()));

  void addNewUsers(UserResponse ? user){
    final stateUser = state.users?? UserResponse();
    emit(state.copyWith(users: stateUser));
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> signUp() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: state.email,
        password: state.password,
      ).then((_){
        debugPrint('User registered successful with UID ${_firebaseAuth.currentUser?.uid}.');
        final user = state.users ?? UserResponse();

        user.copyWith(
          id: _firebaseAuth.currentUser?.uid,
          name: '',
          email: state.email,
          password: state.password,
        );
        emit(state.copyWith(users: user));
        debugPrint('User registered successful with user object ${state.users}');
      });
      emit(state.copyWith(authState: AuthSuccess('Successfully registered')));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> signIn() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _firebaseAuth.signInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(authState: AuthSuccess('Successfully login')));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> forgotPassword() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _firebaseAuth.sendPasswordResetEmail (email: state.email);
      emit(state.copyWith(authState: AuthSuccess('Successfully sent password reset email')));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> storeNewUser() async {
    try {
      //emit(state.copyWith(authState: AuthLoading()));
      debugPrint('user-map ${state.users?.toMap()}');
      await _fireStore.collection('users').doc(state.users?.id).set(state.users?.toMap() ?? <String, dynamic>{});
      // emit(state.copyWith(authState: AuthSuccess('Successfully login')));
      debugPrint('successfully store');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      //emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  void clear() => emit(state.clear());
}
