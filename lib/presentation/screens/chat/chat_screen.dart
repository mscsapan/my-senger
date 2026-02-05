import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: dummyChatList.length,
        padding: DataUtils.only(bottom: 20.0),
        itemBuilder: (context, index) {
          final item = dummyChatList[index];
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  MessagesScreen(chat: item),
                ),
              );
            },
            child: ChatItem(item: item),
          );
        },
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  const ChatItem({super.key, required this.item});

  final DummyModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DataUtils.symmetric(h: 14.0,v: 12.0),
      child: Row(
        children: [
           CircleImage(image: item.image,size: 48.0),
          DataUtils.horizontalSpace(8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(text: item.name,maxLine: 1,fontWeight: FontWeight.w700,fontSize: 16.0),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Flexible(child: CustomText(text: item.value,maxLine: 1,fontWeight: FontWeight.w500,fontSize: 14.0)),
                //     // Column(
                //     //   children: [
                //     //     CustomText(text: item.time,fontWeight: FontWeight.w600,fontSize: 14.0,color: AppColor.darkLightest6C7576,),
                //     //     CircleAvatar(maxRadius: 10.0,backgroundColor: AppColor.primaryOne4B9EFF,child: CustomText(text: '4',color: AppColor.whiteFFFFFF,),),
                //     //   ],
                //     // ),
                //   ],
                // ),
                Flexible(child: CustomText(text: item.value,maxLine: 1,fontWeight: FontWeight.w500,fontSize: 14.0)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(text: item.time,fontWeight: FontWeight.w600,fontSize: 14.0,color: AppColor.darkLightest6C7576),
              if(item.unreadMsg > 0)...[
                DataUtils.verticalSpace(4.0),
                CircleAvatar(maxRadius: 10.0,backgroundColor: AppColor.primaryOne4B9EFF,child: CustomText(text: '${item.unreadMsg}',color: AppColor.whiteFFFFFF,fontWeight: FontWeight.w500,),),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
