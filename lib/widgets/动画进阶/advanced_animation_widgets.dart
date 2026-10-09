import 'dart:math' as math;

import 'package:flutter/material.dart';

// 动画进阶：AnimationController + Tween、TweenAnimationBuilder、
// AnimatedSwitcher、AnimatedList、交错动画（Staggered）。
//
// 速查：怎么选动画方式？
// | 需求                               | 推荐                              |
// |------------------------------------|-----------------------------------|
// | 属性变了自动过渡                   | AnimatedXxx 隐式动画（见「动画」） |
// | 从 A 到 B 的一次性自定义补间       | TweenAnimationBuilder             |
// | 新旧子组件切换                     | AnimatedSwitcher                  |
// | 列表插入 / 删除                    | AnimatedList / SliverAnimatedList |
// | 需要播放、暂停、反向、循环、监听   | AnimationController（显式动画）    |
// | 多个动画按时间先后编排             | 一个 Controller + 多个 Interval   |

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// ===================== AnimationController + Tween =====================
///
/// 【是什么】
/// 显式动画三件套：
/// - AnimationController：动画的"播放器"，在 duration 内把 value 从 0.0 推到 1.0，
///   需要 vsync（State 混入 SingleTickerProviderStateMixin）
/// - CurvedAnimation：给 0~1 的进度加上曲线（加速、回弹……）
/// - Tween：把 0~1 映射成真正需要的值（尺寸、颜色、角度、偏移……）
///
/// 【常用 API】
/// - forward() / reverse() / repeat(reverse: true) / stop() / reset()
/// - animateTo(0.5)：动画到指定进度
/// - addStatusListener：dismissed / forward / reverse / completed
/// - `Tween<double>(begin, end)`.animate(curved)
/// - ColorTween / AlignmentTween / `Tween<Offset>` 等
///
/// 【注意】
/// - Controller 必须在 dispose() 里释放
/// - 用 AnimatedBuilder（或 XxxTransition）只重建需要变化的部分，不要整页 setState
/// - 多个 Controller 时用 TickerProviderStateMixin
///
/// 【常见使用场景】
/// 1. 需要手动控制播放 / 暂停 / 反向的动画
/// 2. 循环动画（呼吸灯、加载动画）
/// 3. 根据手势进度驱动动画（controller.value = dx / width）
class ExplicitAnimationDemo extends StatefulWidget {
  const ExplicitAnimationDemo({super.key});

  @override
  State<ExplicitAnimationDemo> createState() => _ExplicitAnimationDemoState();
}

class _ExplicitAnimationDemoState extends State<ExplicitAnimationDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..addStatusListener((status) => setState(() => _status = status));

  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutBack,
    reverseCurve: Curves.easeIn,
  );
  late final Animation<double> _size = Tween<double>(begin: 60, end: 160).animate(_curved);
  late final Animation<Color?> _color = ColorTween(begin: Colors.blue, end: Colors.pink).animate(_controller);
  late final Animation<double> _angle = Tween<double>(begin: 0, end: math.pi).animate(_curved);

  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SizedBox(
          height: 220,
          child: Center(
            // AnimatedBuilder：每一帧只重建 builder 里的内容
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _angle.value,
                  child: Container(
                    width: _size.value,
                    height: _size.value,
                    decoration: BoxDecoration(color: _color.value, borderRadius: BorderRadius.circular(16)),
                    child: child,
                  ),
                );
              },
              // child 不随动画变化，传进去可避免重复构建
              child: const Icon(Icons.flutter_dash, color: Colors.white, size: 48),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => Column(
            children: [
              Text('controller.value = ${_controller.value.toStringAsFixed(2)}    status = ${_status.name}'),
              Slider(
                value: _controller.value,
                onChanged: (v) {
                  _controller.stop();
                  _controller.value = v; // 手动拖动进度
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: _controller.forward, child: const Text('forward')),
              FilledButton(onPressed: _controller.reverse, child: const Text('reverse')),
              FilledButton.tonal(onPressed: () => _controller.repeat(reverse: true), child: const Text('repeat')),
              OutlinedButton(onPressed: _controller.stop, child: const Text('stop')),
              OutlinedButton(onPressed: _controller.reset, child: const Text('reset')),
            ],
          ),
        ),
        _title('同一个 Controller 驱动三个 Tween'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '• 尺寸：Tween<double>(60 → 160) + easeInOutBack 曲线\n'
            '• 颜色：ColorTween(蓝 → 粉)，线性\n'
            '• 角度：Tween<double>(0 → π) + 同一条曲线',
          ),
        ),
      ],
    );
  }
}

/// ===================== TweenAnimationBuilder =====================
///
/// 【是什么】
/// 不需要自己创建 Controller 的"自定义隐式动画"：
/// 给出 tween 和 duration，builder 会收到逐帧变化的值。
/// 当 tween.end 改变时，会从当前值平滑过渡到新的 end。
///
/// 【属性】
/// - tween: 必填，如 `Tween<double>(begin: 0, end: target)`
/// - duration / curve: 时长与曲线
/// - builder: (context, value, child) => Widget
/// - child: 不随动画变化的子组件，可提升性能
/// - onEnd: 动画结束回调
///
/// 【注意】
/// - begin 只在第一次构建时生效，之后都是"从当前值到新的 end"
/// - 不能暂停 / 反向 / 循环，这些需求请用 AnimationController
///
/// 【常见使用场景】
/// 数字滚动、进度环、颜色渐变等"值从 A 变到 B"的效果
class TweenAnimationBuilderDemo extends StatefulWidget {
  const TweenAnimationBuilderDemo({super.key});

  @override
  State<TweenAnimationBuilderDemo> createState() => _TweenAnimationBuilderDemoState();
}

class _TweenAnimationBuilderDemoState extends State<TweenAnimationBuilderDemo> {
  double _progress = 0.3;
  int _score = 60;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 进度环：拖动滑块，进度平滑过渡'),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(value: value, strokeWidth: 10),
                    Center(child: Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.headlineSmall)),
                  ],
                ),
              );
            },
          ),
        ),
        Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
        _title('2. 数字滚动 + 颜色渐变'),
        Center(
          child: TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: _score),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) => Text(
              '$value 分',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color.lerp(Colors.red, Colors.green, value / 100),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final s in [0, 30, 60, 100])
                ChoiceChip(label: Text('$s'), selected: _score == s, onSelected: (_) => setState(() => _score = s)),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===================== AnimatedSwitcher =====================
///
/// 【是什么】
/// 当 child 换成"另一个"组件时，旧的执行退出动画、新的执行进入动画（默认淡入淡出）。
///
/// 【属性】
/// - child: 当前显示的子组件
/// - duration / reverseDuration: 进入 / 退出时长
/// - transitionBuilder: 自定义过渡，如 ScaleTransition、SlideTransition
/// - switchInCurve / switchOutCurve: 曲线
/// - layoutBuilder: 新旧组件同时存在时如何布局（默认 Stack 居中叠放）
///
/// 【注意】
/// - 判断"是不是新组件"靠 runtimeType + key；同类型组件必须给不同的 Key
///   （如 Text('$count', key: ValueKey(count))），否则不会有动画！
///
/// 【常见使用场景】
/// 计数器数字切换、加载中 ↔ 内容切换、图标状态切换（播放 / 暂停）
class AnimatedSwitcherDemo extends StatefulWidget {
  const AnimatedSwitcherDemo({super.key});

  @override
  State<AnimatedSwitcherDemo> createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<AnimatedSwitcherDemo> {
  int _count = 0;
  bool _playing = false;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 数字切换：缩放 + 淡入（Key 不同才会触发）'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(onPressed: () => setState(() => _count--), icon: const Icon(Icons.remove)),
            SizedBox(
              width: 100,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '$_count',
                  key: ValueKey(_count),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            IconButton.filledTonal(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add)),
          ],
        ),
        _title('2. 图标切换：旋转过渡'),
        Center(
          child: IconButton(
            iconSize: 64,
            onPressed: () => setState(() => _playing = !_playing),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(turns: animation, child: child),
              child: Icon(_playing ? Icons.pause_circle : Icons.play_circle, key: ValueKey(_playing)),
            ),
          ),
        ),
        _title('3. 加载中 ↔ 内容：从下方滑入'),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _loaded
                ? const Card(
                    key: ValueKey('content'),
                    child: Padding(padding: EdgeInsets.all(24), child: Text('🎉 内容加载完成')),
                  )
                : const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _loaded = !_loaded),
            child: Text(_loaded ? '切回加载中' : '模拟加载完成'),
          ),
        ),
      ],
    );
  }
}

/// ===================== AnimatedList =====================
///
/// 【是什么】
/// 插入 / 删除条目时带动画的列表。它自己维护条目数量，
/// 你需要同时修改数据源，并通过 `GlobalKey<AnimatedListState>` 通知它。
///
/// 【常用 API】
/// - initialItemCount: 初始条目数
/// - itemBuilder: (context, index, animation) => Widget
/// - _listKey.currentState!.insertItem(index)
/// - _listKey.currentState!.removeItem(index, (context, animation) => 被删条目的样子)
///
/// 【注意】
/// - 数据源和 insertItem / removeItem 必须保持同步，否则下标错乱
/// - removeItem 的 builder 里要用"删除前"的数据构建条目
/// - 在 CustomScrollView 中使用 SliverAnimatedList
///
/// 【常见使用场景】
/// 购物车、待办清单、聊天消息插入
class AnimatedListDemo extends StatefulWidget {
  const AnimatedListDemo({super.key});

  @override
  State<AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<int> _items = [1, 2, 3];
  int _next = 4;

  void _insert() {
    final index = _items.isEmpty ? 0 : 1; // 插在第二个位置，更容易看出动画
    _items.insert(index, _next++);
    _listKey.currentState!.insertItem(index, duration: const Duration(milliseconds: 400));
  }

  void _remove(int index) {
    final removed = _items.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildItem(removed, animation, removing: true),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildItem(int value, Animation<double> animation, {bool removing = false}) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          color: removing ? Colors.red.shade100 : null,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('$value')),
            title: Text('条目 $value'),
            trailing: removing
                ? null
                : IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(_items.indexOf(value))),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(onPressed: _insert, icon: const Icon(Icons.add), label: const Text('插入一条')),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _items.length,
            itemBuilder: (context, index, animation) => _buildItem(_items[index], animation),
          ),
        ),
      ],
    );
  }
}

/// ===================== 交错动画（Staggered Animation） =====================
///
/// 【是什么】
/// 用"一个" AnimationController 驱动"多个"动画，每个动画只在总时长的某一段内播放，
/// 形成先后有序的编排效果。关键是 Interval(begin, end) 曲线。
///
/// 【写法】
/// Tween(...).animate(CurvedAnimation(
///   parent: controller,
///   curve: const Interval(0.0, 0.4, curve: Curves.easeOut), // 只在前 40% 播放
/// ))
///
/// 【注意】
/// - Interval 的 begin / end 是 0~1 的比例，不是秒数
/// - 不同段可以重叠，形成"此起彼伏"的效果
/// - 列表项依次出现：第 i 项用 Interval(i * 0.1, i * 0.1 + 0.5)
///
/// 【常见使用场景】
/// 页面进场动画、列表依次出现、引导页、复杂的展开 / 收起效果
class StaggeredAnimationDemo extends StatefulWidget {
  const StaggeredAnimationDemo({super.key});

  @override
  State<StaggeredAnimationDemo> createState() => _StaggeredAnimationDemoState();
}

class _StaggeredAnimationDemoState extends State<StaggeredAnimationDemo> with SingleTickerProviderStateMixin {
  static const _count = 5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  // 方块：先变宽（0~0.3），再变圆（0.3~0.6），最后变色（0.6~1.0）
  late final Animation<double> _width = Tween<double>(begin: 60, end: 240).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.3, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _radius = Tween<double>(begin: 0, end: 30).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeInOut),
    ),
  );
  late final Animation<Color?> _color = ColorTween(
    begin: Colors.indigo,
    end: Colors.orange,
  ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1)));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 第 i 项在 [i*0.1, i*0.1+0.5] 区间内播放；提前创建好，避免每次 build 都新建
  late final List<Animation<double>> _items = List.generate(
    _count,
    (i) => CurvedAnimation(
      parent: _controller,
      curve: Interval(i * 0.1, i * 0.1 + 0.5, curve: Curves.easeOutCubic),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 一个方块：变宽 → 变圆 → 变色'),
        SizedBox(
          height: 80,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Container(
                width: _width.value,
                height: 60,
                decoration: BoxDecoration(color: _color.value, borderRadius: BorderRadius.circular(_radius.value)),
              ),
            ),
          ),
        ),
        _title('2. 列表依次滑入'),
        for (var i = 0; i < _count; i++)
          SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(_items[i]),
            child: FadeTransition(
              opacity: _items[i],
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text('第 ${i + 1} 项'),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(onPressed: () => _controller.forward(from: 0), child: const Text('重新播放')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _controller.reverse, child: const Text('倒放')),
            ],
          ),
        ),
      ],
    );
  }
}
