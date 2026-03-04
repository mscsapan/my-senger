// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class AppSettingModel extends Equatable {
  final String authToken;
  final String version;
  const AppSettingModel({required this.authToken, required this.version});

  AppSettingModel copyWith({String? authToken, String? version}) {
    return AppSettingModel(
      authToken: authToken ?? this.authToken,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'authToken': authToken, 'version': version};
  }

  factory AppSettingModel.fromMap(Map<String, dynamic> map) {
    return AppSettingModel(
      authToken: map['auth_token'] ?? '',
      version: map['version'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettingModel.fromJson(String source) =>
      AppSettingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [authToken, version];
}
