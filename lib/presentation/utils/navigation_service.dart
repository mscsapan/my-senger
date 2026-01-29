import 'package:flutter/material.dart';
import '../../presentation/utils/constraints.dart';
import '../../presentation/widgets/custom_text.dart';



class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  // Basic navigation
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    // Logger.navigation('Navigating to: $routeName');
    return navigator?.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments}) async {
    // Logger.navigation('Navigate and replace to: $routeName');
    return navigator?.pushReplacementNamed<T, Object?>(routeName, arguments: arguments);
  }

  static Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments}) async {
    // Logger.navigation('Navigate and clear stack to: $routeName');
    return navigator?.pushNamedAndRemoveUntil<T>(
      routeName, (route) => false,
      arguments: arguments,
    );
  }

  static void goBack<T>([T? result]) {
    // Logger.navigation('Going back');
    if (canGoBack()) {
      navigator?.pop<T>(result);
    }
  }

  static bool canGoBack() {
    return navigator?.canPop() ?? false;
  }

  // Dialog navigation
  static Future<T?> showDialogRoute<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    // Logger.navigation('Showing dialog');
    return showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => dialog,
    );
  }

  // Bottom sheet navigation
  static Future<T?> showBottomSheetRoute<T>({
    required Widget bottomSheet,
    bool isScrollControlled = false,
  }) {
    // Logger.navigation('Showing bottom sheet');
    return showModalBottomSheet<T>(
      context: context!,
      isScrollControlled: isScrollControlled,
      builder: (context) => bottomSheet,
    );
  }

  // Snackbar
  static void errorSnackBar(BuildContext context, String errorMsg,[int time = 2000]) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: time),
          content: CustomText(text:errorMsg, color: redColor),
        ),
      );
  }


  // static void errorSnackBar(BuildContext context, String msg,
  //     [Color textColor = whiteColor, int time = 1000]) {
  //   Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: time < 2000 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
  //     gravity: ToastGravity.CENTER,
  //     backgroundColor: redColor,
  //     textColor: textColor,
  //     fontSize: 16.0,
  //   );
  // }

  static void showSnackBar(BuildContext context, String msg,
      [Color textColor = whiteColor, int time = 2000]) {
    final snackBar = SnackBar(
        duration: Duration(milliseconds: time),
        content: CustomText(text:msg, color: textColor));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // static void showSnackBar(BuildContext context, String msg,
  //     [Color textColor = whiteColor, int time = 1000]) {
  //   Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: time < 2000 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
  //     gravity: ToastGravity.CENTER,
  //     backgroundColor: greenColor,
  //     textColor: textColor,
  //     fontSize: 16.0,
  //   );
  // }

  static void serviceUnAvailable(BuildContext context, String msg,
      [Color textColor = whiteColor]) {
    final snackBar = SnackBar(
        backgroundColor: redColor,
        duration: const Duration(milliseconds: 500),
        content: CustomText(text:msg, color: textColor));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSnackBarWithAction(BuildContext context, String msg, VoidCallback onPress,
      [Color textColor = primaryColor]) {
    final snackBar = SnackBar(
      content: CustomText(text:msg, color: textColor),
      action: SnackBarAction(
        label: 'Active',
        onPressed: onPress,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

}
