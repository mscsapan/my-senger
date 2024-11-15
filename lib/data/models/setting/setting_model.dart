import 'dart:convert';

import 'package:equatable/equatable.dart';

class SettingModel extends Equatable {
  final String logo;
  final String favicon;
  final int enableUserRegistration;
  final int phoneNumberRequired;
  final String defaultPhoneCode;
  final int enableMultivendor;
  final String timeZone;
  final String currencyIcon;
  final String currencyName;
  final String themeOne;
  final String themeTwo;

  const SettingModel({
    required this.logo,
    required this.favicon,
    required this.enableUserRegistration,
    required this.phoneNumberRequired,
    required this.defaultPhoneCode,
    required this.enableMultivendor,
    required this.timeZone,
    required this.currencyIcon,
    required this.currencyName,
    required this.themeOne,
    required this.themeTwo,
  });

  SettingModel copyWith({
    String? logo,
    String? favicon,
    int? enableUserRegistration,
    int? phoneNumberRequired,
    String? defaultPhoneCode,
    int? enableMultivendor,
    String? timeZone,
    String? currencyIcon,
    String? currencyName,
    String? themeOne,
    String? themeTwo,
  }) {
    return SettingModel(
      logo: logo ?? this.logo,
      favicon: favicon ?? this.favicon,
      enableUserRegistration:
          enableUserRegistration ?? this.enableUserRegistration,
      phoneNumberRequired: phoneNumberRequired ?? this.phoneNumberRequired,
      defaultPhoneCode: defaultPhoneCode ?? this.defaultPhoneCode,
      enableMultivendor: enableMultivendor ?? this.enableMultivendor,
      timeZone: timeZone ?? this.timeZone,
      currencyIcon: currencyIcon ?? this.currencyIcon,
      currencyName: currencyName ?? this.currencyName,
      themeOne: themeOne ?? this.themeOne,
      themeTwo: themeTwo ?? this.themeTwo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'logo': logo,
      'favicon': favicon,
      'enable_user_register': enableUserRegistration,
      'phone_number_required': phoneNumberRequired,
      'default_phone_code': defaultPhoneCode,
      'enable_multivendor': enableMultivendor,
      'timezone': timeZone,
      'currency_icon': currencyIcon,
      'currency_name': currencyName,
      'theme_one': themeOne,
      'theme_two': themeTwo,
    };
  }

  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      logo: map['logo'] ?? '',
      favicon: map['favicon'] ?? '',
      enableUserRegistration: map['enable_user_register'] != null
          ? int.parse(map['enable_user_register'].toString())
          : 0,
      phoneNumberRequired: map['phone_number_required'] != null
          ? int.parse(map['phone_number_required'].toString())
          : 0,
      defaultPhoneCode: map['default_phone_code'] ?? '',
      enableMultivendor: map['enable_multivendor'] != null
          ? int.parse(map['enable_multivendor'].toString())
          : 0,
      timeZone: map['timezone'] as String,
      currencyIcon: map['currency_icon'] ?? '\$',
      currencyName: map['currency_name'] ?? '',
      themeOne: map['theme_one'] ?? '',
      themeTwo: map['theme_two'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingModel.fromJson(String source) =>
      SettingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      logo,
      favicon,
      enableUserRegistration,
      phoneNumberRequired,
      defaultPhoneCode,
      enableMultivendor,
      timeZone,
      currencyIcon,
      currencyName,
      themeOne,
      themeTwo,
    ];
  }
}
