import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _messageController = TextEditingController();
  final String apiKey = 'AIzaSyD4Q6sUNZiz4i_mT9BhAMLUVdc14yQ-nu4'; // Replace with your actual API key

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        _chatMessages.add(ChatMessage(message, true));
      });

      // Simulate sending the user message to the AI backend
      _getAIResponse(message);
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    final apiUrl =
        'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key=$apiKey';

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      "prompt": {"text": userMessage},
      "temperature": 0.7,
      "candidateCount": 1,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final aiResponse = responseData['candidates'][0]['output'];

        setState(() {
          _chatMessages.add(ChatMessage(aiResponse, false));
        });
      } else {
        // Handle API error here
        print('API Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors here
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chatbot'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chatMessage = _chatMessages[index];
                return ListTile(
                  title: Text(chatMessage.text),
                  subtitle: chatMessage.isUser ? Text('User') : Text('AI'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
