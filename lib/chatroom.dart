import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatRoomForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Chat Room'),
        ),
        body: ChatRoomScreen(),
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _agentIdController = TextEditingController();

  Future<void> _createChatRoom() async {
    final url = Uri.parse("http://localhost:8080/chat/create");
    final response = await http.post(
      url,
      body: jsonEncode({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "clientId": _clientIdController.text,
        "agentId": _agentIdController.text,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      // Handle successful response as needed
    } else {
      throw Exception("Failed to create chat room");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: _clientIdController,
            decoration: InputDecoration(labelText: 'Client ID'),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: _agentIdController,
            decoration: InputDecoration(labelText: 'Agent ID'),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              _createChatRoom();
            },
            child: Text('Create Chat Room'),
          ),
        ],
      ),
    );
  }
}
