import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chat.dart';

class ChatRoomList extends StatelessWidget {
  final String accountId;

  const ChatRoomList({super.key, required this.accountId});

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

  const ChatRoomListScreen({super.key, required this.accountId});

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
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        chatRooms = jsonList.map((json) => ChatRoomResponseDTO.fromJson(json)).toList();
      });

      for (final chatRoom in chatRooms) {
        _subscribeToChatRoom(chatRoom.id);
      }
    } else {
      throw Exception("Failed to fetch chat rooms");
    }
  }

  void _subscribeToChatRoom(String chatRoomId) {
    var roomId = chatRoomId;
    var eventSource = EventSource('http://localhost:8080/chat/connect/$roomId');

    eventSource.addEventListener('connect', (e) {
      print('connect event data');
    });

    eventSource.addEventListener('chat', (e) {
      var event = e as MessageEvent;
      var eventData = jsonDecode(event.data);
      var chatRoomId = eventData['chatRoomId'];
      var message = eventData['message'];

      setState(() {
        for (var i = 0; i < chatRooms.length; i++) {
          var room = chatRooms[i];
          if (room.id == chatRoomId) {
            room.recentMessage = message;

            // Move the updated chat room to the top of the list
            var updatedRoom = chatRooms.removeAt(i);
            chatRooms.insert(0, updatedRoom);
            break; // Exit loop as the updated chat room is processed
          }
        }
      });
    });
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
                // Inside the ListView.builder's itemBuilder method
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  color: Color(0xFF224488),
                  elevation: 4.0, // Add elevation for a raised effect
                  child: ListTile(
                    title: Text(chatRoom.nickname, style: TextStyle(color: Colors.white),),
                    subtitle: Text(
                      chatRoom.recentMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(chatRoom.nickname[0], style: TextStyle(color: Color(0xFF224488)),),
                    ),
                    onTap: () {
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
                  ),
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
  final String nickname;
  final String clientId;
  final String brokerId;
  String recentMessage;

  ChatRoomResponseDTO({
    required this.id,
    required this.participantIds,
    required this.nickname,
    required this.clientId,
    required this.brokerId,
    required this.recentMessage,
  });

  factory ChatRoomResponseDTO.fromJson(Map<String, dynamic> json) {
    return ChatRoomResponseDTO(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      nickname: json['nickname'],
      clientId: json['clientId'],
      brokerId: json['brokerId'],
      recentMessage: json['recentMessage'],
    );
  }
}
