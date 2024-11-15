part of 'setting_cubit.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object> get props => [];
}

class SettingInitial extends SettingState {
  const SettingInitial();
}

class SettingStateLoading extends SettingState {
  const SettingStateLoading();
}

class SettingStateLoaded extends SettingState {
  final WebsiteSetupModel settingModel;

  const SettingStateLoaded(this.settingModel);

  @override
  List<Object> get props => [settingModel];
}

class SettingStateError extends SettingState {
  final String message;
  final int statusCode;

  const SettingStateError(this.message, this.statusCode);

  @override
  List<Object> get props => [message, statusCode];
}
