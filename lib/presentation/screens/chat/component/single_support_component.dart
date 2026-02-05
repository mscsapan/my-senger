import 'package:flutter/material.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../utils/constraints.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_text.dart';


// ignore: must_be_immutable
class SingleSupportComponent extends StatelessWidget {
  SingleSupportComponent({super.key, required this.m, required this.isSeller});

  final DemoMessage m;
  final bool isSeller;
  double radius = 8.0;

  @override
  Widget build(BuildContext context) {
    // final msgCubit = context.read<BidCubit>();
    return Row(
      mainAxisAlignment:
          isSeller ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding: Utils.symmetric(h: 12.0, v: 12.0),
            margin: Utils.symmetric(h: 16.0, v: 10.0).copyWith(top: 0.0),
            decoration: BoxDecoration(
              color: !isSeller ? gray5B : greenColor.withValues(alpha: 0.2),
              // color: isSeller ? AppColor.colorBg2GreyF1 : AppColor.info10CCE4 .withValues(alpha: 0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
                bottomLeft: Radius.circular(isSeller ? radius : 0.0),
                bottomRight: Radius.circular(isSeller ? 0.0 : radius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // state.downloadProgress > 0 && state.downloadProgress < 1
                //     ? LinearProgressIndicator(
                //         value: state.downloadProgress, color: redColor)
                //     : const SizedBox(),
                Flexible(
                  child: CustomText(
                    text: m.message,
                    maxLine: 20,
                    color: blackColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                /* if (m.documents?.isNotEmpty??false) ...[
                      Utils.verticalSpace(6.0),
                      ...List.generate(m.documents?.length??0, (index) {
                        final doc = m.documents?[index];
                        if(doc?.document.isNotEmpty??false){
                          return GestureDetector(
                            onTap: () async {
                              debugPrint('image-path ${doc?.document}');
                              bool permissionGranted =
                              await Utils.getStoragePermission();
                              if (permissionGranted) {
                                final ext = doc?.document.split('.').last;
                                debugPrint('extension $ext');
                                final result = await msgCubit.chatFileDownload(doc?.document??'',ext??'jpeg');
                                result.fold((failure) {
                                  Utils.errorSnackBar(context, "Something went wrong!");
                                }, (success) {
                                  if (success) {
                                    Utils.showSnackBar(context, "Downloaded");
                                  } else {
                                    Utils.errorSnackBar(context, "Download Failed");
                                  }
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.download_rounded,
                                    size: 16.0,
                                    color:  blackColor),
                                Utils.horizontalSpace(2.0),
                                const CustomText(
                                    text: 'Download',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.0,
                                    color: blackColor),
                              ],
                            ),
                          );
                        }else{
                          return const SizedBox.shrink();
                        }
                      })
                    ],*/
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// void showImage(BuildContext context, String path) {
//   Utils.showCustomDialog(context, child: CustomImage(path: path));
// }
