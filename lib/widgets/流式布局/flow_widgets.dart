import 'package:flutter/material.dart';

// 流式布局：Wrap（自动换行）与 Flow（自定义定位，性能高）。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// ===================== Wrap =====================
///
/// 【是什么】
/// Wrap 像 Row/Column，但当一行（或一列）放不下时会"自动换行"，
/// 是最常用的流式布局组件，不会产生溢出错误。
///
/// 【属性】
/// - children:           子组件列表
/// - direction:          主轴方向，Axis.horizontal（默认，横向排满换行）/ Axis.vertical
/// - spacing:            主轴方向上子项之间的间距
/// - runSpacing:         "行与行"之间（交叉轴）的间距
/// - alignment:          每一行内子项在主轴上的对齐（start/center/end/spaceBetween...）
/// - runAlignment:       所有行作为整体在交叉轴上的对齐（Wrap 高度大于内容时才有效果）
/// - crossAxisAlignment: 每一行内子项在交叉轴上的对齐
/// - textDirection / verticalDirection: 排列方向的正反
/// - clipBehavior:       裁剪方式
///
/// 【注意】
/// - spacing 与 runSpacing 不要搞混：spacing 是同一行内的间距，runSpacing 是行间距
/// - Wrap 不能滚动；内容很多时请放到 SingleChildScrollView / ListView 中
/// - 子项数量特别多（上百）时，Wrap 一次性布局所有子项，性能不如 GridView.builder
/// - 想要每行等宽整齐的网格，用 GridView；Wrap 是"按各自宽度流式排列"
///
/// 【常见使用场景】
/// 1. 标签（Tag / Chip）云
/// 2. 搜索历史、热门搜索词
/// 3. 多选筛选条件
/// 4. 不确定数量、不确定宽度的按钮组
class WrapDemo extends StatelessWidget {
  const WrapDemo({super.key});

  static const _tags = [
    'Flutter',
    'Dart',
    'Widget',
    '布局',
    'Row',
    'Column',
    'Stack',
    '状态管理',
    '动画',
    'Material',
    'Cupertino',
    '路由',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：对比——同样的内容用 Row 会溢出，Wrap 自动换行
          _title('1. 基础用法：自动换行'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(children: [for (final t in _tags) Chip(label: Text(t))]),
          ),

          // 示例 2：spacing / runSpacing
          _title('2. spacing: 8（同行间距）, runSpacing: 4（行间距）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, runSpacing: 4, children: [for (final t in _tags) Chip(label: Text(t))]),
          ),

          // 示例 3：alignment 居中 / 两端对齐
          _title('3. alignment: center'),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [for (final t in _tags.take(8)) Chip(label: Text(t))],
            ),
          ),
          _title('4. alignment: spaceBetween'),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [for (final t in _tags.take(8)) Chip(label: Text(t))],
            ),
          ),

          // 示例 5：crossAxisAlignment——高度不同的子项
          _title('5. crossAxisAlignment: center（高低不一的子项居中）'),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < 6; i++)
                  Container(width: 50, height: 20.0 + (i % 3) * 20, color: Colors.primaries[i * 2]),
              ],
            ),
          ),

          // 示例 6：direction 垂直，需要限定高度才会换列
          _title('6. direction: vertical（高度 120 后换列）'),
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Wrap(
              direction: Axis.vertical,
              spacing: 6,
              runSpacing: 10,
              children: [
                for (var i = 0; i < 10; i++)
                  Container(
                    width: 40,
                    height: 30,
                    color: Colors.primaries[i],
                    alignment: Alignment.center,
                    child: Text('$i', style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 自定义 Flow 的布局委托：把子项沿水平方向依次排开，
/// 展开程度由动画值 progress 控制（0 时全部叠在一起，1 时完全展开）。
class _FanDelegate extends FlowDelegate {
  _FanDelegate(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paintChildren(FlowPaintingContext context) {
    // 第 0 个子项是"主按钮"，固定在左边；其余子项随 progress 向右展开
    for (var i = 0; i < context.childCount; i++) {
      final size = context.getChildSize(i)!;
      final dx = i * (size.width + 8) * progress.value;
      context.paintChild(i, transform: Matrix4.translationValues(dx, 0, 0), opacity: i == 0 ? 1 : progress.value);
    }
  }

  @override
  bool shouldRepaint(covariant _FanDelegate old) => old.progress != progress;
}

/// 简单的"流式换行"委托：按固定尺寸一行行排，放不下换行
class _SimpleWrapDelegate extends FlowDelegate {
  _SimpleWrapDelegate();

  final double gap = 6;

  @override
  void paintChildren(FlowPaintingContext context) {
    var x = 0.0;
    var y = 0.0;
    for (var i = 0; i < context.childCount; i++) {
      final s = context.getChildSize(i)!;
      if (x + s.width > context.size.width) {
        x = 0;
        y += s.height + gap;
      }
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
      x += s.width + gap;
    }
  }

  @override
  Size getSize(BoxConstraints constraints) => Size(constraints.maxWidth, 140);

  @override
  bool shouldRepaint(covariant _SimpleWrapDelegate old) => false;
}

/// ===================== Flow =====================
///
/// 【是什么】
/// Flow 是高度自定义、性能很高的流式布局：子组件的"位置"由你实现的
/// FlowDelegate 在绘制阶段通过矩阵变换决定，位置变化时只需重绘而不用重新布局，
/// 非常适合配合动画做"展开菜单"等效果。
///
/// 【属性】
/// - delegate:     必填，FlowDelegate 的子类，需实现：
///                 paintChildren(context) 用 context.paintChild(i, transform: ...) 绘制每个子项；
///                 shouldRepaint(old)     何时需要重绘；
///                 可选 getSize(constraints) 指定 Flow 自身大小；
///                 getConstraintsForChild(i, constraints) 为子项指定约束
/// - children:     子组件列表
/// - clipBehavior: 裁剪方式，默认 Clip.hardEdge
///
/// 【注意】
/// - 初学者优先使用 Wrap；只有需要精确控制位置、做动画或追求性能时才用 Flow
/// - Flow 的位置只影响"绘制"，子项的点击区域会跟着变换后的位置，
///   但子项的"布局占位"并不改变
/// - Flow 自身大小由 delegate.getSize 决定，没重写时会取约束的最大值，
///   在无界空间（如 Column 内）需要重写 getSize 给出有限尺寸，否则报错
/// - 构造函数 super(repaint: animation) 可让动画驱动重绘而不触发 build
///
/// 【常见使用场景】
/// 1. 展开式浮动菜单（点击主按钮弹出多个按钮）
/// 2. 自定义的圆形 / 扇形 / 瀑布式排列
/// 3. 大量子项的动画布局，追求高性能
class FlowDemo extends StatefulWidget {
  const FlowDemo({super.key});

  @override
  State<FlowDemo> createState() => _FlowDemoState();
}

class _FlowDemoState extends State<FlowDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Widget _circle(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：自定义换行排列（用 delegate 实现类似 Wrap 的效果）
          _title('1. 自定义委托：宽度不够自动换行'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Flow(
              delegate: _SimpleWrapDelegate(),
              children: [
                for (var i = 0; i < 14; i++)
                  Container(
                    width: 50.0 + (i % 3) * 15,
                    height: 36,
                    color: Colors.primaries[i],
                    alignment: Alignment.center,
                    child: Text('$i', style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),

          // 示例 2：动画展开菜单
          _title('2. 动画：点击主按钮展开 / 收起'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 56,
              child: Flow(
                delegate: _FanDelegate(_controller),
                children: [
                  _circle(Icons.menu, Colors.indigo, _toggle),
                  _circle(Icons.home, Colors.orange, () {}),
                  _circle(Icons.search, Colors.teal, () {}),
                  _circle(Icons.settings, Colors.pink, () {}),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '提示：动画值变化时只会触发 Flow 重绘，不会重新 build 整个组件，因此性能很高。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
