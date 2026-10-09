import 'package:flutter/material.dart';

/// ===================== GestureDetector =====================
///
/// 【是什么】
/// GestureDetector 是一个不绘制 UI 的手势识别器，可以监听点击、长按、
/// 拖动、缩放等原始手势，适合给任意组件添加交互。
///
/// 【属性】
/// - child / on 同名回调: child 是响应手势的区域；onTap、onDoubleTap、
///   onLongPress 等回调在对应手势发生时触发
/// - onTapDown / onTapUp / onTapCancel: 点击按下、抬起、取消时触发
/// - onPanStart / onPanUpdate / onPanEnd: 任意方向拖动的生命周期回调
/// - onVerticalDrag... / onHorizontalDrag...: 只识别指定方向的拖动
/// - onScaleStart / onScaleUpdate / onScaleEnd: 监听双指缩放、旋转和焦点
/// - behavior: HitTestBehavior，控制透明区域是否也参与命中测试
/// - excludeFromSemantics: 是否从无障碍语义树中排除
///
/// 【注意】
/// - 空白区域默认不一定能命中手势；需要让透明区域可点时设置 behavior
///   为 HitTestBehavior.opaque
/// - 父子手势可能发生竞争，GestureArena 会决定由哪个识别器获胜
/// - 只做 Material 风格点击反馈时，优先考虑 InkWell
///
/// 【常见使用场景】
/// 1. 给图片、卡片或自定义绘制区域添加点击/长按操作
/// 2. 自定义拖动、滑动、缩放交互
/// 3. 检测双击、单击等不适合使用按钮组件的手势
class GestureDetectorDemo extends StatefulWidget {
  const GestureDetectorDemo({super.key});

  @override
  State<GestureDetectorDemo> createState() => _GestureDetectorDemoState();
}

class _GestureDetectorDemoState extends State<GestureDetectorDemo> {
  int _tapCount = 0;
  String _gesture = '试试下面的手势';
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 点击、双击与长按', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _tapCount++;
              _gesture = '单击';
            }),
            onDoubleTap: () => setState(() => _gesture = '双击'),
            onLongPress: () => setState(() => _gesture = '长按'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text('$_gesture · 单击计数：$_tapCount'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('2. 监听拖动方向与位移', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.flag, color: Colors.green),
                ),
                Positioned(
                  left: _dragX.clamp(0, 240),
                  top: 25,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) => setState(() {
                      _dragX = (_dragX + details.delta.dx).clamp(0, 240);
                    }),
                    onHorizontalDragEnd: (_) => setState(() => _gesture = '水平拖动完成'),
                    child: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.open_with, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(_gesture),
          const SizedBox(height: 24),
          const Text('3. 多指缩放', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onScaleUpdate: (details) => setState(() {
                _gesture = '缩放比例：${details.scale.toStringAsFixed(2)}';
              }),
              child: Container(
                width: 160,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.orange.shade200, borderRadius: BorderRadius.circular(12)),
                child: const Text('双指捏合或展开'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Dismissible =====================
///
/// 【是什么】
/// Dismissible 是可通过滑动移除的列表项，常用于待办事项、通知和邮件列表。
///
/// 【属性】
/// - key: 每一项必须有稳定且唯一的 Key，移除列表项时尤其重要
/// - child: 正常显示的内容
/// - background / secondaryBackground: 向起始方向 / 结束方向滑动时显示的背景
/// - onDismissed: 滑动完成并移除动画结束后调用，通常在这里更新数据
/// - confirmDismiss: 可异步确认是否允许移除，返回 false 可取消
/// - direction: 可滑动方向，如 horizontal、endToStart 或 vertical
/// - resizeDuration: 移除后收缩占位空间的动画时长；设为 null 可关闭
/// - movementDuration / dismissThresholds: 移动动画时长及触发阈值
/// - crossAxisEndOffset: 滑出时在垂直方向的偏移比例
///
/// 【注意】
/// - onDismissed 中应同步从数据源删除对应项，否则重建时可能再次显示
/// - key 不能重复，也不要用会随列表变化的索引作为不稳定身份标识
/// - 背景通常要与 child 尺寸一致；方向不同可用 secondaryBackground 区分
/// - 删除前需确认的场景使用 confirmDismiss，而不是在 onDismissed 中拦截
///
/// 【常见使用场景】
/// 1. 滑动删除待办事项、聊天会话或邮件
/// 2. 左右滑动执行归档、稍后处理等操作
/// 3. 可撤销的消息或通知列表
class DismissibleDemo extends StatefulWidget {
  const DismissibleDemo({super.key});

  @override
  State<DismissibleDemo> createState() => _DismissibleDemoState();
}

class _DismissibleDemoState extends State<DismissibleDemo> {
  final List<String> _items = ['待办事项：阅读文档', '通知：课程已更新', '邮件：欢迎加入'];
  bool _verticalVisible = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 向左或向右滑动移除', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_items.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('列表已清空，请重置后再试。')),
          ..._items.map(
            (item) => Dismissible(
              key: ValueKey(item),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.green,
                child: const Icon(Icons.archive, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => setState(() => _items.remove(item)),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(item),
                  subtitle: const Text('向左删除 · 向右归档'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('2. 限制滑动方向', style: TextStyle(fontWeight: FontWeight.bold)),
          if (_verticalVisible)
            Dismissible(
              key: const ValueKey('vertical-only'),
              direction: DismissDirection.vertical,
              background: Container(
                alignment: Alignment.topCenter,
                color: Colors.amber.shade200,
                child: const Icon(Icons.keyboard_arrow_up),
              ),
              secondaryBackground: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.amber.shade200,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              onDismissed: (_) => setState(() => _verticalVisible = false),
              child: const Card(child: ListTile(title: Text('只能上下滑动此示例项'))),
            )
          else
            const Text('垂直滑动项已移除'),
          TextButton.icon(
            onPressed: () => setState(() {
              _items
                ..clear()
                ..addAll(['待办事项：阅读文档', '通知：课程已更新', '邮件：欢迎加入']);
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('重置第一组列表'),
          ),
        ],
      ),
    );
  }
}

/// ===================== Draggable =====================
///
/// 【是什么】
/// Draggable 让子组件成为拖拽源，配合 DragTarget 接收数据，可构建拖放交互。
///
/// 【属性】
/// - child: 未拖动时显示的内容
/// - feedback: 手指拖动时跟随显示的组件
/// - data: 传递给目标组件的数据
/// - childWhenDragging: 拖动期间原位置显示的替代组件
/// - axis: 限制拖动轴向；affinity 用于指定竞争手势的优先方向
/// - feedbackOffset: 拖动反馈相对指针的偏移
/// - maxSimultaneousDrags: 同时允许的拖动数量，设为 0 可禁用
/// - onDragStarted / onDragUpdate / onDraggableCanceled / onDragEnd:
///   拖动过程中的状态回调
/// - DragTarget.builder / onWillAcceptWithDetails / onAcceptWithDetails:
///   构建目标外观、判断是否接收、处理带类型的数据
///
/// 【注意】
/// - Draggable 与 DragTarget 的数据类型必须匹配
/// - feedback 不参与原布局；childWhenDragging 用于保留原位置的视觉提示
/// - DragTarget 的接收回调只应执行接收后的更新，目标区域需有实际尺寸
/// - 更简单的列表重排可使用 ReorderableListView
///
/// 【常见使用场景】
/// 1. 拖动卡片到分类区或回收区
/// 2. 拼图、配对题、看板和文件拖放
/// 3. 自定义可拖拽控件及目标区域
class DraggableDemo extends StatefulWidget {
  const DraggableDemo({super.key});

  @override
  State<DraggableDemo> createState() => _DraggableDemoState();
}

class _DraggableDemoState extends State<DraggableDemo> {
  String _result = '把蓝色方块拖到目标区域';
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Draggable + DragTarget', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Draggable<String>(
                data: 'Flutter',
                feedback: Material(color: Colors.transparent, child: _dragChip('Flutter', Colors.blue, elevation: 8)),
                childWhenDragging: _dragChip('拖动中', Colors.grey),
                onDragStarted: () => setState(() => _result = '正在拖动…'),
                onDraggableCanceled: (_, _) => setState(() => _result = '没有放到目标区域'),
                child: _dragChip('Flutter', Colors.blue),
              ),
              DragTarget<String>(
                onWillAcceptWithDetails: (details) => details.data == 'Flutter',
                onAcceptWithDetails: (details) => setState(() {
                  _result = '成功接收：${details.data}';
                  _accepted = true;
                }),
                builder: (context, candidates, rejected) => Container(
                  width: 140,
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: candidates.isNotEmpty || _accepted ? Colors.green.shade100 : Colors.orange.shade100,
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_accepted ? '已接收' : '放在这里'),
                ),
              ),
            ],
          ),
          Text(_result),
          const SizedBox(height: 24),
          const Text('2. 限制拖动方向与类型', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Draggable<int>(
            data: 42,
            axis: Axis.horizontal,
            feedback: _dragChip('数字 42', Colors.deepPurple, elevation: 8),
            childWhenDragging: _dragChip('仅水平拖动', Colors.grey),
            child: _dragChip('数字 42', Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          DragTarget<int>(
            onAcceptWithDetails: (details) => setState(() => _result = '收到数字：${details.data}'),
            builder: (context, candidates, rejected) => Container(
              width: double.infinity,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(candidates.isEmpty ? '数字目标区' : '松手接收数字'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dragChip(String text, Color color, {double elevation = 0}) {
    return Material(
      color: color,
      elevation: elevation,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// ===================== InkWell =====================
///
/// 【是什么】
/// InkWell 是 Material Design 的水波纹点击区域，点击反馈绘制在最近的
/// Material 组件上，适合列表项、卡片和按钮式区域。
///
/// 【属性】
/// - child: 点击区域中的子组件
/// - onTap / onDoubleTap / onLongPress: 单击、双击、长按回调
/// - onTapDown / onTapUp / onTapCancel: 点击按下、抬起及取消回调
/// - onHover / onFocusChange: 鼠标悬停及键盘焦点状态变化回调
/// - onHighlightChanged: 高亮状态变化回调
/// - splashColor / highlightColor / hoverColor / focusColor:
///   水波纹、按下高亮、悬停和焦点颜色
/// - borderRadius / customBorder: 水波纹裁剪形状
/// - radius: 水波纹半径；containedInkWell: 是否限制水波纹范围
/// - splashFactory / enableFeedback: 水波纹样式工厂及平台触觉反馈开关
///
/// 【注意】
/// - InkWell 需要祖先存在 Material；背景装饰应放在 Material 上，或使用
///   Ink 代替 Container，否则不透明背景可能遮住水波纹
/// - borderRadius 只裁剪墨水反馈，不会自动裁剪 child
/// - 不需要水波纹或 Material 反馈时可用 GestureDetector
///
/// 【常见使用场景】
/// 1. 可点击的列表项、卡片和菜单
/// 2. Material 风格的文字/图标按钮
/// 3. 需要点击、悬停、焦点多种反馈的自定义区域
class InkWellDemo extends StatefulWidget {
  const InkWellDemo({super.key});

  @override
  State<InkWellDemo> createState() => _InkWellDemoState();
}

class _InkWellDemoState extends State<InkWellDemo> {
  int _count = 0;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 基础水波纹与圆角', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Material(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.blue.withValues(alpha: 0.25),
              onTap: () => setState(() => _count++),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Center(child: Text('点击体验水波纹')),
              ),
            ),
          ),
          Text('点击次数：$_count'),
          const SizedBox(height: 24),
          const Text('2. 选中状态与自定义反馈颜色', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Material(
            color: _selected ? Colors.teal.shade100 : Colors.grey.shade100,
            child: InkWell(
              onTap: () => setState(() => _selected = !_selected),
              splashColor: Colors.teal.withValues(alpha: 0.3),
              highlightColor: Colors.teal.withValues(alpha: 0.12),
              child: ListTile(
                leading: Icon(_selected ? Icons.check_circle : Icons.circle_outlined),
                title: const Text('点按切换选择状态'),
                trailing: Text(_selected ? '已选中' : '未选中'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('3. 点击、双击和长按', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Material(
            color: Colors.orange.shade50,
            child: InkWell(
              onTap: () => _showMessage('单击'),
              onDoubleTap: () => _showMessage('双击'),
              onLongPress: () => _showMessage('长按'),
              child: const ListTile(leading: Icon(Icons.touch_app), title: Text('尝试单击、双击或长按')),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('检测到$message')));
  }
}
