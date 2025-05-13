import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../logic/bloc/login/login_bloc.dart';
import '../../../logic/cubit/auth/auth_cubit.dart';

class AuthStateModel extends Equatable {
  final String email;
  final String password;
  final bool isActive;
  final bool show;
  final AuthState authState;

  const AuthStateModel({
    // this.email = 'seller@gmail.com',
    // this.password = '1234',
    this.email = '',
    this.password = '',
    this.isActive = false,
    this.show = true,
    this.authState = const AuthInitial(),
  });

  AuthStateModel copyWith({
    String? email,
    String? password,
    bool? isActive,
    bool? show,
    AuthState? authState,
  }) {
    return AuthStateModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      show: show ?? this.show,
      authState: authState ?? this.authState,
    );
  }

  AuthStateModel clear() {
    return const AuthStateModel(
      email: '',
      password: '',
      isActive: false,
      show: true,
      authState: AuthInitial(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'email': email.trim()});
    result.addAll({'password': password});
    // result.addAll({'state': state});

    return result;
  }

  factory AuthStateModel.fromMap(Map<String, dynamic> map) {
    return AuthStateModel(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthStateModel.fromJson(String source) =>
      AuthStateModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'AuthModelState(username: $email, password: $password, state: $authState)';

  @override
  List<Object> get props => [
        email,
        password,
        isActive,
        show,
        authState,
      ];
}
