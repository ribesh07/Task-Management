import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/domain/services/sendfcm.dart';
import 'package:task_management_app/presentation/providers/fcm_token_provider.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatPage({super.key, this.chatId = 'global'});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  // final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    ref.read(fcmTokenInitializerProvider);

    // ref.watch(chatStreamProvider(widget.chatId));
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://websocket-server-2eur.onrender.com'),
    );

    _channel.stream.listen((data) {
      final msg = jsonDecode(data);
      if (msg['chatId'] == widget.chatId) {
        // setState(() => _messages.add(msg));
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final chatStream = ref.watch(chatStreamProvider(widget.chatId));

    final userToken = ref.watch(fcmTokenProvider);
    if (userToken == null)
      return const Center(child: CircularProgressIndicator());
    // token = userToken ?? '';
    void _send() async {
      final text = _controller.text.trim();
      if (text.isEmpty) return;

      final message = {
        'token': userToken,
        'text': text,
        'chatId': widget.chatId,
      };

      _channel.sink.add(jsonEncode(message));
      _controller.clear();

      await ref.read(chatRepositoryProvider).saveMessage(
            widget.chatId,
            userToken,
            text,
          );
      await sendFCMToAllTokens(
        title: 'Task Status Updated',
        body: 'Message from "${widget.chatId}" : "$text"',
      );
    }

    Widget _buildBubble(Map<String, dynamic> msg) {
      final isMe = msg['token'] == userToken;
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(msg['text'] ?? '', style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.chatId}')),
      body: Column(
        children: [
          Expanded(
            child: chatStream.when(
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (_, i) => _buildBubble(messages[i]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
