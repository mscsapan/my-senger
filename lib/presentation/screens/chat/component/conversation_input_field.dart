import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/presentation/utils/k_images.dart';

import '../../../utils/constraints.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';


class ConversationInputField extends StatelessWidget {
  ConversationInputField({super.key});

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // final mCubit = context.read<BidCubit>();
    return Container(
      margin: Utils.symmetric(v: 8.0, h: 12.0).copyWith(bottom: 8),
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
              hintText: 'Message',
              hintStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: blackColor,
              ),
              contentPadding: Utils.symmetric(h: 14.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0),borderSide:   BorderSide(color: borderColor),),
              enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide:  BorderSide(color: borderColor),
              ),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide:  BorderSide(color: borderColor),
              ),
             suffixIcon: SizedBox.shrink(),
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
                  color: primaryColor,
                  shape: BoxShape.circle
                  //borderRadius: Utils.borderRadius(r: 50.0)
              ),
              margin: Utils.only(left: 10.0),
              padding: Utils.all(value: 12.0),
              child:  CustomImage(path: KImages.sendIcon),
            ),
          ),
          //]
        ],
      ),
    );
  }
}
