import 'package:flutter/material.dart';

import '../../utils/k_images.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        padding: Utils.symmetric(h: 60.0),
        child: const CustomImage(path: KImages.splashBg),
      ),
    );
  }

// Widget _circleSplash() {
//   return Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Spacer(),
//         Spacer(),
//         Spacer(),
//         CustomImage(path: KImages.splashBg),
//         Spacer(),
//         Spacer(),
//         SpinKitFadingCircle(color: secondaryColor, size: 60.0),
//         Spacer(),
//       ],
//     ),
//   );
// }
}
