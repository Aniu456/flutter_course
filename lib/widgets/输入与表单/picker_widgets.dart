import 'package:flutter/material.dart';

// 日期与时间选择：showDatePicker / showTimePicker / showDateRangePicker。

/// ===================== 日期 / 时间选择器 =====================
///
/// 【是什么】
/// Material 风格的弹窗选择器，返回 Future，用户取消时结果为 null。
///
/// 【常用 API】
/// - showDatePicker(context, initialDate, firstDate, lastDate) → `Future<DateTime?>`
/// - showTimePicker(context, initialTime) → `Future<TimeOfDay?>`
/// - showDateRangePicker(context, firstDate, lastDate) → `Future<DateTimeRange?>`
///
/// 【常用参数】
/// - initialEntryMode: DatePickerEntryMode.calendar / input（直接输入）
/// - selectableDayPredicate: 哪些日期可选（如禁用周末）
/// - helpText / cancelText / confirmText: 自定义文案
/// - locale: 指定语言（需配置 flutter_localizations，见「工程化 / 国际化」）
/// - builder: 包一层 Theme 自定义颜色，或 MediaQuery 强制 24 小时制
///
/// 【注意】
/// - 弹窗是异步的：await 之后先判断 mounted 再 setState
/// - 中文界面需要在 MaterialApp 中配置 localizationsDelegates
/// - iOS 风格请用 CupertinoDatePicker（见「Cupertino」分类）
///
/// 【常见使用场景】
/// 生日、预约时间、酒店入住 / 离店日期、筛选时间范围
class DateTimePickerDemo extends StatefulWidget {
  const DateTimePickerDemo({super.key});

  @override
  State<DateTimePickerDemo> createState() => _DateTimePickerDemoState();
}

class _DateTimePickerDemoState extends State<DateTimePickerDemo> {
  DateTime? _date;
  TimeOfDay? _time;
  DateTimeRange? _range;
  DateTime? _weekday;

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 10),
      helpText: '选择日期',
    );
    if (result != null && mounted) setState(() => _date = result);
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: '选择时间',
      // 强制使用 24 小时制
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (result != null && mounted) setState(() => _time = result);
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: '选择入住和离店日期',
    );
    if (result != null && mounted) setState(() => _range = result);
  }

  Future<void> _pickWeekday() async {
    final now = DateTime.now();
    var initial = now;
    while (initial.weekday > DateTime.friday) {
      initial = initial.add(const Duration(days: 1));
    }
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 90)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: '只能选工作日',
      selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
    );
    if (result != null && mounted) setState(() => _weekday = result);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('showDatePicker'),
          subtitle: Text(_date == null ? '未选择' : _fmt(_date!)),
          trailing: FilledButton.tonal(onPressed: _pickDate, child: const Text('选择')),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('showTimePicker（24 小时制）'),
          subtitle: Text(_time == null ? '未选择' : _time!.format(context)),
          trailing: FilledButton.tonal(onPressed: _pickTime, child: const Text('选择')),
        ),
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text('showDateRangePicker'),
          subtitle: Text(
            _range == null ? '未选择' : '${_fmt(_range!.start)} → ${_fmt(_range!.end)}（${_range!.duration.inDays} 晚）',
          ),
          trailing: FilledButton.tonal(onPressed: _pickRange, child: const Text('选择')),
        ),
        ListTile(
          leading: const Icon(Icons.work_outline),
          title: const Text('selectableDayPredicate：禁用周末'),
          subtitle: Text(_weekday == null ? '未选择' : _fmt(_weekday!)),
          trailing: FilledButton.tonal(onPressed: _pickWeekday, child: const Text('选择')),
        ),
      ],
    );
  }
}
