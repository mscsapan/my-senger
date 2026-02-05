import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/notification_service.dart';
import 'dependency_injection.dart';
import 'firebase_options.dart';
import 'presentation/routes/route_names.dart';
import 'presentation/utils/constraints.dart';
import 'presentation/utils/navigation_service.dart';
import 'presentation/widgets/custom_theme.dart';
import 'presentation/widgets/fetch_error_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firebase App Check with graceful error handling
  try {
    await FirebaseAppCheck.instance.activate(
      // Use debug provider in debug mode, Play Integrity in release mode
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      // Use debug provider in debug mode, App Attest in release mode
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
    debugPrint('✅ Firebase App Check activated successfully');
  } catch (e) {
    // In debug mode, allow app to continue even if App Check fails
    // In production, App Check failures will still be enforced by Firebase
    debugPrint('⚠️ Firebase App Check activation failed: $e');
    if (kDebugMode) {
      debugPrint('📝 Continuing in debug mode without App Check enforcement');
      debugPrint('💡 To fix: Register debug token in Firebase Console');
    }
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DInjector.initDB();

  // Initialize notification service
  await NotificationService().init();

  runApp(const MySenger());
}

class MySenger extends StatelessWidget {
  const MySenger({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375.0, 812.0),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (BuildContext context, child) {
        return MultiRepositoryProvider(
          providers: DInjector.repositoryProvider,
          child: MultiBlocProvider(
            providers: DInjector.blocProviders,
            child: MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: RouteNames.generateRoutes,
              initialRoute: RouteNames.splashScreen,
              theme: MyTheme.theme,
              onUnknownRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      body: FetchErrorText(
                        text: 'No Route Found ${settings.name}',
                        textColor: blackColor,
                      ),
                    );
                  },
                );
              },
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child ?? const SizedBox(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
