import 'package:flutter/material.dart';

enum CalendarView { day, week }

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final bool canceled;
  final Color color;

  CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    this.canceled = false,
    this.color = const Color(0xFFEF4444), // 默认红色
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarView _view = CalendarView.day;
  DateTime _focusDate = DateTime(2026, 3, 7); // 设计稿示例日期
  bool _hideCanceled = false;
  final ScrollController _weekScrollController = ScrollController();

  final List<CalendarEvent> _events = [
    CalendarEvent(
      title: '已取消-天基组周会',
      start: DateTime(2026, 3, 7, 9, 0),
      end: DateTime(2026, 3, 7, 10, 0),
      canceled: true,
      color: const Color(0xFF94A3B8),
    ),
    CalendarEvent(
      title: '小组周会',
      start: DateTime(2026, 3, 7, 18, 0),
      end: DateTime(2026, 3, 7, 19, 0),
      color: const Color(0xFFEF4444),
    ),
    CalendarEvent(
      title: '架构组讨论',
      start: DateTime(2026, 3, 3, 20, 0),
      end: DateTime(2026, 3, 3, 21, 0),
      color: const Color(0xFFEF4444),
    ),
    CalendarEvent(
      title: '攻坚克难',
      start: DateTime(2026, 3, 12, 10, 0),
      end: DateTime(2026, 3, 12, 11, 0),
      color: const Color(0xFFEF4444),
    ),
  ];

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(child: _buildView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dateText = '${_focusDate.year}年${_focusDate.month}月${_focusDate.day}日 周${_weekdayLabel(_focusDate)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevPeriod,
                  splashRadius: 30,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: Text(
                    dateText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextPeriod,
                  splashRadius: 30,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              _buildViewSwitcher(),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher() {
    final labels = ['日', '周'];
    final selectedIndex = _view.index;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: ToggleButtons(
        isSelected: List.generate(labels.length, (i) => i == selectedIndex),
        onPressed: (i) {
          setState(() => _view = CalendarView.values[i]);
        },
        borderRadius: BorderRadius.circular(10),
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        fillColor: Colors.white,
        selectedColor: const Color(0xFFEF4444),
        color: const Color(0xFF94A3B8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
        children: List.generate(labels.length, (i) {
          return Text(
            labels[i],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: i == selectedIndex ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildView() {
    switch (_view) {
      case CalendarView.day:
        return _buildDayView();
      case CalendarView.week:
        return _buildWeekView();
    }
  }

  List<CalendarEvent> _eventsForDay(DateTime day) {
    return _events.where((e) {
      if (_hideCanceled && e.canceled) return false;
      return e.start.year == day.year && e.start.month == day.month && e.start.day == day.day;
    }).toList();
  }

  Widget _buildDayView() {
    const double hourHeight = 64;
    final events = _eventsForDay(_focusDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: hourHeight * 24,
        child: Stack(
          children: [
            Column(
              children: List.generate(24, (i) {
                return SizedBox(
                  height: hourHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          i.toString().padLeft(2, '0') + ':00',
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Expanded(
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                    ],
                  ),
                );
              }),
            ),
            ...events.map((e) {
              final minutesFromStart = (e.start.hour * 60 + e.start.minute).toDouble();
              final durationMinutes = e.end.difference(e.start).inMinutes.toDouble().clamp(60, 240);
              final top = minutesFromStart / 60 * hourHeight;
              final height = durationMinutes / 60 * hourHeight;

              return Positioned(
                top: top,
                left: 72,
                right: 16,
                child: Container(
                  height: height,
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: e.canceled ? const Color(0xFFF1F5F9) : e.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: e.canceled ? const Color(0xFFE5E7EB) : e.color.withOpacity(0.5),
                      width: e.canceled ? 0.8 : 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        margin: const EdgeInsets.only(right: 8, top: 2),
                        decoration: BoxDecoration(
                          color: e.canceled ? const Color(0xFFCBD5E1) : e.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 1.1,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: e.canceled ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              _timeRange(e),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 1.1,
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _focusDate.subtract(Duration(days: _focusDate.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 56, child: Text('UTC+8', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) {
                    final selected = d.day == _focusDate.day && d.month == _focusDate.month && d.year == _focusDate.year;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _focusDate = DateTime(d.year, d.month, d.day);
                        });
                      },
                      child: Column(
                        children: [
                          Text('周${_weekdayLabel(d)}', style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFFEE2E2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: selected ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              d.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: Stack(
            children: [
              // 网格
              SingleChildScrollView(
                controller: _weekScrollController,
                child: Column(
                  children: List.generate(13, (row) {
                    return SizedBox(
                      height: 72,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            child: Text(
                              '${(row + 9).toString().padLeft(2, '0')}:00',
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Expanded(
                            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              // 事件（与网格共享同一滚动控制器，保持时间轴同步）
              SingleChildScrollView(
                controller: _weekScrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 72 * 13,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hourHeight = constraints.maxHeight / 13; // 9-21
                          final dayWidth = (constraints.maxWidth - 0) / 7;
                          return Stack(
                            children: _events
                                .where((e) {
                                  if (_hideCanceled && e.canceled) return false;
                                  return e.start.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                                      e.start.isBefore(startOfWeek.add(const Duration(days: 7)));
                                })
                                .map((e) {
                                  final dayIndex = e.start.difference(startOfWeek).inDays;
                                  final startMinutes = (e.start.hour - 9) * 60 + e.start.minute;
                                  final durationMinutes = e.end.difference(e.start).inMinutes.toDouble().clamp(30, 240);
                                  final top = (startMinutes / 60) * hourHeight;
                                  final height = (durationMinutes / 60) * hourHeight;
                                  return Positioned(
                                    left: 56 + dayWidth * dayIndex + 8,
                                    top: top + 4,
                                    width: dayWidth - 16,
                                    height: height,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: e.canceled ? const Color(0xFFF1F5F9) : e.color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: e.canceled ? const Color(0xFFE5E7EB) : e.color,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        e.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: e.canceled ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final firstDay = DateTime(_focusDate.year, _focusDate.month, 1);
    final daysInMonth = DateTime(_focusDate.year, _focusDate.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=周日
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              SizedBox(width: 56, child: Text('UTC+8', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
              Spacer(),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: const [
              _WeekdayHeader('日'),
              _WeekdayHeader('一'),
              _WeekdayHeader('二'),
              _WeekdayHeader('三'),
              _WeekdayHeader('四'),
              _WeekdayHeader('五'),
              _WeekdayHeader('六'),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75, // 更高的单元格，减少溢出
            ),
            itemCount: rows * 7,
            itemBuilder: (context, index) {
              final dayNumber = index - startWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = DateTime(_focusDate.year, _focusDate.month, dayNumber);
              final dayEvents = _eventsForDay(day);
              final isToday = _isSameDay(day, DateTime.now());
              final isFocus = _isSameDay(day, _focusDate);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isFocus ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB)),
                  boxShadow: const [BoxShadow(color: Color(0x0CCBD5E1), blurRadius: 6, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFEF4444) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                          color: isToday ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...dayEvents.take(3).map((e) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: e.canceled ? const Color(0xFFF8FAFC) : e.color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: e.canceled ? const Color(0xFFE5E7EB) : e.color, width: 0.8),
                        ),
                        child: Text(
                          e.title.length > 6 ? '${e.title.substring(0, 5)}...' : e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.0,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: e.canceled ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _goToday() {
    setState(() {
      final now = DateTime.now();
      _focusDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _prevPeriod() {
    setState(() {
      if (_view == CalendarView.day) {
        _focusDate = _focusDate.subtract(const Duration(days: 1));
      } else {
        _focusDate = _focusDate.subtract(const Duration(days: 7));
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_view == CalendarView.day) {
        _focusDate = _focusDate.add(const Duration(days: 1));
      } else {
        _focusDate = _focusDate.add(const Duration(days: 7));
      }
    });
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['日', '一', '二', '三', '四', '五', '六'];
    return labels[date.weekday % 7];
  }

  String _timeRange(CalendarEvent e) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(e.start.hour)}:${two(e.start.minute)} - ${two(e.end.hour)}:${two(e.end.minute)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String label;
  const _WeekdayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}