// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatPageStatus extends Equatable {
  final String userId;
  final bool isOpenChatPage;
  const ChatPageStatus({
    required this.userId,
    required this.isOpenChatPage,
  });

  ChatPageStatus copyWith({
    String? userId,
    bool? isOpenChatPage,
  }) {
    return ChatPageStatus(
      userId: userId ?? this.userId,
      isOpenChatPage: isOpenChatPage ?? this.isOpenChatPage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'is_open_chat_page': isOpenChatPage,
    };
  }

  factory ChatPageStatus.fromMap(Map<String, dynamic> map) {
    return ChatPageStatus(
      userId: map['user_id'] ?? '',
      isOpenChatPage: map['is_open_chat_page'] ??false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatPageStatus.fromJson(String source) => ChatPageStatus.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [userId, isOpenChatPage];
}
