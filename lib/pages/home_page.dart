import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 模拟消息列表
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'assistant',
      'content': '你好！ Felix。我是你的规划助手。你可以告诉我任何想要完成的目标，我会为你拆解成可执行的步骤。',
      'time': '今天',
    }
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'time': '刚刚',
      });
      _messageController.clear();
    });

    // 自动回复演示
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': '收到你的目标 "$text"，正在为你规划...',
            'time': '刚刚',
          });
        });
        _scrollToBottom();
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80, // 增加高度以容纳更多信息
        titleSpacing: 24,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 规划师',
                  style: TextStyle(
                    color: Color(0xFF1E293B), // Slate 800
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), // Green 500
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '在线 · 2026年02月27日',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)), // Indigo 500
              onPressed: () {
                // TODO: 打开设置或切换模型
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 聊天区域
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final showDate = index == 0 || _messages[index - 1]['time'] != msg['time'];

                return Column(
                  children: [
                    if (showDate) 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['time'],
                            style: const TextStyle(
                              color: Color(0xFF94A3B8), // Slate 400
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5), // Indigo 600
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            ),
                          
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser 
                                  ? const Color(0xFF4F46E5) // Indigo 600
                                  : const Color(0xFFF1F5F9), // Slate 100
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 20),
                                ),
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                           if (isUser)
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(left: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5), // Indigo 600
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: Text('F', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 底部输入区域
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC), // Slate 50
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: '输入任务，如：写一份重构报告',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5), // Indigo 600
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x404F46E5),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}