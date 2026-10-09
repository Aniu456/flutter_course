import 'package:flutter/material.dart';

/// ===================== AnimatedContainer =====================
///
/// 【是什么】
/// AnimatedContainer 是 Container 的隐式动画版本；当尺寸、颜色、边距、
/// 装饰等属性变化时，会在指定时长内自动补间，不需要手动管理控制器。
///
/// 【属性】
/// - child: 子组件
/// - width / height / constraints: 动画过渡的尺寸和约束
/// - padding / alignment / margin: 内边距、对齐、外边距也可参与补间
/// - color / decoration / foregroundDecoration: 颜色或装饰；颜色变化可动画
/// - transform / transformAlignment: 变换矩阵及变换原点
/// - duration: 必填，动画时长
/// - curve: 动画曲线，如 Curves.easeInOut、Curves.bounceOut
/// - onEnd: 动画结束时调用
/// - clipBehavior: 子组件裁剪方式
///
/// 【注意】
/// - 至少有一个属性的目标值发生变化，动画才会播放
/// - color 与 decoration 不能同时设置；复杂装饰建议通过 decoration 动画
/// - 颜色、边距等只有类型支持补间时才会平滑过渡
/// - 需要逐帧控制、监听或组合多段动画时使用 AnimationController
///
/// 【常见使用场景】
/// 1. 点按展开卡片、改变尺寸或圆角
/// 2. 选中状态切换背景色、边框和内边距
/// 3. 使用较少代码实现常见状态过渡
class AnimatedContainerDemo extends StatefulWidget {
  const AnimatedContainerDemo({super.key});

  @override
  State<AnimatedContainerDemo> createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<AnimatedContainerDemo> {
  bool _expanded = false;
  bool _decorated = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 尺寸与颜色动画', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: _expanded ? 240 : 140,
              height: _expanded ? 140 : 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _expanded ? Colors.deepPurple : Colors.lightBlue,
                borderRadius: BorderRadius.circular(_expanded ? 28 : 8),
              ),
              child: Text(_expanded ? '展开状态' : '收起状态', style: const TextStyle(color: Colors.white)),
            ),
          ),
          Center(
            child: FilledButton(onPressed: () => setState(() => _expanded = !_expanded), child: const Text('切换尺寸和颜色')),
          ),
          const SizedBox(height: 24),
          const Text('2. 边框、阴影与内边距动画', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _decorated = !_decorated),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.bounceOut,
              padding: EdgeInsets.all(_decorated ? 28 : 16),
              decoration: BoxDecoration(
                color: _decorated ? Colors.amber.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(_decorated ? 24 : 8),
                border: Border.all(color: _decorated ? Colors.deepOrange : Colors.grey, width: _decorated ? 3 : 1),
                boxShadow: _decorated
                    ? const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
                    : const [],
              ),
              child: const Text('点击此卡片，切换装饰和留白'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('3. 动画曲线与结束回调', style: TextStyle(fontWeight: FontWeight.bold)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            width: _expanded ? 210 : 110,
            height: 56,
            margin: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            color: Colors.teal,
            onEnd: () {},
            child: const Text('Curves.elasticOut', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// ===================== AnimatedOpacity =====================
///
/// 【是什么】
/// AnimatedOpacity 是隐式透明度动画组件，在 opacity 改变时自动淡入或淡出。
///
/// 【属性】
/// - opacity: 目标透明度，范围为 0.0（完全透明）到 1.0（完全不透明）
/// - duration: 必填，透明度变化的动画时长
/// - curve: 动画曲线
/// - child: 被渐变显示/隐藏的子组件
/// - onEnd: 动画结束时调用
/// - alwaysIncludeSemantics: 透明时是否仍保留子组件的无障碍语义
///
/// 【注意】
/// - opacity 为 0 时 child 仍占据布局空间，也仍可能响应点击；隐藏交互可结合
///   IgnorePointer 或 Visibility
/// - 大面积透明度动画需要离屏合成，复杂界面要注意性能
/// - 仅需即时隐藏、不需要动画时可用 Visibility
///
/// 【常见使用场景】
/// 1. 内容淡入淡出
/// 2. 加载状态、提示信息的显示过渡
/// 3. 保留布局占位但暂时弱化内容
class AnimatedOpacityDemo extends StatefulWidget {
  const AnimatedOpacityDemo({super.key});

  @override
  State<AnimatedOpacityDemo> createState() => _AnimatedOpacityDemoState();
}

class _AnimatedOpacityDemoState extends State<AnimatedOpacityDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 淡入淡出（保留原有空间）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: Container(
                width: 220,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(12)),
                child: const Text('淡入淡出内容', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Center(
            child: FilledButton(
              onPressed: () => setState(() => _visible = !_visible),
              child: Text(_visible ? '淡出' : '淡入'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('2. 透明内容不再响应点击', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              child: Material(
                color: Colors.orange.shade100,
                child: InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('按钮仍可点击'))),
                  child: const ListTile(leading: Icon(Icons.touch_app), title: Text('可交互内容：先隐藏，再尝试点击')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('3. 延迟切换的淡入提示', style: TextStyle(fontWeight: FontWeight.bold)),
          AnimatedOpacity(
            opacity: _visible ? 1 : 0.25,
            duration: const Duration(milliseconds: 900),
            curve: Curves.decelerate,
            child: const Padding(padding: EdgeInsets.all(16), child: Text('opacity 取值介于 0.0 与 1.0 之间')),
          ),
        ],
      ),
    );
  }
}

/// ===================== Hero =====================
///
/// 【是什么】
/// Hero 在两个路由中寻找相同 tag 的组件，并在页面切换时执行共享元素过渡，
/// 常见效果是列表缩略图飞到详情页并放大。
///
/// 【属性】
/// - tag: 必填的匹配标识，同一时刻同一路由内必须唯一
/// - child: Hero 包裹的共享元素
/// - createRectTween: 自定义起止矩形之间的插值方式
/// - flightShuttleBuilder: 自定义飞行过程中的组件外观
/// - placeholderBuilder: 飞行期间原位置的占位外观
/// - transitionOnUserGestures: 是否在 iOS 返回手势过程中播放过渡
///
/// 【注意】
/// - 前后页面的 Hero tag 必须相同；同一路由中不能有重复 tag
/// - 通常通过 Navigator 推入新路由触发；直接替换组件不会启动 Hero 动画
/// - 两端 child 尺寸/形状可以不同，但复杂布局需检查飞行中的裁剪效果
/// - Hero 负责共享元素过渡，页面整体过渡仍由路由控制
///
/// 【常见使用场景】
/// 1. 图片列表到图片详情页
/// 2. 卡片头像、商品缩略图到详情页
/// 3. 页面间共享图标、颜色块或其他视觉元素
class HeroDemo extends StatelessWidget {
  const HeroDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 点击共享元素进入详情页', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: Hero(
              tag: 'hero-demo-card',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (context) => const _HeroDetailPage())),
                  child: Container(
                    width: 180,
                    height: 130,
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(18)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flight_takeoff, color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text('点我查看详情', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('2. tag 用于匹配前后路由的 Hero', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('目标页面使用相同的 tag；返回时也会反向播放动画。'),
        ],
      ),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero 详情页')),
      body: Center(
        child: Hero(
          tag: 'hero-demo-card',
          child: Container(
            width: 280,
            height: 240,
            decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(28)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flight_takeoff, color: Colors.white, size: 72),
                SizedBox(height: 16),
                Text('共享元素已放大', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== AnimatedBuilder =====================
///
/// 【是什么】
/// AnimatedBuilder 根据 Listenable（通常是 Animation）通知重建 builder，
/// 常与 AnimationController 配合实现显式动画，并可通过 child 避免重复构建静态内容。
///
/// 【属性】
/// - animation: 监听的 Listenable / Animation，变化时触发 builder
/// - builder: 根据动画值构建动态部分的回调
/// - child: 可选的静态子组件，动画过程中不会由 AnimatedBuilder 重复构建
/// - AnimationController.vsync: TickerProvider，用于屏幕刷新同步
/// - duration: 控制器正向播放的时长
/// - lowerBound / upperBound / value: 动画值的范围及初始值
/// - curve / Tween: CurvedAnimation 设置曲线；Tween 将动画值映射到目标范围
/// - forward / reverse / repeat / stop / reset: 控制动画播放
///
/// 【注意】
/// - AnimationController 只能在 State.initState 中创建，并在 dispose 中释放
/// - 控制器驱动动画时通常需要 StatefulWidget 和 SingleTickerProviderStateMixin
/// - 动画过程中每帧都会触发 builder；静态且较重的子树放进 child 参数
/// - 隐式动画更适合简单状态过渡；需要精确控制时再使用显式动画
///
/// 【常见使用场景】
/// 1. 旋转加载指示器、脉冲和循环动画
/// 2. 根据动画值精确控制位置、角度、颜色或尺寸
/// 3. 复用静态子组件以减少动画帧的构建开销
class AnimatedBuilderDemo extends StatefulWidget {
  const AnimatedBuilderDemo({super.key});

  @override
  State<AnimatedBuilderDemo> createState() => _AnimatedBuilderDemoState();
}

class _AnimatedBuilderDemoState extends State<AnimatedBuilderDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _rotation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. AnimatedBuilder 驱动旋转', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Center(
            child: AnimatedBuilder(
              animation: _rotation,
              child: const Icon(Icons.flutter_dash, size: 72, color: Colors.blue),
              builder: (context, child) =>
                  Transform.rotate(angle: _rotation.value * 2 * 3.141592653589793, child: child),
            ),
          ),
          const SizedBox(height: 24),
          const Text('2. 控制器播放、暂停与反向播放', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _controller.forward(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('正向'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _controller.reverse(),
                icon: const Icon(Icons.replay),
                label: const Text('反向'),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: '暂停/继续',
                onPressed: () {
                  if (_controller.isAnimating) {
                    _controller.stop();
                  } else {
                    _controller.repeat();
                  }
                },
                icon: const Icon(Icons.pause_circle_outline),
              ),
            ],
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Text('当前进度：${(_controller.value * 100).round()}%'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('3. 使用 Tween 改变大小', style: TextStyle(fontWeight: FontWeight.bold)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final size = 24 + 32 * _controller.value;
              return Center(
                child: Icon(Icons.favorite, size: size, color: Colors.pink),
              );
            },
          ),
        ],
      ),
    );
  }
}
