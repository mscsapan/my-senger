import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/setting/currencies_model.dart';
import 'currency_state_model.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyStateModel> {
  CurrencyCubit() : super(CurrencyStateModel.init());

  void addNewCurrency(CurrenciesModel newCurrency) {
    final updatedCurrencies = List.of(state.currencies)..add(newCurrency);
    debugPrint('new-currency-added ${updatedCurrencies.length}');
    emit(state.copyWith(currencies: updatedCurrencies));
  }
}
