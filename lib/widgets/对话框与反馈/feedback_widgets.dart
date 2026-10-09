import 'package:flutter/material.dart';

// 对话框与反馈：AlertDialog / SnackBar / BottomSheet / Tooltip / ProgressIndicator

/// ===================== AlertDialog =====================
///
/// 【是什么】
/// Material 风格的弹出对话框，用于提示、确认、简单输入。
/// 通过 showDialog 显示，通过 Navigator.pop 关闭并可返回结果。
///
/// 【属性】
/// - title:            标题
/// - content:          内容（过长请包 SingleChildScrollView）
/// - actions:          底部按钮列表（TextButton 等）
/// - icon:             标题上方图标
/// - backgroundColor:  背景色
/// - shape:            形状，如圆角
/// - scrollable:       内容是否整体可滚动
/// showDialog 参数：
/// - barrierDismissible: 点击遮罩是否关闭，默认 true
/// - builder:          构建对话框
/// 其他：SimpleDialog（选项列表）、showDatePicker 等专用对话框
///
/// 【注意】
/// - 关闭对话框用 Navigator.pop(context, 结果)，不是 dismiss
/// - await showDialog 之后使用 context 前检查 mounted
/// - content 里放 ListView 需要限定高度，否则报尺寸错误
/// - 需要在对话框里有状态变化时用 StatefulBuilder
///
/// 【常见使用场景】
/// 1. 删除前的确认
/// 2. 错误 / 成功提示
/// 3. 简单表单输入
/// 4. 单项选择
class AlertDialogDemo extends StatefulWidget {
  const AlertDialogDemo({super.key});

  @override
  State<AlertDialogDemo> createState() => _AlertDialogDemoState();
}

class _AlertDialogDemoState extends State<AlertDialogDemo> {
  String _result = '（无）';

  Future<void> _confirm() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 必须点按钮才能关闭
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除？'),
        content: const Text('删除后无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _result = ok == true ? '已删除' : '已取消');
  }

  Future<void> _input() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('输入昵称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('确定')),
        ],
      ),
    );
    controller.dispose();
    if (!mounted) return;
    setState(() => _result = '输入：${text ?? '无'}');
  }

  Future<void> _simple() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择语言'),
        children: [
          for (final l in ['Dart', 'Kotlin', 'Swift'])
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, l), child: Text(l)),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _result = '选择：${choice ?? '无'}');
  }

  void _styled() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('操作成功'),
        content: const Text('图标、圆角、背景色都可以自定义。'),
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('好的'))],
      ),
    );
  }

  Future<void> _stateful() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        var checked = false;
        return StatefulBuilder(
          builder: (ctx, setInner) => AlertDialog(
            title: const Text('对话框内部状态'),
            content: CheckboxListTile(
              value: checked,
              title: const Text('我已阅读'),
              onChanged: (v) => setInner(() => checked = v ?? false),
            ),
            actions: [TextButton(onPressed: checked ? () => Navigator.pop(ctx) : null, child: const Text('继续'))],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：确认对话框（返回 bool）'),
        ElevatedButton(onPressed: _confirm, child: const Text('删除')),
        const SizedBox(height: 12),
        const Text('示例 2：带输入框'),
        ElevatedButton(onPressed: _input, child: const Text('输入昵称')),
        const SizedBox(height: 12),
        const Text('示例 3：SimpleDialog 单选'),
        ElevatedButton(onPressed: _simple, child: const Text('选择语言')),
        const SizedBox(height: 12),
        const Text('示例 4：icon + 圆角 + 背景色'),
        ElevatedButton(onPressed: _styled, child: const Text('自定义样式')),
        const SizedBox(height: 12),
        const Text('示例 5：StatefulBuilder 让对话框内部可刷新'),
        ElevatedButton(onPressed: _stateful, child: const Text('阅读协议')),
        const SizedBox(height: 12),
        Text('结果：$_result'),
      ],
    );
  }
}

/// ===================== SnackBar =====================
///
/// 【是什么】
/// 屏幕底部短暂出现的轻量提示条，通过
/// ScaffoldMessenger.of(context).showSnackBar 显示。
///
/// 【属性】
/// - content:          内容（通常 Text）
/// - duration:         显示时长，默认 4 秒
/// - action:           SnackBarAction（label、onPressed），如"撤销"
/// - backgroundColor:  背景色
/// - behavior:         fixed（贴底）/ floating（悬浮，可配合 margin）
/// - margin / padding / shape / width: 外观，margin、width 需 floating
/// - showCloseIcon:    是否显示关闭图标
/// - elevation:        阴影
///
/// 【注意】
/// - 需要 Scaffold 祖先；新的 SnackBar 会排队，可先 hideCurrentSnackBar
/// - margin 与 width 不能同时设置，且仅 floating 有效
/// - 需要用户必须响应的信息请用 AlertDialog
///
/// 【常见使用场景】
/// 1. 操作成功 / 失败的轻提示
/// 2. 带"撤销"的删除提示
/// 3. 网络异常提示
class SnackBarDemo extends StatelessWidget {
  const SnackBarDemo({super.key});

  void _show(BuildContext context, SnackBar bar) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(bar);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：最简单'),
        ElevatedButton(
          onPressed: () => _show(context, const SnackBar(content: Text('保存成功'))),
          child: const Text('基础'),
        ),
        const SizedBox(height: 12),
        const Text('示例 2：带 action（撤销）'),
        ElevatedButton(
          onPressed: () => _show(
            context,
            SnackBar(
              content: const Text('已删除 1 项'),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () => _show(context, const SnackBar(content: Text('已撤销'))),
              ),
            ),
          ),
          child: const Text('带撤销'),
        ),
        const SizedBox(height: 12),
        const Text('示例 3：floating + 圆角 + 背景色 + 关闭图标'),
        ElevatedButton(
          onPressed: () => _show(
            context,
            SnackBar(
              content: const Text('出错了，请重试'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              showCloseIcon: true,
            ),
          ),
          child: const Text('悬浮样式'),
        ),
        const SizedBox(height: 12),
        const Text('示例 4：自定义时长与富内容'),
        ElevatedButton(
          onPressed: () => _show(
            context,
            const SnackBar(
              duration: Duration(seconds: 1),
              content: Row(
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text('1 秒后消失'),
                ],
              ),
            ),
          ),
          child: const Text('1 秒提示'),
        ),
      ],
    );
  }
}

/// ===================== BottomSheet =====================
///
/// 【是什么】
/// 从屏幕底部弹出的面板。showModalBottomSheet 为模态（有遮罩，
/// 点击外部关闭）；showBottomSheet 为非模态（常驻，可与页面交互）。
///
/// 【属性】
/// - builder:             构建内容
/// - isScrollControlled:  true 时高度可超过半屏（含键盘场景、全屏面板）
/// - showDragHandle:      是否显示顶部拖动条
/// - backgroundColor / shape / elevation: 外观，如顶部圆角
/// - isDismissible / enableDrag: 是否可点击遮罩 / 拖动关闭
/// - useSafeArea:         避开状态栏等安全区
/// - constraints:         尺寸约束
/// - DraggableScrollableSheet: 可拖动改变高度的面板
///
/// 【注意】
/// - 内容用 mainAxisSize: MainAxisSize.min 的 Column 以包裹高度
/// - 面板里有输入框时设 isScrollControlled 并加 viewInsets.bottom 的 padding
/// - 用 Navigator.pop(context, 值) 关闭并返回结果
///
/// 【常见使用场景】
/// 1. 分享 / 操作菜单
/// 2. 筛选、排序选项
/// 3. 底部评论输入
/// 4. 选择器
class BottomSheetDemo extends StatefulWidget {
  const BottomSheetDemo({super.key});

  @override
  State<BottomSheetDemo> createState() => _BottomSheetDemoState();
}

class _BottomSheetDemoState extends State<BottomSheetDemo> {
  String _picked = '（无）';

  void _basic() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.share), title: const Text('分享'), onTap: () => Navigator.pop(ctx)),
            ListTile(leading: const Icon(Icons.link), title: const Text('复制链接'), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  Future<void> _result() async {
    final v = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in ['按时间', '按热度', '按价格']) ListTile(title: Text(s), onTap: () => Navigator.pop(ctx, s)),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _picked = v ?? '（取消）');
  }

  void _input() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // 允许跟随键盘上移
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [TextField(autofocus: true, decoration: InputDecoration(labelText: '写评论'))],
        ),
      ),
    );
  }

  void _draggable() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: 30,
          itemBuilder: (_, i) => ListTile(title: Text('可拖动面板 第 $i 项')),
        ),
      ),
    );
  }

  void _persistent() {
    showBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 120,
        width: double.infinity,
        color: Colors.indigo.shade50,
        alignment: Alignment.center,
        child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭非模态面板')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：基础模态面板 + 拖动条'),
        ElevatedButton(onPressed: _basic, child: const Text('操作菜单')),
        const SizedBox(height: 12),
        const Text('示例 2：圆角 + 返回选择结果'),
        ElevatedButton(onPressed: _result, child: const Text('排序方式')),
        Text('选择：$_picked'),
        const SizedBox(height: 12),
        const Text('示例 3：isScrollControlled + 键盘适配'),
        ElevatedButton(onPressed: _input, child: const Text('写评论')),
        const SizedBox(height: 12),
        const Text('示例 4：DraggableScrollableSheet 可拖动高度'),
        ElevatedButton(onPressed: _draggable, child: const Text('可拖动')),
        const SizedBox(height: 12),
        const Text('示例 5：showBottomSheet 非模态（需要 Scaffold）'),
        ElevatedButton(onPressed: _persistent, child: const Text('非模态')),
      ],
    );
  }
}

/// ===================== Tooltip =====================
///
/// 【是什么】
/// 长按（桌面端悬停）时显示的文字提示，用来解释图标按钮等控件。
///
/// 【属性】
/// - message:          提示文字（与 richMessage 二选一）
/// - richMessage:      富文本提示（InlineSpan）
/// - child:            被包裹的组件
/// - waitDuration:     悬停多久后显示
/// - showDuration:     显示多久后消失
/// - triggerMode:      触发方式：longPress / tap / manual
/// - preferBelow:      优先显示在下方
/// - verticalOffset:   与 child 的垂直距离
/// - decoration / textStyle / padding / margin: 外观
/// - IconButton.tooltip: 按钮自带的快捷写法
///
/// 【注意】
/// - 移动端默认需要长按；想点击即显示用 triggerMode: tap
/// - 提示应简短；无障碍读屏也会读取 message
///
/// 【常见使用场景】
/// 1. 图标按钮的说明
/// 2. 被截断文字的完整内容
/// 3. 桌面 / Web 的悬停提示
class TooltipDemo extends StatelessWidget {
  const TooltipDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：基础（长按 / 悬停）'),
        const Tooltip(
          message: '这是提示文字',
          child: Padding(padding: EdgeInsets.all(12), child: Icon(Icons.info, size: 32)),
        ),
        const Text('示例 2：IconButton 自带 tooltip'),
        IconButton(tooltip: '删除', icon: const Icon(Icons.delete), onPressed: () {}),
        const Text('示例 3：点击触发 + 自定义样式'),
        Tooltip(
          message: '点我也能显示',
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          showDuration: const Duration(seconds: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(color: Colors.white),
          child: const Chip(label: Text('点击我')),
        ),
        const SizedBox(height: 12),
        const Text('示例 4：富文本提示'),
        Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          richMessage: const TextSpan(
            children: [
              TextSpan(
                text: '重要 ',
                style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '请谨慎操作'),
            ],
          ),
          child: const Icon(Icons.warning, color: Colors.orange, size: 32),
        ),
        const SizedBox(height: 12),
        const Text('示例 5：长文本被截断时显示完整内容'),
        const Tooltip(
          message: '这是一段非常非常长的文字，完整内容通过提示展示出来。',
          triggerMode: TooltipTriggerMode.tap,
          child: Text('这是一段非常非常长的文字，完整内容通过提示展示出来。', maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// ===================== ProgressIndicator =====================
///
/// 【是什么】
/// 进度指示器：CircularProgressIndicator（圆形）与
/// LinearProgressIndicator（线性），表示加载中或具体进度。
///
/// 【属性】
/// - value:               0.0~1.0 的进度；为 null 表示不确定进度（无限动画）
/// - color / valueColor:  进度颜色
/// - backgroundColor:     轨道背景色
/// - strokeWidth:         （圆形）线宽
/// - minHeight:           （线性）高度
/// - borderRadius:        （线性）圆角
/// - semanticsLabel / semanticsValue: 无障碍描述
/// - CircularProgressIndicator.adaptive: 随平台切换 iOS 风格
/// - RefreshProgressIndicator: 下拉刷新样式
///
/// 【注意】
/// - 圆形默认尺寸 36，改大小用 SizedBox 包裹（而非 Container 的 width）
/// - 线性指示器宽度撑满父级，放 Row 里需要 Expanded
/// - 无限动画的指示器在页面不可见时仍可能耗电，不用时及时移除
///
/// 【常见使用场景】
/// 1. 页面 / 列表加载中
/// 2. 文件上传下载进度
/// 3. 按钮提交时的小转圈
class ProgressIndicatorDemo extends StatefulWidget {
  const ProgressIndicatorDemo({super.key});

  @override
  State<ProgressIndicatorDemo> createState() => _ProgressIndicatorDemoState();
}

class _ProgressIndicatorDemoState extends State<ProgressIndicatorDemo> {
  double _value = 0.3;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：不确定进度（value 为 null）'),
        const SizedBox(height: 8),
        const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Expanded(child: LinearProgressIndicator()),
          ],
        ),
        const SizedBox(height: 20),
        Text('示例 2：确定进度 ${(_value * 100).round()}%（拖动滑块）'),
        const SizedBox(height: 8),
        Row(
          children: [
            CircularProgressIndicator(value: _value),
            const SizedBox(width: 24),
            Expanded(child: LinearProgressIndicator(value: _value)),
          ],
        ),
        Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
        const SizedBox(height: 12),
        const Text('示例 3：自定义颜色、粗细、圆角'),
        const SizedBox(height: 8),
        const Row(
          children: [
            CircularProgressIndicator(color: Colors.red, backgroundColor: Colors.black12, strokeWidth: 8, value: 0.6),
            SizedBox(width: 24),
            Expanded(
              child: LinearProgressIndicator(
                value: 0.6,
                minHeight: 12,
                color: Colors.green,
                backgroundColor: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('示例 4：用 SizedBox 改变圆形大小'),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 6)),
        ),
        const SizedBox(height: 20),
        const Text('示例 5：按钮内的加载状态'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            label: Text(_loading ? '提交中...' : '提交'),
          ),
        ),
      ],
    );
  }
}
