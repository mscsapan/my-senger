import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/notification_service.dart';

import '../../../logic/cubit/auth/auth_cubit.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver{
  final _homeController = MainController();
  late AuthCubit loginBloc;
  late List<Widget> screenList;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init(){
    WidgetsBinding.instance.addObserver(this);

    loginBloc = context.read<AuthCubit>()..fetchUserData();

    screenList = [
      const HomeScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    initFCMToken();

  }

  Future<void> initFCMToken()async{
    await NotificationService().initializeFcmToken();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('calledddddddddd ${state.toString()}');
    if (state == AppLifecycleState.resumed) {
      debugPrint('current-app-state resumed');
    } else if (state == AppLifecycleState.inactive) {
      debugPrint('current-app-state inactive');
    } else if (state == AppLifecycleState.paused) {
      debugPrint('current-app-state paused');
    } else if (state == AppLifecycleState.hidden) {
      debugPrint('current-app-state hidden');
    } else if (state == AppLifecycleState.detached) {
      debugPrint('current-app-state detached');
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
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
        bottomNavigationBar: MyBottomNavigationBar(),
      ),
    );
  }
}
