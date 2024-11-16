import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_senger/presentation/routes/route_packages_name.dart';

import '../../routes/route_names.dart';
import '../../utils/k_images.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    _init();
    super.initState();
  }

  _init() {
    Future.delayed(
        const Duration(seconds: 1),
        () => Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.authScreen, (route) => false));
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  _dispose(){
    debugPrint('screen-disposed');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
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
    );
  }
}
