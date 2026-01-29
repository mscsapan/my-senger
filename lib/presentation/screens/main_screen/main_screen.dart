import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/login_state_model.dart';
import '../../../logic/bloc/login/login_bloc.dart';

import '../chat/chat_screen.dart';
import '../home/home_screen.dart';

import '../profile/profile_screen.dart';
import 'component/bottom_navigation_bar.dart';
import 'component/main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _homeController = MainController();
  late LoginBloc loginBloc;
  late List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    loginBloc = context.read<LoginBloc>();
    _init();

  }

  void _init(){
    screenList = [
      const HomeScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        body: StreamBuilder<int>(
          initialData: 0,
          stream: _homeController.naveListener.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            int item = snapshot.data ?? 0;
            return screenList[item];
          },
        ),
        bottomNavigationBar: BlocBuilder<LoginBloc, LoginStateModel>(
          builder: (context, state) {
            //_init();

            return MyBottomNavigationBar();

            // if (state is DashboardStateLoaded) {
            //   return const MyBottomNavigationBar();
            // }
            // if (dCubit.dashboardModel != null) {
            //   return const MyBottomNavigationBar();
            // } else {
            //   return const SizedBox.shrink();
            // }
          },
        ),
      ),
    );
  }
}
