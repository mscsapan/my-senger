import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_senger/logic/cubit/auth/auth_cubit.dart';
import 'package:my_senger/presentation/routes/route_packages_name.dart';

import '../../../data/models/auth/auth_state_model.dart';
import '../../routes/route_names.dart';
import '../../utils/k_images.dart';
import '../../utils/navigation_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthCubit authCubit;
  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    _init();
    super.initState();
  }

  void _init() {
   authCubit = context.read<AuthCubit>()..checkAuthStatus();
  }

  void _goToNext() {
    Navigator.pushNamedAndRemoveUntil(context, RouteNames.authScreen, (route) => false);
  }


  // _dispose(){
  //   debugPrint('screen-disposed');
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  // }

  @override
  Widget build(BuildContext context) {
    /*return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: whiteColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: transparent,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarDividerColor: transparent,
      ),
      child: Scaffold(
        body: Container(
          height: Utils.mediaQuery(context).height,
          width: Utils.mediaQuery(context).width,
          padding: Utils.symmetric(h: 60.0),
          child: const CustomImage(path: KImages.splashBg),
        ),
      ),
    );*/
    return Scaffold(
      body: BlocListener<AuthCubit, AuthStateModel>(
        listener: (context,authState){
          final state = authState.authState;

          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, RouteNames.mainScreen, (route) => false);
          } else if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, RouteNames.authScreen, (route) => false);
          }
        },
        child: Container(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        padding: Utils.symmetric(h: 60.0),
        child: const CustomImage(path: KImages.splashBg),
      ),
      ),
    );
  }
}
