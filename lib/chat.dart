import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String accountId;

  const Chat({Key? key, required this.chatRoomId, required this.accountId});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  final String webSocketUrl = 'http://localhost:8080/stomp/chat';
  late StompClient _client;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    _client = StompClient(
      config: StompConfig.sockJS(
        url: webSocketUrl,
        onConnect: onConnectCallback,
      ),
    );
    _client.activate();
    _fetchChatRoom();
  }

  void onConnectCallback(StompFrame connectFrame) {
    _client.subscribe(
      destination: '/exchange/chat.exchange/room.${widget.chatRoomId}',
      headers: {},
      callback: (frame) {
        setState(() {
          messages.add(json.decode(frame.body!));
        });
      },
    );
  }

  Future<void> _fetchChatRoom() async {
    final url = Uri.parse("http://localhost:8080/chat/room/resp?chatRoomId=${widget.chatRoomId}&accountId=${widget.accountId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final chatMessages = jsonResponse['chatMessagesInRoom'];
      setState(() {
        messages.addAll(chatMessages);
      });
    } else {
      throw Exception("Failed to fetch chat room");
    }
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      _client.send(
        destination: '/pub/chat.message.${widget.chatRoomId}',
        body: json.encode({
          'chatRoomId': widget.chatRoomId,
          'message': message,
          'accountId': widget.accountId,
          'nickname': 'test',
        }), // Format the message as needed
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = messages[index];
                  bool isMyMessage = item['accountId'] == widget.accountId;
                  return Column(
                    crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nickname'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Align(
                        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isMyMessage ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item['message'],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _client.deactivate();
    _controller.dispose();
    super.dispose();
  }
}
