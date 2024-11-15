part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginStateInitial extends LoginState {
  const LoginStateInitial();

  @override
  List<Object?> get props => [];
}

class LoginStateLoading extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginStateLogoutLoading extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginStateLogoutLoaded extends LoginState {
  final String message;
  final int statusCode;

  const LoginStateLogoutLoaded(this.message, this.statusCode);

  @override
  List<Object?> get props => [message, statusCode];
}

class LoginStateLogoutError extends LoginState {
  final String message;
  final int statusCode;

  const LoginStateLogoutError(this.message, this.statusCode);

  @override
  List<Object?> get props => [message, statusCode];
}

class LoginStateLoaded extends LoginState {
  final UserResponseModel responses;

  const LoginStateLoaded({required this.responses});

  @override
  List<Object?> get props => [responses];
}

class LoginStateError extends LoginState {
  final String message;
  final int statusCode;

  const LoginStateError({required this.message, required this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class LoginStateFormValidate extends LoginState {
  final Errors errors;

  const LoginStateFormValidate(this.errors);

  @override
  List<Object?> get props => [errors];
}
