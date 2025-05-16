import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthStateModel> {
  AuthCubit() : super(AuthStateModel());


  void addEmail(String text) =>emit(state.copyWith(email: text,authState: AuthInitial()));

  void addPassword(String text) =>emit(state.copyWith(password: text,authState: AuthInitial()));

  void addIsActive() =>emit(state.copyWith(isActive: !state.isActive,authState: AuthInitial()));

  void showPassword() =>emit(state.copyWith(show: !state.show,authState: AuthInitial()));

  void showConfirmPassword() =>emit(state.copyWith(showConfirm: !state.showConfirm,authState: AuthInitial()));

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
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

  void clear() => emit(state.clear());
}
