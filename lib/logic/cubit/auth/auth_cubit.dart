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

  // final loginFormKey = GlobalKey<FormState>();
  // final signUpFormKey = GlobalKey<FormState>();

  void addUserInfo(UserResponse Function(UserResponse existing) updateFn) {

    final existing = state.users ?? UserResponse();

    final updated = updateFn(existing);

    emit(state.copyWith(users: updated,authState: AuthInitial()));
  }

  Future<void> signUp() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _auth.createUserWithEmailAndPassword(
        email: state.users?.signUpEmail?? '',
        password: state.users?.signUpPassword ?? '',
      ).whenComplete(() {

        // debugPrint('User registered successful with UID ${_auth.currentUser?.uid}.');

      /*    final updatedUser = (state.users ?? UserResponse()).copyWith(
            id: _auth.currentUser?.uid,
            loginEmail: state.loginEmail,
            loginPassword: state.loginPassword,
          );
          emit(state.copyWith(users: updatedUser));*/
      });

      // debugPrint('User registered successful with user object ${state.users}');
      emit(state.copyWith(authState: AuthSuccess('Successfully registered')));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
    }
  }

  Future<void> signIn() async {
    try {
      emit(state.copyWith(authState: AuthLoading()));
      await _auth.signInWithEmailAndPassword(
        email: state.users?.loginEmail ?? '',
        password: state.users?.loginPassword?? '',
      );
      emit(state.copyWith(authState: AuthSuccess('Successfully login')));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      emit(state.copyWith(authState: AuthError(e.message, e.code)));
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
