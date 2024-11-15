import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../data/models/setting/currencies_model.dart';
import 'currency_cubit.dart';

class CurrencyStateModel extends Equatable {
  final List<CurrenciesModel> currencies;

  // final List<LanguageListModel> languages;
  final CurrencyState currencyState;

  const CurrencyStateModel({
    required this.currencies,
    // required this.languages,
    this.currencyState = const CurrencyInitial(),
  });

  CurrencyStateModel copyWith({
    List<CurrenciesModel>? currencies,
    // List<LanguageListModel>? languages,
    CurrencyState? currencyState,
  }) {
    return CurrencyStateModel(
      currencies: currencies ?? this.currencies,
      // languages: languages ?? this.languages,
      currencyState: currencyState ?? this.currencyState,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currencies': currencies.map((x) => x.toMap()).toList(),
      // 'languages': languages.map((x) => x.toMap()).toList(),
    };
  }

  factory CurrencyStateModel.fromMap(Map<String, dynamic> map) {
    return CurrencyStateModel(
      currencies: List<CurrenciesModel>.from(
        (map['currencies'] as List<dynamic>).map<CurrenciesModel>(
          (x) => CurrenciesModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      // languages: List<LanguageListModel>.from(
      //   (map['languages'] as List<dynamic>).map<LanguageListModel>(
      //         (x) => LanguageListModel.fromMap(x as Map<String, dynamic>),
      //   ),
      // ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrencyStateModel.fromJson(String source) =>
      CurrencyStateModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  static CurrencyStateModel init() {
    return const CurrencyStateModel(
      currencies: <CurrenciesModel>[],
      // languages: <LanguageListModel>[],
      currencyState: CurrencyInitial(),
    );
  }

  @override
  List<Object> get props => [currencies, currencyState];
}
