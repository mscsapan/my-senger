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
  final AuthType? authType;

  const AuthLoading(this.authType);

  @override
  List<Object?> get props => [authType];
}

final class AuthError extends AuthState {
  final String? message;
  final String? code;
  final AuthType? authType;

  const AuthError(this.message, this.code,this.authType);

  @override
  List<Object?> get props => [message,authType];
}

final class AuthSuccess extends AuthState {
  final String? message;
  final AuthType? authType;

  const AuthSuccess(this.message, this.authType);

  @override
  List<Object?> get props => [message, authType];
}

class AuthAuthenticated extends AuthState {
  final User? user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}

final class AnotherUserInfo extends AuthState {
  final UserResponse ? userInfo;

  const AnotherUserInfo(this.userInfo);

  @override
  List<Object?> get props => [userInfo];
}
