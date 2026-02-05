import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../common/theme/colors.dart';
import '../../../../../common/widgets/custom_image.dart';
import '../../../../../utils/data_utils/data_utils.dart';



class SupportInputField extends StatelessWidget {
  SupportInputField({super.key});

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // final mCubit = context.read<BidCubit>();
    return Container(
      margin: DataUtils.symmetric(v: 8.0, h: 12.0).copyWith(bottom: 8),
      child: Row(
        children: [
          Expanded(child: TextFormField(
            focusNode: focusNode,
            textInputAction: TextInputAction.done,
            //initialValue: state.message,
            // controller: mCubit.messageController,
            style: const TextStyle(fontSize: 14.0),
            onChanged: (String text) {
              //print('onChanged $text');
              // mCubit.messageChange(text);
            },
            decoration: InputDecoration(
              hintText: '${DataUtils.localizeText(context)?.writeHere}...',
              //contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0),borderSide:   BorderSide(color: AppColor.inputBorderRegularE4E5E7),),
              enabledBorder:  OutlineInputBorder(
                // borderRadius: BorderRadius.circular(0.0),
                borderSide:  BorderSide(color: AppColor.inputBorderRegularE4E5E7),
              ),
              focusedBorder:  OutlineInputBorder(
                // borderRadius: BorderRadius.circular(0.0),
                borderSide:  BorderSide(color: AppColor.inputBorderFocus469FFF),
              ),
              /*suffixIcon: IconButton(
                splashRadius: 1.0,
                onPressed: () {
                  Utils.closeKeyBoard(context);
                  mCubit.sendTicketMessage();
                  mCubit.messageController.clear();
                  // mCubit.clear();
                },
                icon: Icon(
                  Icons.send_rounded,
                  // color:  greenColor ,
                  color: state.message.trim().isNotEmpty ? greenColor : grayColor,
                  size: 30.0,
                ),
              ),*/
              prefixIcon: IconButton(
                splashRadius: 0.5,
                onPressed: () async {
                  // mCubit.docClear();
                  //
                  // int totalSize = 0;
                  //
                  // const maxFileSize = 2 * 1024 * 1024;
                  //
                  // final img = await Utils.pickMultipleFile();
                  //
                  // if (img.isNotEmpty) {
                  //   for (final i in img) {
                  //     final file = File(i);
                  //     final fileSize = await file.length();
                  //     totalSize +=  fileSize;
                  //   }
                  // }
                  //
                  // if (totalSize > maxFileSize) {
                  //   Utils.errorSnackBar(context, 'Files size should not exceed 2MB');
                  //   return;
                  // } else {
                  //   for (final i in img) {
                  //     mCubit.documentChange(i);
                  //   }
                  // }
                },
                icon:  Icon(
                  Icons.attach_file,
                  color: AppColor.darkLightest6C7576,
                  size: 30.0,
                ),
              ),
              // fillColor: fillColor,
            ),
          )),
          //if(state.message.trim().isNotEmpty)...[


          GestureDetector(
            onTap: (){
              // if(auction?.bidId.isNotEmpty??false){
              //   bidCubit.detailId(auction?.bidId??'');
              //   Navigator.pushNamed(context,RouteNames.bidingDetailScreen);
              // }
              // mCubit.sendTicketMessage();
            },
            child:Container(
              height: 48.0,
              width: 48.0,
              decoration: BoxDecoration(
                  color: AppColor.primaryOne4B9EFF,
                  borderRadius: DataUtils.borderRadius(r: 4.0)
              ),
              margin: DataUtils.only(left: 10.0),
              padding: DataUtils.all(value: 10.0),
              child: const CustomImage(path: 'assets/send_icon.svg'),
            ),
          ),
          //]
        ],
      ),
    );
  }
}
