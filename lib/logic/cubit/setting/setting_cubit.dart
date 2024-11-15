import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/setting/website_setup_model.dart';
import '../../repository/setting_repository.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingRepository _repository;
  WebsiteSetupModel? settingModel;

  SettingCubit({required SettingRepository repository})
      : _repository = repository,
        super(const SettingInitial()) {
    getSetting();
  }

  bool get showOnBoarding =>
      _repository.checkOnBoarding().fold((l) => false, (r) => true);

  Future<void> cacheOnBoarding() async {
    final result = await _repository.cachedOnBoarding();
    result.fold((l) => false, (r) => r);
  }

  Future<void> getSetting() async {
    emit(const SettingStateLoading());
    final result = await _repository.getSetting();
    result.fold((failure) {
      emit(SettingStateError(failure.message, failure.statusCode));
    }, (success) {
      settingModel = success;
      emit(SettingStateLoaded(success));
    });
  }
}
