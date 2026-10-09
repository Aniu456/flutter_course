import 'package:flutter/material.dart';

// 生命周期与 Key：State 生命周期、App 生命周期（AppLifecycleListener）、
// Key 对列表重排的影响、GlobalKey 跨父组件保留状态。
//
// Key 速查：
// | Key            | 判断相同的依据             | 典型用途                         |
// |----------------|----------------------------|----------------------------------|
// | 不写 Key       | 类型 + 位置                | 大多数静态布局                   |
// | ValueKey(v)    | v 的 == 相等               | 列表项用数据 id 作 Key           |
// | ObjectKey(o)   | o 是同一个对象（identical） | 没有唯一 id、但对象唯一时         |
// | UniqueKey()    | 永不相同                   | 强制重建、AnimatedSwitcher 刷新   |
// | GlobalKey      | 全局唯一                   | 跨父组件保留状态、访问 State/Form |
// | PageStorageKey | 同 ValueKey + 保存滚动位置  | Tab 切换后保留列表滚动位置        |

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// 生命周期日志：生命周期方法常在 build 阶段被调用，
/// 那时不能直接 setState，所以先记下来，等这一帧结束后再统一刷新日志面板。
class _LifecycleLog {
  final List<String> lines = [];
  final ValueNotifier<int> version = ValueNotifier(0);
  bool _scheduled = false;
  bool _disposed = false;

  void add(String line) {
    debugPrint('[Lifecycle] $line');
    lines.insert(0, line);
    if (_scheduled || _disposed) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!_disposed) version.value++;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void clear() {
    lines.clear();
    version.value++;
  }

  void dispose() {
    _disposed = true;
    version.dispose();
  }
}

/// 用于演示 didChangeDependencies 的 InheritedWidget。
class _DemoInherited extends InheritedWidget {
  const _DemoInherited({required this.color, required super.child});

  final Color color;

  static Color of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_DemoInherited>()!.color;

  @override
  bool updateShouldNotify(_DemoInherited oldWidget) => color != oldWidget.color;
}

/// ===================== State 生命周期 =====================
///
/// 【是什么】
/// StatefulWidget 的 State 从创建到销毁会依次经过这些回调：
///
///   createState → initState → didChangeDependencies → build
///        ↓ 父组件重建、传入新配置
///   didUpdateWidget → build
///        ↓ 依赖的 InheritedWidget（Theme、MediaQuery……）变化
///   didChangeDependencies → build
///        ↓ 自身 setState
///   build
///        ↓ 从树上移除
///   deactivate → dispose
///
/// 【各方法用途】
/// - initState：只调用一次。初始化 Controller、订阅、发起首次请求（不能用 context 读 InheritedWidget）
/// - didChangeDependencies：initState 之后立刻调用一次；之后依赖变化时再调用
/// - didUpdateWidget(oldWidget)：父组件用新参数重建了我；对比 oldWidget 决定是否重新请求
/// - build：可能被频繁调用，只做"描述 UI"，不要发请求、不要做耗时计算
/// - deactivate：从树上移除时调用（GlobalKey 重新插入时可能会再激活）
/// - dispose：永久销毁，释放 Controller、取消订阅、关闭流
/// - reassemble：热重载时调用（仅 debug）
///
/// 【注意】
/// - dispose 之后不能再 setState；异步回调里先判断 mounted
/// - 打开控制台可以看到同样的 [Lifecycle] 日志
class StateLifecycleDemo extends StatefulWidget {
  const StateLifecycleDemo({super.key});

  @override
  State<StateLifecycleDemo> createState() => _StateLifecycleDemoState();
}

class _StateLifecycleDemoState extends State<StateLifecycleDemo> {
  final _LifecycleLog _log = _LifecycleLog();
  int _param = 1;
  bool _show = true;
  bool _red = false;

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: () => setState(() => _param++), child: const Text('修改传入参数')),
              FilledButton.tonal(onPressed: () => setState(() {}), child: const Text('父组件 setState')),
              FilledButton.tonal(onPressed: () => setState(() => _red = !_red), child: const Text('修改 Inherited 数据')),
              OutlinedButton(onPressed: () => setState(() => _show = !_show), child: Text(_show ? '移除子组件' : '插入子组件')),
              TextButton(onPressed: _log.clear, child: const Text('清空日志')),
            ],
          ),
        ),
        _DemoInherited(
          color: _red ? Colors.red : Colors.blue,
          child: SizedBox(
            height: 110,
            child: _show ? _LifecycleChild(param: _param, log: _log) : const Center(child: Text('（子组件已移除）')),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: _log.version,
            builder: (_, _, _) => ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text('日志（最新在上）：', style: TextStyle(fontWeight: FontWeight.bold)),
                for (final line in _log.lines)
                  Text(line, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LifecycleChild extends StatefulWidget {
  const _LifecycleChild({required this.param, required this.log});

  final int param;
  final _LifecycleLog log;

  @override
  State<_LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<_LifecycleChild> {
  int _inner = 0;

  _LifecycleLog get _log => widget.log;

  @override
  void initState() {
    super.initState();
    _log.add('createState() → initState()');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _log.add('didChangeDependencies()');
  }

  @override
  void didUpdateWidget(covariant _LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log.add('didUpdateWidget(param: ${oldWidget.param} → ${widget.param})');
  }

  @override
  void reassemble() {
    super.reassemble();
    _log.add('reassemble()  // 热重载');
  }

  @override
  void deactivate() {
    _log.add('deactivate()');
    super.deactivate();
  }

  @override
  void dispose() {
    _log.add('dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log.add('build()');
    final color = _DemoInherited.of(context);
    return Card(
      color: color.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.widgets, color: color),
        title: Text('子组件：param = ${widget.param}'),
        subtitle: Text('内部状态 _inner = $_inner'),
        trailing: TextButton(onPressed: () => setState(() => _inner++), child: const Text('自身 setState')),
      ),
    );
  }
}

/// ===================== AppLifecycleListener =====================
///
/// 【是什么】
/// 监听整个 App 的前后台状态（Flutter 3.13+ 推荐写法，
/// 替代旧的 WidgetsBindingObserver.didChangeAppLifecycleState）。
///
/// 【状态（AppLifecycleState）】
/// - resumed：前台可见且可交互
/// - inactive：可见但失去焦点（来电、下拉通知栏、App 切换器）
/// - hidden：不可见（各平台进入后台前的过渡状态）
/// - paused：在后台，不可见
/// - detached：引擎还在，但没有任何视图（如即将退出）
///
/// 【常用回调】
/// onStateChange / onResume / onInactive / onHide / onShow / onPause / onRestart / onDetach，
/// 桌面端还有 onExitRequested（可以拦截退出）
///
/// 【注意】
/// - 在 initState 创建，在 dispose 里调用 listener.dispose()
/// - 试一试：把 App 切到后台再回来，观察日志
///
/// 【常见使用场景】
/// 回到前台时刷新数据 / 校验登录、进入后台时暂停视频 / 保存草稿
class AppLifecycleDemo extends StatefulWidget {
  const AppLifecycleDemo({super.key});

  @override
  State<AppLifecycleDemo> createState() => _AppLifecycleDemoState();
}

class _AppLifecycleDemoState extends State<AppLifecycleDemo> {
  late final AppLifecycleListener _listener;
  final List<String> _logs = [];
  AppLifecycleState? _state = WidgetsBinding.instance.lifecycleState;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: (s) => setState(() => _state = s),
      onShow: () => _add('onShow：App 重新可见'),
      onResume: () => _add('onResume：回到前台，可交互'),
      onInactive: () => _add('onInactive：失去焦点'),
      onHide: () => _add('onHide：不可见'),
      onPause: () => _add('onPause：进入后台'),
      onRestart: () => _add('onRestart：从后台恢复'),
      onDetach: () => _add('onDetach：视图已分离'),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _add(String text) {
    final now = TimeOfDay.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() => _logs.insert(0, '$time  $text'));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ListTile(
          leading: const Icon(Icons.phone_android),
          title: Text('当前状态：${_state?.name ?? '未知'}'),
          subtitle: const Text('把 App 切到后台再切回来，下面会出现回调日志'),
        ),
        const Divider(),
        _title('回调日志'),
        if (_logs.isEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('（暂无）')),
        for (final log in _logs) ListTile(dense: true, title: Text(log)),
      ],
    );
  }
}

/// 自带内部状态（计数）的小方块，用来观察状态"跟着谁走"。
class _CounterTile extends StatefulWidget {
  const _CounterTile({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  State<_CounterTile> createState() => _CounterTileState();
}

class _CounterTileState extends State<_CounterTile> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _count++),
      child: Container(
        width: 110,
        height: 70,
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(8)),
        child: Text(
          '${widget.label}\n内部计数 $_count',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// ===================== Key 与列表重排 =====================
///
/// 【是什么】
/// Flutter 更新时，会拿新 Widget 和旧 Element 做匹配：
/// "类型相同 且 Key 相同" 就复用旧的 Element 和 State。
/// 不写 Key 时，只能按"位置"匹配。
///
/// 【现象】
/// - 不写 Key：交换顺序后，标签（来自 Widget）换了，但内部计数（在 State 里）留在原位 → 错乱
/// - 写 ValueKey：State 跟着 Key 走，标签和计数一起交换 → 正确
///
/// 【注意】
/// - 有状态的列表项（输入框、勾选、动画）在增删 / 排序时一定要加 Key
/// - Key 用数据的唯一 id，不要用 index（index 会变，等于没加）
/// - Key 只在"同一个父组件的子组件之间"比较
///
/// 【常见使用场景】
/// 可排序列表、可删除列表、ReorderableListView（强制要求 Key）、AnimatedSwitcher
class KeyReorderDemo extends StatefulWidget {
  const KeyReorderDemo({super.key});

  @override
  State<KeyReorderDemo> createState() => _KeyReorderDemoState();
}

class _KeyReorderDemoState extends State<KeyReorderDemo> {
  List<(String, Color)> _tiles = [('A', Colors.teal), ('B', Colors.deepOrange)];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('先分别点几下方块让"内部计数"不同，再点"交换顺序"。')),
        _title('1. 不写 Key：颜色和标签交换了，计数却留在原位'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [for (final (label, color) in _tiles) _CounterTile(label: label, color: color)],
        ),
        _title('2. ValueKey(label)：状态跟着 Key 一起移动'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final (label, color) in _tiles) _CounterTile(key: ValueKey(label), label: label, color: color),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => setState(() => _tiles = _tiles.reversed.toList()),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('交换顺序'),
          ),
        ),
      ],
    );
  }
}

/// ===================== GlobalKey 跨父组件保留状态 =====================
///
/// 【是什么】
/// 普通 Key 只在同一个父组件下比较；组件被移到"另一个父组件"下时，
/// 旧 State 会被销毁、重新创建。GlobalKey 在整棵树中唯一，
/// 组件换了父组件也能找回原来的 Element 和 State（称为 reparenting）。
///
/// 【其他用途】
/// - key.currentState：拿到 State 调用方法（如 FormState.validate()）
/// - key.currentContext：拿到 context 计算尺寸、位置
///
/// 【注意】
/// - 同一个 GlobalKey 同一时刻只能用在一个组件上，否则报错
/// - GlobalKey 开销较大，不要在列表里给每一项都用
///
/// 【常见使用场景】
/// 布局切换（横竖屏）时保留视频播放器状态、Form 校验、AnimatedList 操作
class GlobalKeyReparentDemo extends StatefulWidget {
  const GlobalKeyReparentDemo({super.key});

  @override
  State<GlobalKeyReparentDemo> createState() => _GlobalKeyReparentDemoState();
}

class _GlobalKeyReparentDemoState extends State<GlobalKeyReparentDemo> {
  final GlobalKey _globalKey = GlobalKey();
  bool _left = true;

  Widget _slot(String name, Widget? child) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(color: Colors.grey)),
            ?child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const plain = _CounterTile(label: '无 GlobalKey', color: Colors.blueGrey);
    final global = _CounterTile(key: _globalKey, label: 'GlobalKey', color: Colors.indigo);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('先点几下两个方块，再点"移动到另一边"：\n没有 GlobalKey 的计数会清零，有 GlobalKey 的会保留。'),
        ),
        _title('1. 不写 Key（换了父组件 → 新建 State）'),
        Row(children: [_slot('左边容器', _left ? plain : null), _slot('右边容器', _left ? null : plain)]),
        _title('2. 使用 GlobalKey（换了父组件 → 保留 State）'),
        Row(children: [_slot('左边容器', _left ? global : null), _slot('右边容器', _left ? null : global)]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => setState(() => _left = !_left),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('移动到另一边'),
          ),
        ),
      ],
    );
  }
}
