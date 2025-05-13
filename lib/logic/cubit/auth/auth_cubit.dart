import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthStateModel> {
  AuthCubit() : super(AuthStateModel());


  void addEmail(String text) =>emit(state.copyWith(email: text,authState: AuthInitial()));

  void addPassword(String text) =>emit(state.copyWith(password: text,authState: AuthInitial()));

  void addIsActive() =>emit(state.copyWith(isActive: !state.isActive,authState: AuthInitial()));

  void showPassword() =>emit(state.copyWith(show: !state.show,authState: AuthInitial()));

}
