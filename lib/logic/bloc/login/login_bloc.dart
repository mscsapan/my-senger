import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/auth/login_state_model.dart';
import '../../../data/models/auth/user_response_model.dart';
import '../../../presentation/errors/errors_model.dart';
import '../../../presentation/errors/failure.dart';
import '../../repository/auth_repository.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginStateModel> {
  final AuthRepository _repository;

  UserResponseModel? _users;

  bool get isLoggedIn => _users != null && _users!.accessToken.isNotEmpty;

  UserResponseModel? get userInformation => _users;

  set saveUserData(UserResponseModel usersData) => _users = usersData;

  LoginBloc({required AuthRepository repository})
      : _repository = repository,
        super(const LoginStateModel()) {
    on<LoginEventUserEmail>((event, emit) {
      emit(state.copyWith(
          email: event.email, loginState: const LoginStateInitial()));
      //emit(state.copyWith(loginState: const LoginStateInitial()));
    });
    on<LoginEventPassword>((event, emit) {
      emit(state.copyWith(
          password: event.password, loginState: const LoginStateInitial()));
      //emit(state.copyWith(loginState: const LoginStateInitial()));
    });

    on<SaveUserCredentialEvent>((event, emit) {
      emit(state.copyWith(
          isActive: event.isActive, loginState: const LoginStateInitial()));
      //emit(state.copyWith(loginState: const LoginStateInitial()));
    });

    on<ShowPasswordEvent>((event, emit) {
      emit(state.copyWith(
          show: !(event.show), loginState: const LoginStateInitial()));
      //emit(state.copyWith(loginState: const LoginStateInitial()));
    });

    on<LoginEventSubmit>(_loginEvent);
    on<LoginEventLogout>(_logoutEvent);
    final result = _repository.getExistingUserInfo();
    result.fold((failure) => _users = null, (success) {
      saveUserData = success;
      log('$success',name: 'saved-user-data');
    });
  }

  Future<void> saveUserCredentials(String email, String password) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', email);
    pref.setString('password', password);
  }

  Future<void> _loginEvent(
      LoginEventSubmit event, Emitter<LoginStateModel> emit) async {
    emit(state.copyWith(loginState: LoginStateLoading()));
    final result = await _repository.login(state);
    result.fold(
      (failure) {
        if (failure is InvalidAuthData) {
          final errors = LoginStateFormValidate(failure.errors);
          emit(state.copyWith(loginState: errors));
        } else {
          final errors = LoginStateError(
              message: failure.message, statusCode: failure.statusCode);
          emit(state.copyWith(loginState: errors));
        }
      },
      (success) {
        final userLoaded = LoginStateLoaded(responses: success);
        _users = success;

        emit(state.copyWith(loginState: userLoaded));
        if (state.isActive == true) {
          debugPrint('check-box ${state.isActive}');
          saveUserCredentials(state.email, state.password);
        } else {
          debugPrint('check-box ${state.isActive}');
        }
        emit(state.clear());
      },
    );
  }

  Future<void> remoteCredentials() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('email');
    pref.remove('password');
  }

  Future<void> _logoutEvent(
      LoginEventLogout event, Emitter<LoginStateModel> emit) async {
    emit(state.copyWith(loginState: LoginStateLogoutLoading()));
    final result = await _repository.logout(userInformation!.accessToken);
    result.fold(
      (failure) {
        if (failure.statusCode == 500) {
          const loadedData = LoginStateLogoutLoaded('logout success', 200);
          emit(state.copyWith(loginState: loadedData));
        } else {
          final errors =
              LoginStateLogoutError(failure.message, failure.statusCode);
          emit(state.copyWith(loginState: errors));
        }
      },
      (logout) {
        _users = null;
        emit(state.copyWith(loginState: LoginStateLogoutLoaded(logout, 200)));
        remoteCredentials();
      },
    );
  }
}
