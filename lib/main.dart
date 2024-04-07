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
    var randomId = generateRandomId();
    print(randomId);
    return MaterialApp(
      title: "Stream Builder",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: ChatRoomList(accountId: 'qqweqweeqw'),
    );
  }
}

String generateRandomId() {
  var random = Random();
  var randomId = List.generate(10, (index) => random.nextInt(10)).join();
  return 'user_$randomId';
}
