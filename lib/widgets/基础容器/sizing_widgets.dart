import 'package:flutter/material.dart';

// 尺寸与缩放：AspectRatio / FittedBox / FractionallySizedBox。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _box(String text, Color color) {
  return Container(
    color: color,
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

/// ===================== AspectRatio =====================
///
/// 【是什么】
/// 让子组件保持固定的宽高比（宽 / 高）。它会在父约束允许的范围内，
/// 先尽量取最大宽度，再按比例算出高度。
///
/// 【属性】
/// - aspectRatio: 必填，宽 / 高，例如 16 / 9、1.0、3 / 4
/// - child: 子组件
///
/// 【注意】
/// - 父组件必须至少在一个方向上给出有限约束；在无限高的 Column 里宽度有限即可
/// - 外层用 SizedBox / ConstrainedBox 限制宽度，可以控制最终大小
/// - 图片本身的比例用 Image 的 fit 处理；AspectRatio 控制的是"盒子"的比例
///
/// 【常见使用场景】
/// 视频播放器 16:9、商品方图 1:1、Banner 轮播图、卡片封面
class AspectRatioDemo extends StatefulWidget {
  const AspectRatioDemo({super.key});

  @override
  State<AspectRatioDemo> createState() => _AspectRatioDemoState();
}

class _AspectRatioDemoState extends State<AspectRatioDemo> {
  static const _ratios = {'16:9': 16 / 9, '4:3': 4 / 3, '1:1': 1.0, '3:4': 3 / 4};
  String _selected = '16:9';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('选择比例'),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final name in _ratios.keys)
              ChoiceChip(
                label: Text(name),
                selected: _selected == name,
                onSelected: (_) => setState(() => _selected = name),
              ),
          ],
        ),
        _title('1. 宽度撑满，高度按比例计算'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(aspectRatio: _ratios[_selected]!, child: _box('AspectRatio($_selected)', Colors.indigo)),
        ),
        _title('2. 外层限制宽度 200'),
        Center(
          child: SizedBox(
            width: 200,
            child: AspectRatio(aspectRatio: _ratios[_selected]!, child: _box(_selected, Colors.teal)),
          ),
        ),
        _title('3. 典型用法：视频封面 16:9 + 播放按钮'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===================== FittedBox =====================
///
/// 【是什么】
/// 把子组件按 fit 规则缩放（或裁剪）以适应自身大小，
/// 类似给任意组件用上 Image 的 BoxFit。
///
/// 【属性】
/// - fit: 缩放方式，默认 BoxFit.contain
///   contain 等比完整显示 / cover 等比铺满（可能裁剪） / fill 拉伸铺满
///   fitWidth / fitHeight 按一边适配 / scaleDown 只缩小不放大 / none 不缩放
/// - alignment: 子组件在 FittedBox 中的对齐
/// - clipBehavior: 超出部分是否裁剪
///
/// 【注意】
/// - FittedBox 会给子组件"无限制"约束让它按自然大小布局，再整体缩放；
///   所以子组件不能是需要有限约束的组件（例如无宽度的 Row + Expanded）
/// - 缩放的是绘制结果，文字也会跟着变小 / 变大
///
/// 【常见使用场景】
/// 1. 长文本 / 大数字在固定区域内自动缩小（不换行）
/// 2. 图标、Logo 在不同尺寸容器中自适应
class FittedBoxDemo extends StatefulWidget {
  const FittedBoxDemo({super.key});

  @override
  State<FittedBoxDemo> createState() => _FittedBoxDemoState();
}

class _FittedBoxDemoState extends State<FittedBoxDemo> {
  BoxFit _fit = BoxFit.contain;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 切换 fit，观察 200×100 的蓝框中子组件（120×120 的方块）如何变化'),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            for (final fit in BoxFit.values)
              ChoiceChip(label: Text(fit.name), selected: _fit == fit, onSelected: (_) => setState(() => _fit = fit)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 200,
            height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2)),
            child: FittedBox(
              fit: _fit,
              clipBehavior: Clip.hardEdge,
              child: Container(
                width: 120,
                height: 120,
                color: Colors.orange,
                alignment: Alignment.center,
                child: const Text('120×120'),
              ),
            ),
          ),
        ),
        _title('2. 大数字自动缩小，保证一行显示（scaleDown）'),
        for (final value in ['¥ 99', '¥ 9,999,999', '¥ 99,999,999,999,999'])
          Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.green.shade50,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

/// ===================== FractionallySizedBox =====================
///
/// 【是什么】
/// 按父组件可用空间的"比例"来确定子组件的尺寸。
///
/// 【属性】
/// - widthFactor: 宽度占父宽度的比例，如 0.5 = 50%；null 表示不限制
/// - heightFactor: 高度占父高度的比例
/// - alignment: 子组件在剩余空间中的对齐，默认居中
///
/// 【注意】
/// - 对应方向上父约束必须是有限的（比如 Column 里用 heightFactor 会报错）
/// - 在 Row / Column 里按比例分配空间时，一般用 Expanded(flex) 更合适
///
/// 【常见使用场景】
/// 按钮占屏幕宽度 80%、进度条、百分比布局
class FractionallySizedBoxDemo extends StatefulWidget {
  const FractionallySizedBoxDemo({super.key});

  @override
  State<FractionallySizedBoxDemo> createState() => _FractionallySizedBoxDemoState();
}

class _FractionallySizedBoxDemoState extends State<FractionallySizedBoxDemo> {
  double _factor = 0.6;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('widthFactor = ${_factor.toStringAsFixed(2)}'),
        Slider(value: _factor, min: 0.1, max: 1, onChanged: (v) => setState(() => _factor = v)),
        _title('1. 宽度为父组件的 ${(_factor * 100).round()}%'),
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.grey.shade300,
          child: FractionallySizedBox(widthFactor: _factor, child: _box('子组件', Colors.purple)),
        ),
        _title('2. alignment: centerLeft 做一个进度条'),
        Container(
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
          child: FractionallySizedBox(
            widthFactor: _factor,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        _title('3. 宽、高同时按比例（父容器 300×150）'),
        Center(
          child: Container(
            width: 300,
            height: 150,
            color: Colors.grey.shade300,
            child: FractionallySizedBox(
              widthFactor: _factor,
              heightFactor: _factor,
              child: _box('${(_factor * 300).round()} × ${(_factor * 150).round()}', Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
