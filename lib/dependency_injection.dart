import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dependency_injection_packages.dart';
import 'logic/cubit/auth/auth_cubit.dart';
import 'logic/cubit/chat/chat_list_cubit.dart';
import 'logic/cubit/chat/conversation_cubit.dart';
import 'logic/repository/conversation_repository.dart';

class DInjector {
  static late final SharedPreferences _sharedPreferences;

  static Future<void> initDB() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static final repositoryProvider = <RepositoryProvider>[
    RepositoryProvider<Client>(create: (context) => Client()),
    RepositoryProvider<SharedPreferences>(
      create: (context) => _sharedPreferences,
    ),
    RepositoryProvider<RemoteDataSources>(
      create: (context) => RemoteDataSourcesImpl(client: context.read()),
    ),
    RepositoryProvider<LocalDataSources>(
      create: (context) =>
          LocalDataSourcesImpl(sharedPreferences: context.read()),
    ),
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        remoteDataSources: context.read(),
        localDataSources: context.read(),
      ),
    ),
    RepositoryProvider<SettingRepository>(
      create: (context) => SettingRepositoryImpl(
        remoteDataSources: context.read(),
        localDataSources: context.read(),
      ),
    ),
    RepositoryProvider<ConversationRepository>(
      create: (context) => ConversationRepositoryImpl(
        remoteDataSources: context.read(),
      ),
    ),
  ];

  static final blocProviders = <BlocProvider>[
    BlocProvider<InternetStatusBloc>(create: (context) => InternetStatusBloc()),
    BlocProvider<CurrencyCubit>(create: (context) => CurrencyCubit()),
    BlocProvider<LoginBloc>(
      create: (BuildContext context) => LoginBloc(repository: context.read()),
    ),
    BlocProvider<SettingCubit>(
      create: (BuildContext context) =>
          SettingCubit(repository: context.read()),
    ),
    BlocProvider<AuthCubit>(create: (BuildContext context) => AuthCubit()),

    // Chat cubits - ChatListCubit is provided at app level for global access
    // ConversationCubit is created at screen level since it's specific to each conversation
    BlocProvider<ChatListCubit>(
      create: (BuildContext context) => ChatListCubit(),
    ),
    BlocProvider<ConversationCubit>(
      create: (BuildContext context) => ConversationCubit(repository: context.read<ConversationRepository>()),
    ),
  ];
}
