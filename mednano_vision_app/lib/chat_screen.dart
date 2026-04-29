import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "مرحباً بك! أنا المساعد الطبي لـ Mednano. العقل اللغوي متصل وجاهز للتحليل."}
  ];

  // الكوبري اللي بيكلم كود الكوتلن (MainActivity)
  static const platform = MethodChannel('mednano.ai/pytorch');

  bool _isTyping = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isTyping = true;
      _controller.clear();
    });

    try {
      final directory = await getApplicationSupportDirectory();
      final modelPath = "${directory.path}/mednano_edge.ptl";

      // إرسال السؤال للأندرويد
      final String result = await platform.invokeMethod('generateText', {
        'prompt': userText,
        'modelPath': modelPath,
      });

      setState(() {
        _messages.add({"role": "bot", "text": result});
        _isTyping = false;
      });

    } on PlatformException catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "⚠️ خطأ في الاتصال بالمحرك: ${e.message}"});
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المساعد الطبي الذكي"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // 🔴 الـ SafeArea اهي متركبة صح ومقفولة بأقواسها
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.teal.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Text(msg["text"]!, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "اكتب سؤالك الطبي هنا...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
