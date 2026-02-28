import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoggedIn;
  final VoidCallback onLocalMode;
  const LoginPage({
    super.key,
    required this.onLoggedIn,
    required this.onLocalMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _wechatController = TextEditingController();
  bool _useWechat = false;

  void _submit() {
    // 占位：后续接入真实校验/请求
    widget.onLoggedIn();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                '规划应用登录',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '参考 app.html 的卡片与色彩，后续可嵌入进度、统计等组件。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
              ),
              const SizedBox(height: 32),
              ToggleButtons(
                isSelected: [_useWechat == false, _useWechat == true],
                onPressed: (index) {
                  setState(() {
                    _useWechat = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('手机号登录'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('微信号登录'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!_useWechat)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '手机号',
                    hintText: '请输入手机号',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              else
                TextField(
                  controller: _wechatController,
                  decoration: InputDecoration(
                    labelText: '微信号',
                    hintText: '请输入微信号',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                child: const Text('立即登录'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: Colors.indigo, width: 1.5),
                ),
                onPressed: () {
                  widget.onLocalMode();
                  if (mounted) context.go('/home');
                },
                child: const Text('暂不登录，使用本地模式'),
              ),
              const SizedBox(height: 12),
              Text(
                '本地模式下，所有数据仅保存在您的设备上。您可以随时在"我的"页面登录以启用云同步功能。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}