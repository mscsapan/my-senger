import 'package:flutter/material.dart';
import 'package:peshajibi/common/theme/colors.dart';
import 'package:peshajibi/common/theme/text.dart';

import '../../../../common/dummy_model/dummy_model.dart';
import '../../../../common/widgets/circle_image.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/custom_text.dart';
import '../../../../utils/data_utils/data_utils.dart';
import 'component/single_support_component.dart';
import 'component/support_input_field.dart';
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.chat});
  final DummyModel chat;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: AppColor.whiteFFFFFF,
      appBar: AppBar(
        leadingWidth: 30.0,
        // leading: Padding(
        //   padding: DataUtils.symmetric(h: 18.0),
        //   child: GestureDetector(
        //     onTap: () => Navigator.of(context).pop(),
        //     child: Icon(Icons.arrow_back,color: AppColor.whiteFFFFFF),
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleImage(image: widget.chat.image,size: 44.0),
            DataUtils.horizontalSpace(10.0),
            CustomText(text: widget.chat.name,fontWeight: FontWeight.w600,fontSize: 16.0,color: AppColor.whiteFFFFFF,height: 1.6,),
          ],
        ),
        centerTitle: false,
        // leadingWidth: 20.0,
      ),
      body: const LoadedChat(),
    );
  }
}

class LoadedChat extends StatelessWidget {
  const LoadedChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (dummyMessages.isNotEmpty??false) ...[
          Expanded(
            child: ListView.builder(
              // controller: widget.controller,
              shrinkWrap: true,
              padding: DataUtils.symmetric(h: 0.0, v: 14.0),
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                final m = dummyMessages[index];
                final isSeller = m.sendBy == 'user';
                return SingleSupportComponent(m: m, isSeller: isSeller);
              },
            ),
          ),
        ] else ...[
          const Expanded(
            child: Center(
              // child: Text(Utils.translatedText(context, 'No messages available')),
              child: Text('No messages available'),
            ),
          ),
        ],
        SupportInputField(),
      ],
    );
  }
}
