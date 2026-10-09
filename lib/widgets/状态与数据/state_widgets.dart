import 'dart:async';

import 'package:flutter/material.dart';

// 状态与数据：StatefulWidget、InheritedWidget 以及各种 Builder。

/// 示例标题小组件：给每个示例加一个带说明的标题。
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

/// ===================== StatefulWidget =====================
///
/// 【是什么】
/// StatefulWidget 是"有状态组件"：界面会随数据变化而重建。
/// Widget 本身不可变，可变的数据放在对应的 State 对象里，
/// 数据变化后调用 setState() 通知框架重新执行 build()。
///
/// 【属性 / 生命周期方法】（都写在 State 类里）
/// - createState():     创建 State，只调用一次
/// - initState():       State 创建后调用一次，用来初始化数据、创建
///                      Controller、订阅 Stream；先调用 super.initState()
/// - didChangeDependencies(): 依赖的 InheritedWidget（如 Theme）变化时调用，
///                      initState 之后也会调用一次
/// - build():           构建界面，会被多次调用，里面不要做耗时操作
/// - didUpdateWidget(old): 父组件用新配置重建本组件时调用，
///                      可对比 oldWidget 与 widget 的差异
/// - setState(fn):      在 fn 中修改状态，然后标记需要重建
/// - deactivate():      从树中移除时调用
/// - dispose():         永久销毁时调用一次，释放 Controller / 取消订阅，
///                      先做自己的清理，最后调用 super.dispose()
/// - widget:            State 中通过 widget 访问当前配置（构造参数）
/// - mounted:           State 是否还在树中，异步回调里 setState 前要检查
///
/// 【注意】
/// - 只修改变量不调用 setState，界面不会刷新
/// - setState 的回调必须是同步的，不要写 async
/// - 异步操作完成后，先判断 if (!mounted) return; 再 setState
/// - 状态太多或需要跨组件共享时，考虑提升状态、InheritedWidget 或状态管理库
/// - 不依赖任何可变数据的界面用 StatelessWidget 即可
///
/// 【常见使用场景】
/// 1. 计数器、开关、复选框、表单输入
/// 2. 动画（配合 AnimationController）
/// 3. 需要在 initState 请求数据、在 dispose 释放资源的页面
/// 4. 展开/收起、Tab 选中等界面本地状态
class StatefulWidgetDemo extends StatelessWidget {
  const StatefulWidgetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('示例 1：计数器（setState 刷新界面）'),
          Center(child: _CounterBox()),
          _Label(
            '示例 2：生命周期日志（点击按钮切换 title 触发 didUpdateWidget，'
            '切换显示触发 dispose）',
          ),
          _LifecycleParent(),
          _Label('示例 3：开关与多个状态变量'),
          _SwitchBox(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CounterBox extends StatefulWidget {
  const _CounterBox();

  @override
  State<_CounterBox> createState() => _CounterBoxState();
}

class _CounterBoxState extends State<_CounterBox> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: () => setState(() => _count--), icon: const Icon(Icons.remove_circle_outline)),
        Text('$_count', style: const TextStyle(fontSize: 28)),
        IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}

class _LifecycleParent extends StatefulWidget {
  const _LifecycleParent();

  @override
  State<_LifecycleParent> createState() => _LifecycleParentState();
}

class _LifecycleParentState extends State<_LifecycleParent> {
  bool _show = true;
  int _version = 1;
  final List<String> _logs = [];

  void _log(String msg) {
    // 子组件在构建/销毁阶段调用，延后到帧结束后再刷新，避免 build 期间 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _logs.insert(0, msg));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: () => setState(() => _version++), child: const Text('更新 title')),
              ElevatedButton(onPressed: () => setState(() => _show = !_show), child: Text(_show ? '移除子组件' : '显示子组件')),
            ],
          ),
          if (_show) _LifecycleChild(title: 'v$_version', onLog: _log),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: ListView(children: [for (final l in _logs) Text(l)]),
          ),
        ],
      ),
    );
  }
}

class _LifecycleChild extends StatefulWidget {
  const _LifecycleChild({required this.title, required this.onLog});
  final String title;
  final void Function(String) onLog;

  @override
  State<_LifecycleChild> createState() => _LifecycleChildState();
}

class _LifecycleChildState extends State<_LifecycleChild> {
  @override
  void initState() {
    super.initState();
    widget.onLog('initState: ${widget.title}');
  }

  @override
  void didUpdateWidget(covariant _LifecycleChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.onLog('didUpdateWidget: ${oldWidget.title} -> ${widget.title}');
  }

  @override
  void dispose() {
    // 此时 State 已销毁，只能用保存的回调；日志用于演示
    final log = widget.onLog;
    log('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(8), child: Text('子组件 ${widget.title}'));
}

class _SwitchBox extends StatefulWidget {
  const _SwitchBox();

  @override
  State<_SwitchBox> createState() => _SwitchBoxState();
}

class _SwitchBoxState extends State<_SwitchBox> {
  bool _on = false;
  double _size = 40;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(title: Text(_on ? '已开启' : '已关闭'), value: _on, onChanged: (v) => setState(() => _on = v)),
        Slider(min: 20, max: 100, value: _size, onChanged: (v) => setState(() => _size = v)),
        Icon(Icons.lightbulb, size: _size, color: _on ? Colors.amber : Colors.grey),
      ],
    );
  }
}

/// ===================== InheritedWidget =====================
///
/// 【是什么】
/// InheritedWidget 能让子树中任意深度的组件直接读取上层共享的数据，
/// 不必一层层通过构造参数传递。Theme、MediaQuery 就是用它实现的。
/// 数据变化时，依赖它的子组件会自动重建。
///
/// 【属性 / 方法】
/// - child:                 子树
/// - updateShouldNotify(old): 数据变化后是否通知依赖者重建，
///                          通常比较新旧数据是否不同
/// - of(context) 约定写法:  内部调用
///                          context.`dependOnInheritedWidgetOfExactType<T>()`
///                          获取数据并注册依赖
/// - `getInheritedWidgetOfExactType<T>()`: 只读取、不注册依赖（不会随之重建）
///
/// 【注意】
/// - InheritedWidget 自身不可变，要"变化"需要在上层的 StatefulWidget
///   中 setState 后用新数据重建它
/// - 通常会再包一层 StatefulWidget 持有真实状态
/// - 在 initState 中不能用 dependOnInheritedWidgetOfExactType，
///   应放在 didChangeDependencies 或 build
/// - 复杂场景可直接使用 Provider、Riverpod（它们基于 InheritedWidget）
///
/// 【常见使用场景】
/// 1. 共享主题、语言、用户信息、配置
/// 2. 跨多层组件共享状态，避免"参数逐层传递"
/// 3. 自己封装简易状态管理
class InheritedWidgetDemo extends StatefulWidget {
  const InheritedWidgetDemo({super.key});

  @override
  State<InheritedWidgetDemo> createState() => _InheritedWidgetDemoState();
}

class _InheritedWidgetDemoState extends State<InheritedWidgetDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return CounterScope(
      count: _count,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('示例：上层持有 count，深层子组件直接读取（无需传参）'),
            Center(
              child: ElevatedButton(onPressed: () => setState(() => _count++), child: const Text('上层 count +1')),
            ),
            const SizedBox(height: 12),
            const Center(child: _DeepLevel1()),
          ],
        ),
      ),
    );
  }
}

/// 自定义 InheritedWidget：共享一个计数值。
class CounterScope extends InheritedWidget {
  const CounterScope({super.key, required this.count, required super.child});
  final int count;

  static CounterScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CounterScope>();
    assert(scope != null, '上层没有 CounterScope');
    return scope!;
  }

  @override
  bool updateShouldNotify(CounterScope oldWidget) => count != oldWidget.count;
}

class _DeepLevel1 extends StatelessWidget {
  const _DeepLevel1();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(12),
    child: Card(
      child: Padding(padding: EdgeInsets.all(12), child: _DeepLevel2()),
    ),
  );
}

class _DeepLevel2 extends StatelessWidget {
  const _DeepLevel2();

  @override
  Widget build(BuildContext context) {
    // 这里读取并注册依赖，count 变化时本组件会自动重建
    final count = CounterScope.of(context).count;
    return Text('我在很深的层级，读到 count = $count', style: const TextStyle(fontSize: 16));
  }
}

/// ===================== FutureBuilder =====================
///
/// 【是什么】
/// 根据一个 Future 的状态（等待中 / 完成 / 出错）自动构建界面，
/// 省去手动 setState 的样板代码。
///
/// 【属性】
/// - future:       要监听的 Future；为 null 时状态为 none
/// - initialData:  初始数据，在 Future 完成前先显示
/// - builder:      (context, snapshot) 构建界面
///   snapshot.connectionState: none / waiting / active / done
///   snapshot.hasData / data:  是否有数据 / 数据
///   snapshot.hasError / error: 是否出错 / 错误
///
/// 【注意】
/// - 不要在 build 里直接创建 Future（每次重建都会重新请求）；
///   应在 initState 中创建并保存成员变量，刷新时在 setState 里重新赋值
/// - 先判断 hasError，再判断 hasData，最后是加载中
/// - 持续产生数据（多次）用 StreamBuilder
///
/// 【常见使用场景】
/// 1. 网络请求结果展示
/// 2. 读取本地文件 / 数据库
/// 3. 一次性异步初始化后展示界面
class FutureBuilderDemo extends StatefulWidget {
  const FutureBuilderDemo({super.key});

  @override
  State<FutureBuilderDemo> createState() => _FutureBuilderDemoState();
}

class _FutureBuilderDemoState extends State<FutureBuilderDemo> {
  late Future<String> _future;
  int _times = 0;

  Future<String> _load({bool fail = false}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (fail) throw Exception('模拟网络错误');
    return '第 ${++_times} 次加载成功';
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Widget _buildResult(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('出错：${snapshot.error}', style: const TextStyle(color: Colors.red));
    }
    return Text(snapshot.data ?? '无数据');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：加载中 / 成功 / 失败 三种状态'),
          Center(
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () => setState(() => _future = _load()), child: const Text('重新加载（成功）')),
                ElevatedButton(
                  onPressed: () => setState(() => _future = _load(fail: true)),
                  child: const Text('重新加载（失败）'),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<String>(future: _future, builder: (context, snapshot) => _buildResult(snapshot)),
            ),
          ),
          const _Label('示例 2：initialData 先显示占位数据'),
          Center(
            child: FutureBuilder<String>(
              future: Future.delayed(const Duration(seconds: 1), () => '真实数据'),
              initialData: '初始数据（1 秒后变为真实数据）',
              builder: (context, snapshot) => Text(snapshot.data ?? ''),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== StreamBuilder =====================
///
/// 【是什么】
/// 监听一个 Stream（可持续产生多个值的异步序列），每来一个新值就重建界面。
///
/// 【属性】
/// - stream:       要监听的 Stream
/// - initialData:  第一个事件到来前显示的数据
/// - builder:      (context, snapshot) 构建界面；
///                 connectionState: waiting（等第一个事件）/ active（数据流动中）/
///                 done（流已关闭）；data / error 同 FutureBuilder
///
/// 【注意】
/// - 不要在 build 里每次创建新 Stream；在 initState 创建，dispose 中关闭
///   StreamController / 取消订阅
/// - 普通 Stream 只能被监听一次，多处监听需用 asBroadcastStream()
/// - 只想响应单个值的变化，ValueListenableBuilder 更轻量
///
/// 【常见使用场景】
/// 1. 倒计时、定时器、实时时钟
/// 2. WebSocket、聊天消息、传感器数据
/// 3. Firebase 等实时数据库监听
class StreamBuilderDemo extends StatefulWidget {
  const StreamBuilderDemo({super.key});

  @override
  State<StreamBuilderDemo> createState() => _StreamBuilderDemoState();
}

class _StreamBuilderDemoState extends State<StreamBuilderDemo> {
  late final Stream<int> _ticker;
  final StreamController<String> _controller = StreamController<String>();
  int _msgIndex = 0;

  @override
  void initState() {
    super.initState();
    // 每秒发出一个递增数字
    _ticker = Stream<int>.periodic(const Duration(seconds: 1), (i) => i + 1);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：Stream.periodic 每秒计数'),
          Center(
            child: StreamBuilder<int>(
              stream: _ticker,
              initialData: 0,
              builder: (context, snapshot) => Text('已过 ${snapshot.data} 秒', style: const TextStyle(fontSize: 24)),
            ),
          ),
          const _Label('示例 2：StreamController 手动发送事件'),
          Center(
            child: ElevatedButton(onPressed: () => _controller.add('消息 #${++_msgIndex}'), child: const Text('发送一条消息')),
          ),
          Center(
            child: StreamBuilder<String>(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('等待第一条消息…');
                  case ConnectionState.done:
                    return const Text('流已关闭');
                  default:
                    return Text('收到：${snapshot.data}');
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== ValueListenableBuilder =====================
///
/// 【是什么】
/// 监听一个 ValueListenable（最常用的是 ValueNotifier），值变化时
/// 只重建 builder 里的那一小块界面，不需要 StatefulWidget + setState。
///
/// 【属性】
/// - valueListenable: 要监听的对象，如 `ValueNotifier<int>`
/// - builder:         (context, value, child) 构建界面
/// - child:           不依赖 value 的子树，会被缓存并通过 builder 的第三个
///                    参数传入，变化时不会重建，提高性能
///
/// 【注意】
/// - ValueNotifier 要在 State.dispose 中调用 dispose()
/// - 修改 value 才会通知；对象内部字段变化（如 list.add）不会触发，
///   需要赋值新对象
/// - 值相等（==）时不会通知
///
/// 【常见使用场景】
/// 1. 局部刷新（只刷新计数文本而非整个页面）
/// 2. 表单输入监听（TextEditingController 本身就是 ValueListenable）
/// 3. 简单的跨组件共享状态
class ValueListenableBuilderDemo extends StatefulWidget {
  const ValueListenableBuilderDemo({super.key});

  @override
  State<ValueListenableBuilderDemo> createState() => _ValueListenableBuilderDemoState();
}

class _ValueListenableBuilderDemoState extends State<ValueListenableBuilderDemo> {
  final ValueNotifier<int> _count = ValueNotifier<int>(0);
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _count.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 整个 State 只 build 一次，按钮点击不会触发它重建
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：ValueNotifier 局部刷新（无 setState）'),
          Center(
            child: ValueListenableBuilder<int>(
              valueListenable: _count,
              builder: (context, value, child) => Column(
                children: [
                  Text('$value', style: const TextStyle(fontSize: 32)),
                  child!, // 缓存的子树不会重建
                ],
              ),
              child: const Text('我是 child，不会重建'),
            ),
          ),
          Center(
            child: ElevatedButton(onPressed: () => _count.value++, child: const Text('+1')),
          ),
          const _Label('示例 2：监听 TextEditingController 的输入'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _text,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '输入点什么'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _text,
              builder: (context, value, _) => Text('字数：${value.text.length}，内容：${value.text}'),
            ),
          ),
        ],
      ),
    );
  }
}
