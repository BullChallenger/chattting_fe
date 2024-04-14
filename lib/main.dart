import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mychat/chat.dart';

import 'chatRoomList.dart';

void main() {
  runApp(ChatRoomForm());
}

class ChatRoomForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stream Builder",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: ChatRoomList(accountId: 'qqweqweeqw'),
      // home: Chat(accountId: 'qqweqweeqw', chatRoomId: '1e49ce63-1780-4692-9474-8f7061a7a98c'),
    );
  }
}