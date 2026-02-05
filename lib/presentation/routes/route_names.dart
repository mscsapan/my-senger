import 'package:flutter/material.dart';
import 'package:my_senger/presentation/screens/profile/update_profile_screen.dart';

import '../../data/dummy_data/dummy_data.dart';
import '../screens/authentication/sign_up_screen.dart';
import '../screens/chat/messages_screen.dart';
import '../screens/main_screen/main_screen.dart';
import 'route_packages_name.dart';

class RouteNames {
  ///authentication routes
  static const String splashScreen = '/splashScreen';
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String authScreen = '/authenticationScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String updatePasswordScreen = '/updatePasswordScreen';
  static const String verificationScreen = '/verificationScreen';
  static const String mainScreen = '/mainScreen';




  ///setting routes
  static const String privacyPolicyScreen = '/privacyPolicyScreen';


  ///profile routes
  static const String profileScreen = '/profileScreen';
  static const String updateProfile = '/updateProfile';
  static const String conversationScreen = '/conversationScreen';

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {

      case RouteNames.splashScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SplashScreen());

      case RouteNames.onBoardingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const OnBoardingScreen());

      case RouteNames.authScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const AuthScreen());
        case RouteNames.signUpScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SignUpScreen());

      case RouteNames.forgotPasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ForgotPasswordScreen());
      case RouteNames.updatePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const UpdatePasswordScreen());

      case RouteNames.verificationScreen:
        final isNew = settings.arguments as bool;
        return MaterialPageRoute(
            settings: settings,
            builder: (_) => OtpVerificationScreen(isNew: isNew));

      case RouteNames.changePasswordScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ChangePasswordScreen());

      case RouteNames.mainScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MainScreen());

        case RouteNames.updateProfile:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const UpdateProfileScreen());


    case RouteNames.conversationScreen:
      final chat = settings.arguments as DummyModel;
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  MessagesScreen(chat: chat));


      default:
        return MaterialPageRoute(
          builder: (BuildContext context) => Scaffold(
            body: FetchErrorText(
                text: 'No Route Found ${settings.name}', textColor: blackColor),
          ),
        );
    }
  }
}
