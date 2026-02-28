import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('本周完成', '18 个', '进度、柱状/折线图预留'),
      ('平均耗时', '1.2 小时', '后续可接入 ECharts/Charts'),
      ('高优先级', '5 个', '支持筛选与标签'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          final m = metrics[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(m.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4F46E5))),
                const SizedBox(height: 6),
                Text(
                  m.$3,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: metrics.length,
      ),
    );
  }
}