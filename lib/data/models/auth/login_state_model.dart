import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../logic/bloc/login/login_bloc.dart';

class LoginStateModel extends Equatable {
  final String email;
  final String password;
  final bool isActive;
  final bool show;
  final LoginState loginState;

  const LoginStateModel({
    // this.email = 'seller@gmail.com',
    // this.password = '1234',
    this.email = '',
    this.password = '',
    this.isActive = false,
    this.show = true,
    this.loginState = const LoginStateInitial(),
  });

  LoginStateModel copyWith({
    String? email,
    String? password,
    bool? isActive,
    bool? show,
    LoginState? loginState,
  }) {
    return LoginStateModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      show: show ?? this.show,
      loginState: loginState ?? this.loginState,
    );
  }

  LoginStateModel clear() {
    return const LoginStateModel(
      email: '',
      password: '',
      isActive: false,
      show: true,
      loginState: LoginStateInitial(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'email': email.trim()});
    result.addAll({'password': password});
    // result.addAll({'state': state});

    return result;
  }

  factory LoginStateModel.fromMap(Map<String, dynamic> map) {
    return LoginStateModel(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginStateModel.fromJson(String source) =>
      LoginStateModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'LoginModelState(username: $email, password: $password, state: $loginState)';

  @override
  List<Object> get props => [
        email,
        password,
        isActive,
        show,
        loginState,
      ];
}
