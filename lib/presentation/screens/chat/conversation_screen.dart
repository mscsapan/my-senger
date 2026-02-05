import 'package:flutter/material.dart';
import 'package:my_senger/presentation/routes/route_packages_name.dart';

import '../../../data/dummy_data/dummy_data.dart';
import '../../utils/utils.dart';
import '../../widgets/circle_image.dart';
import '../../widgets/custom_text.dart';
import 'component/conversation_component.dart';
import 'component/conversation_input_field.dart';
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.chat});
  final DummyModel chat;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leadingWidth: 30.0,
        // leading: Padding(
        //   padding: Utils.symmetric(h: 18.0),
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
            Utils.horizontalSpace(10.0),
            CustomText(text: widget.chat.name,fontWeight: FontWeight.w600,fontSize: 16.0,color: whiteColor,height: 1.6,),
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
              padding: Utils.symmetric(h: 0.0, v: 14.0),
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                final m = dummyMessages[index];
                final isSeller = m.sendBy == 'user';
                return ConversationComponent(m: m, isSeller: isSeller);
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
        ConversationInputField(),
      ],
    );
  }
}
