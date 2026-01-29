part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthError extends AuthState {
  final String? message;
  final String? code;

  const AuthError(this.message,this.code);

  @override
  List<Object?> get props => [message];
}

final class AuthSuccess extends AuthState {
  final String? message;
  final AuthType ? authType;

  const AuthSuccess(this.message,this.authType);

  @override
  List<Object?> get props => [message,authType];
}
