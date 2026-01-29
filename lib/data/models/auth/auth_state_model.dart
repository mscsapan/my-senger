import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../logic/cubit/auth/auth_cubit.dart';
import 'user_response_model.dart';

class AuthStateModel extends Equatable {
  // final String email;
  // final String password;
  // final bool isActive;
  // final bool show;
  // final bool showConfirm;
  final UserResponse? users;
  final AuthState authState;

  const AuthStateModel({
    // this.email = 'seller@gmail.com',
    // this.password = '1234',
    // this.email = '',
    // this.password = '',
    // this.isActive = false,
    // this.show = true,
    // this.showConfirm = true,
    this.users,
    this.authState = const AuthInitial(),
  });

  AuthStateModel copyWith({
    // String? email,
    // String? password,
    // bool? isActive,
    // bool? show,
    // bool? showConfirm,
    UserResponse? users,
    AuthState? authState,
  }) {
    return AuthStateModel(
      // email: email ?? this.email,
      // password: password ?? this.password,
      // isActive: isActive ?? this.isActive,
      // show: show ?? this.show,
      // showConfirm: showConfirm ?? this.showConfirm,
      users: users ?? this.users,
      authState: authState ?? this.authState,
    );
  }

  AuthStateModel clear() {
    return const AuthStateModel(
      // email: '',
      // password: '',
      // isActive: false,
      // show: true,
      // showConfirm: true,
      users: null,
      authState: AuthInitial(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    //
    // result.addAll({'email': email.trim()});
    // result.addAll({'password': password});
    // result.addAll({'state': state});

    return result;
  }

  factory AuthStateModel.fromMap(Map<String, dynamic> map) {
    return AuthStateModel(
      // email: map['email'] ?? '',
      // password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthStateModel.fromJson(String source) =>
      AuthStateModel.fromMap(json.decode(source));

  // @override
  // String toString() => 'AuthModelState(username: $email, password: $password, state: $authState)';

  @override
  List<Object?> get props => [
    // email,
    // password,
    // isActive,
    // show,
    // showConfirm,
    users,
    authState,
  ];
}
