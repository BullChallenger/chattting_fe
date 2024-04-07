import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chat.dart';

class ChatRoomList extends StatelessWidget {
  final String accountId;

  const ChatRoomList({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat Room List'),
        ),
        body: ChatRoomListScreen(accountId: accountId),
      ),
    );
  }
}

class ChatRoomListScreen extends StatefulWidget {
  final String accountId;

  const ChatRoomListScreen({Key? key, required this.accountId}) : super(key: key);

  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  late List<ChatRoomResponseDTO> chatRooms = [];

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final url = Uri.parse("http://localhost:8080/chat/${widget.accountId}/room");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        chatRooms = jsonList.map((json) => ChatRoomResponseDTO.fromJson(json)).toList();
      });
    } else {
      throw Exception("Failed to fetch chat rooms");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return ListTile(
                  title: Text('채팅방'),
                  subtitle: Text('걍 연습용 채팅방임'),
                  onTap: () {
                    // Navigate to chat room page with the selected chat room ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          chatRoomId: chatRoom.id,
                          accountId: widget.accountId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatRoomResponseDTO {
  final String id;
  final List<String> participantIds;
  final String clientId;
  final String brokerId;

  ChatRoomResponseDTO({
    required this.id,
    required this.participantIds,
    required this.clientId,
    required this.brokerId,
  });

  factory ChatRoomResponseDTO.fromJson(Map<String, dynamic> json) {
    return ChatRoomResponseDTO(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      clientId: json['clientId'],
      brokerId: json['brokerId'],
    );
  }
}

