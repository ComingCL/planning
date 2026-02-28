import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    final items = auth.isLocalMode
        ? [
            ('登录账号', Icons.login),
            ('通知设置', Icons.notifications),
            ('关于应用', Icons.info),
          ]
        : [
            ('账号信息', Icons.person),
            ('通知设置', Icons.notifications),
            ('数据同步', Icons.sync),
            ('退出登录', Icons.logout),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mode indicator card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: auth.isLocalMode
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: auth.isLocalMode
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF86EFAC),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  auth.isLocalMode ? Icons.phone_android : Icons.cloud_done,
                  color: auth.isLocalMode
                      ? const Color(0xFFD97706)
                      : const Color(0xFF16A34A),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isLocalMode ? '本地模式' : '已登录',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isLocalMode ? '数据仅保存在本设备' : '数据已同步到云端',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Existing list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  tileColor: Colors.white,
                  leading: Icon(item.$2, color: const Color(0xFF4F46E5)),
                  title: Text(item.$1,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  onTap: () {
                    if (auth.isLocalMode && index == 0) {
                      // Navigate to login
                      context.go('/login');
                    } else if (!auth.isLocalMode && item.$1 == '退出登录') {
                      // Show logout confirmation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('退出登录'),
                          content: const Text('确定要退出登录吗？退出后将返回本地模式。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                auth.logout();
                                Navigator.pop(context);
                                context.go('/login');
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}