import 'dart:math' as math;

import 'package:flutter/material.dart';

// 绘制：CustomPaint / CustomPainter、ClipPath / CustomClipper。

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

/// ===================== CustomPaint + CustomPainter =====================
///
/// 【是什么】
/// CustomPaint 提供一块画布，由你继承 CustomPainter 在 paint(canvas, size)
/// 中用 Canvas 自由绘制线条、图形、文字、路径等。
///
/// 【属性】
/// - painter:       画在 child 下面的 CustomPainter
/// - foregroundPainter: 画在 child 上面的 CustomPainter
/// - size:          画布大小；没有 child 时使用，默认 Size.zero（什么都看不到！）
/// - child:         可选子组件；有 child 时画布大小跟随 child
/// - isComplex / willChange: 绘制提示，用于缓存优化
///
/// 【CustomPainter 要实现的方法】
/// - paint(Canvas canvas, Size size): 绘制逻辑
/// - shouldRepaint(old): 是否需要重绘，通常比较新旧参数
///
/// 【Canvas / Paint 常用 API】
/// - drawLine / drawRect / drawRRect / drawCircle / drawArc / drawPath
/// - drawOval / drawPoints / drawColor / drawParagraph(TextPainter 画文字)
/// - Paint: color 颜色、style（fill / stroke）、strokeWidth 线宽、
///   strokeCap 线帽、shader 渐变、isAntiAlias 抗锯齿
/// - Path: moveTo / lineTo / quadraticBezierTo / cubicTo / close
/// - save / restore / translate / rotate / scale: 保存恢复与坐标变换
///
/// 【注意】
/// - 一定要给 size 或 child，否则画布大小为 0
/// - 坐标原点在左上角，x 向右、y 向下；角度单位是弧度
/// - shouldRepaint 返回 true 过于频繁会影响性能；返回 false 则参数改变也不重绘
/// - 动画可传 repaint: animation 给 CustomPainter 构造，仅重绘不重建
/// - 需要事件交互时配合 GestureDetector，自己做坐标命中判断
///
/// 【常见使用场景】
/// 1. 自定义图表（折线、饼图、柱状图）
/// 2. 进度环、仪表盘、波浪动画
/// 3. 签名板 / 涂鸦画板
/// 4. 自定义形状与装饰
class CustomPaintDemo extends StatefulWidget {
  const CustomPaintDemo({super.key});

  @override
  State<CustomPaintDemo> createState() => _CustomPaintDemoState();
}

class _CustomPaintDemoState extends State<CustomPaintDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _progress = 0.6;
  final List<List<Offset>> _strokes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：基础图形（线、矩形、圆、描边圆、渐变）'),
          const Center(
            child: CustomPaint(size: Size(300, 120), painter: _ShapesPainter()),
          ),
          const _Label('示例 2：进度环（拖动滑块改变进度）'),
          Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
          Center(
            child: CustomPaint(size: const Size(120, 120), painter: _RingPainter(_progress)),
          ),
          const _Label('示例 3：动画（传入 repaint，只重绘不重建）'),
          Center(
            child: CustomPaint(size: const Size(120, 120), painter: _ClockPainter(_controller)),
          ),
          const _Label('示例 4：涂鸦画板（手指在灰色区域拖动）'),
          Center(
            child: GestureDetector(
              onPanStart: (d) => setState(() => _strokes.add([d.localPosition])),
              onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
              child: ClipRect(
                child: CustomPaint(
                  size: const Size(300, 160),
                  painter: _DoodlePainter(_strokes),
                  child: Container(width: 300, height: 160, color: Colors.black12),
                ),
              ),
            ),
          ),
          Center(
            child: TextButton(onPressed: () => setState(_strokes.clear), child: const Text('清空')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShapesPainter extends CustomPainter {
  const _ShapesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(10, 10), const Offset(100, 10), paint);

    canvas.drawRect(const Rect.fromLTWH(10, 30, 80, 60), paint..color = Colors.orange);

    canvas.drawCircle(const Offset(140, 60), 30, paint..color = Colors.green);

    canvas.drawCircle(
      const Offset(210, 60),
      30,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    final rect = const Rect.fromLTWH(250, 30, 45, 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..shader = const LinearGradient(colors: [Colors.purple, Colors.pink]).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final bg = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    final fg = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    // 从 12 点钟方向（-π/2）开始顺时针画弧
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, fg);

    final tp = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).round()}%',
        style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final angle = animation.value * 2 * math.pi - math.pi / 2;
    canvas.drawLine(
      center,
      center + Offset(math.cos(angle), math.sin(angle)) * (radius - 8),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) => false;
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in strokes) {
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  // strokes 是同一个 List 对象，内容变化时必须重绘
  @override
  bool shouldRepaint(covariant _DoodlePainter old) => true;
}

/// ===================== ClipPath + CustomClipper =====================
///
/// 【是什么】
/// ClipPath 按任意 Path 形状裁剪子组件，超出形状的部分不显示。
/// 形状由自定义的 `CustomClipper<Path>` 提供。
///
/// 【属性】
/// - clipper:       `CustomClipper<Path>`，实现 getClip(Size) 返回 Path
/// - clipBehavior:  裁剪方式，默认 Clip.antiAlias；hardEdge 更快但有锯齿
/// - child:         被裁剪的子组件
///
/// 【CustomClipper 要实现的方法】
/// - getClip(Size size): 返回裁剪路径，size 是子组件尺寸
/// - shouldReclip(old):  是否需要重新裁剪，参数没变返回 false
///
/// 【相关组件】
/// - ClipRect: 矩形裁剪；ClipRRect: 圆角矩形；ClipOval: 椭圆/圆形
/// - ClipPath.shape(shape:): 直接用 ShapeBorder（如 StarBorder）裁剪
///
/// 【注意】
/// - 裁剪只影响显示和点击区域，不改变布局大小
/// - 裁剪有性能开销，能用 BorderRadius / 圆角 Decoration 就别用 ClipPath
/// - Path 坐标以子组件左上角为原点，应基于 size 计算，不要写死
///
/// 【常见使用场景】
/// 1. 波浪形 / 弧形的头部背景
/// 2. 三角形、六边形等异形头像或卡片
/// 3. 圆角图片（ClipRRect）、圆形头像（ClipOval）
/// 4. 票券缺口样式
class CustomClipperDemo extends StatelessWidget {
  const CustomClipperDemo({super.key});

  Widget _color(double w, double h, String t) => Container(
    width: w,
    height: h,
    alignment: Alignment.center,
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.deepPurple])),
    child: Text(t, style: const TextStyle(color: Colors.white)),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：ClipRRect / ClipOval / ClipRect'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(20), child: _color(100, 80, 'ClipRRect')),
                ClipOval(child: _color(80, 80, 'ClipOval')),
                ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    widthFactor: 0.5, // 只保留左半
                    child: _color(100, 80, 'ClipRect'),
                  ),
                ),
              ],
            ),
          ),
          const _Label('示例 2：自定义三角形裁剪'),
          Center(
            child: ClipPath(clipper: _TriangleClipper(), child: _color(140, 120, '三角形')),
          ),
          const _Label('示例 3：波浪形头部背景'),
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: 140,
              width: double.infinity,
              alignment: const Alignment(0, -0.3),
              color: Colors.teal,
              child: const Text('波浪头部', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          const _Label('示例 4：五角星裁剪'),
          Center(
            child: ClipPath(clipper: _StarClipper(), child: _color(120, 120, '')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(size.width * 3 / 4, size.height - 60, size.width, size.height - 30);
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
