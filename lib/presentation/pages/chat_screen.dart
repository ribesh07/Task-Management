import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/domain/services/sendfcm.dart';
import 'package:task_management_app/presentation/providers/fcm_token_provider.dart';
import 'package:task_management_app/presentation/providers/task_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatPage({super.key, this.chatId = 'Global'});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  late final WebSocketChannel _channel;
  String? _tappedMessageKey;

  @override
  void initState() {
    super.initState();
    ref.read(fcmTokenInitializerProvider);

    _channel = WebSocketChannel.connect(
      Uri.parse('wss://socket-7mzn.onrender.com'),
    );

    _channel.stream.listen((data) {
      final msg = jsonDecode(data);
      if (msg['chatId'] == widget.chatId) {
        // setState(() => _messages.add(msg));
        print('/n/n/nSocket : $msg');
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
    if (userToken == null) {
      return const Center(child: CircularProgressIndicator());
    }

    void _send() async {
      final text = _controller.text.trim();
      if (text.isEmpty) return;

      final message = {
        'token': userToken,
        'text': text,
        'chatId': widget.chatId,
      };

      _channel.sink.add(jsonEncode(message));
      setState(() {});
      _controller.clear();

      await ref.read(chatRepositoryProvider).saveMessage(
            widget.chatId,
            userToken,
            text,
          );
      await sendFCMToAllTokens(
        title: 'Chat',
        body: '${widget.chatId} : $text',
      );
    }

    // String formatFullDate(Timestamp timestamp) {
    //   final dt = timestamp.toDate();
    //   return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    // }

    String formatRelativeTime(Timestamp timestamp) {
      final dt = timestamp.toDate();
      return timeago.format(dt);
    }

    Widget _buildBubble(Map<String, dynamic> msg) {
      final isMe = msg['token'] == userToken;

      final timestamp = msg['timestamp'];
      if (timestamp == null) {
        return Container();
      }
      final ts = timestamp as Timestamp;
      final messageKey = '${msg['token']}_${ts.millisecondsSinceEpoch}';
      final isTapped = _tappedMessageKey == messageKey;

      return GestureDetector(
        onTap: () {
          setState(() {
            _tappedMessageKey =
                _tappedMessageKey == messageKey ? null : messageKey;
          });
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: isMe ? Colors.blue[400] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(msg['text'] ?? '',
                    style: const TextStyle(fontSize: 16)),
              ),
              if (isTapped)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(formatRelativeTime(ts),
                          style: const TextStyle(
                            fontSize: 12,
                          )),
                      const SizedBox(width: 8),
                      Text(("By ${msg['token'].substring(0, 6)}"),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chatId} Chat',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            )),
        backgroundColor: Colors.blue,
      ),
      // backgroundColor: Colors.blue[100],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 120, 191, 241),
              Color.fromARGB(255, 251, 250, 252),
              Color.fromARGB(255, 106, 178, 230),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          )),
          child: Column(
            children: [
              Expanded(
                child: chatStream.when(
                  data: (messages) => ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _buildBubble(messages[i]),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                child: Row(
                  children: [
                    // const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      iconSize: 43,
                      color: Colors.blue[700],
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
