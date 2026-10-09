import 'package:flutter/material.dart';

// 适配与主题：Theme、MediaQuery、LayoutBuilder、SafeArea。

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}

/// ===================== Theme / ThemeData =====================
///
/// 【是什么】
/// Theme 为子树提供统一的外观配置（颜色、字体、各组件样式），
/// 子组件通过 Theme.of(context) 读取。ThemeData 是配置的集合。
///
/// 【属性】
/// - Theme.data:            子树使用的 ThemeData
/// - ThemeData.colorScheme: 配色方案，常用 ColorScheme.fromSeed(seedColor:)
///                          一个种子色生成整套颜色（primary、secondary、surface…）
/// - ThemeData.useMaterial3: 是否使用 Material 3 样式（新版默认开启）
/// - ThemeData.brightness / colorScheme.brightness: 亮色 / 暗色
/// - ThemeData.textTheme:   文本样式（titleLarge、bodyMedium…）
/// - ThemeData.appBarTheme / elevatedButtonTheme / cardTheme 等:
///                          针对某类组件的统一样式
/// - Theme.of(context):     读取最近的主题
/// - theme.copyWith(...):   在现有主题基础上局部覆盖
/// - MaterialApp.theme / darkTheme / themeMode: 全局主题 / 暗色主题 /
///                          跟随系统或手动指定
///
/// 【注意】
/// - 修改局部外观时，用 Theme(data: Theme.of(context).copyWith(...))，
///   不要整个重新构造 ThemeData，否则丢失其他配置
/// - 在 MaterialApp 的同一层 context 里读不到 MaterialApp 提供的 Theme，
///   需要用 Builder 或拆成子组件
/// - 颜色尽量用 colorScheme 的语义色，这样切换暗色模式自动适配
///
/// 【常见使用场景】
/// 1. 全局统一品牌色、字体
/// 2. 亮色 / 暗色模式切换
/// 3. 某个局部区域使用不同风格
class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  Color _seed = Colors.teal;
  bool _dark = false;

  Widget _sample(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      color: cs.surface,
      child: Column(
        children: [
          Text('标题样式 titleLarge', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Filled')),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            color: cs.primaryContainer,
            child: Text('primaryContainer', style: TextStyle(color: cs.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themed = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: _dark ? Brightness.dark : Brightness.light),
      useMaterial3: true,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：用 seedColor 生成配色，并切换亮/暗'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final c in [Colors.teal, Colors.deepOrange, Colors.indigo])
                  GestureDetector(
                    onTap: () => setState(() => _seed = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: _seed == c ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  ),
                const Text('暗色'),
                Switch(value: _dark, onChanged: (v) => setState(() => _dark = v)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Theme 只影响自己的子树
          Theme(
            data: themed,
            child: Builder(builder: _sample),
          ),
          const _Label('示例 2：copyWith 局部覆盖（仅改按钮颜色）'),
          Theme(
            data: Theme.of(context).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
              ),
            ),
            child: Center(
              child: ElevatedButton(onPressed: () {}, child: const Text('粉色按钮')),
            ),
          ),
          const _Label('示例 3：读取当前主题的值'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'primary = ${Theme.of(context).colorScheme.primary}\n'
              'brightness = ${Theme.of(context).brightness}',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== MediaQuery =====================
///
/// 【是什么】
/// 获取当前设备/窗口的信息：屏幕尺寸、方向、像素密度、安全区域、
/// 键盘高度、文字缩放、系统亮暗模式等。
///
/// 【属性】
/// - MediaQuery.of(context) / MediaQuery.sizeOf(context): 逻辑像素尺寸
/// - orientation:        Orientation.portrait / landscape
/// - devicePixelRatio:   物理像素 / 逻辑像素
/// - padding:            系统占用区域（刘海、状态栏、底部横条）
/// - viewInsets:         被遮挡区域，键盘弹出时 bottom 为键盘高度
/// - viewPadding:        不受键盘影响的系统区域
/// - textScaler:         系统字体缩放
/// - platformBrightness: 系统亮 / 暗模式
/// - 细分查询方法：sizeOf、orientationOf、paddingOf、viewInsetsOf、
///                       platformBrightnessOf —— 只订阅用到的字段，性能更好
///
/// 【注意】
/// - 它反映的是"窗口"信息，而不是父组件给的空间；想知道父组件可用空间
///   请用 LayoutBuilder
/// - 优先使用 sizeOf 等细分方法，避免无关变化（如键盘弹出）导致重建
/// - 窗口尺寸变化（旋转、分屏）时依赖它的组件会自动重建
///
/// 【常见使用场景】
/// 1. 按屏幕宽度的百分比设置组件尺寸
/// 2. 判断横竖屏切换布局
/// 3. 手机 / 平板自适应（宽度断点）
/// 4. 键盘弹出时调整界面
class MediaQueryDemo extends StatelessWidget {
  const MediaQueryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final insets = MediaQuery.viewInsetsOf(context);
    final isWide = size.width >= 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：设备信息'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '屏幕尺寸：${size.width.toStringAsFixed(1)} x '
              '${size.height.toStringAsFixed(1)}\n'
              '方向：${MediaQuery.orientationOf(context)}\n'
              '像素密度：${MediaQuery.devicePixelRatioOf(context)}\n'
              '系统 padding：top ${padding.top}, bottom ${padding.bottom}\n'
              '键盘高度 viewInsets.bottom：${insets.bottom}\n'
              '字体缩放：${MediaQuery.textScalerOf(context)}\n'
              '系统亮度：${MediaQuery.platformBrightnessOf(context)}',
            ),
          ),
          const _Label('示例 2：宽度为屏幕 60% 的色块'),
          Container(
            width: size.width * 0.6,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.blue,
            alignment: Alignment.center,
            child: const Text('60% 宽', style: TextStyle(color: Colors.white)),
          ),
          const _Label('示例 3：宽度断点（>= 600 视为平板）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Chip(avatar: Icon(isWide ? Icons.tablet : Icons.smartphone), label: Text(isWide ? '宽屏布局' : '窄屏布局')),
          ),
          const _Label('示例 4：键盘弹出时观察 viewInsets 变化（点击输入框）'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: '点击弹出键盘'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== LayoutBuilder =====================
///
/// 【是什么】
/// 在 builder 中拿到父组件传下来的 BoxConstraints（可用空间范围），
/// 根据它返回不同的子组件，实现"按可用空间自适应"。
///
/// 【属性】
/// - builder: (context, constraints) => Widget
///   constraints.maxWidth / maxHeight: 最大可用宽高
///   constraints.minWidth / minHeight: 最小宽高
///   constraints.biggest / smallest:   最大 / 最小尺寸
///
/// 【注意】
/// - 与 MediaQuery 的区别：LayoutBuilder 取得的是"父组件给的空间"，
///   MediaQuery 取得的是整个屏幕/窗口
/// - 约束变化时会重新 build，所以 builder 要轻量
/// - 父组件给的 maxWidth 可能为 double.infinity（如在横向滚动里），要判断
/// - 不能依赖子组件自身尺寸（那会循环依赖）
///
/// 【常见使用场景】
/// 1. 宽度足够时多列，不足时单列的响应式布局
/// 2. 根据可用宽度决定显示几个网格列
/// 3. 可复用组件根据所放位置的大小自适应
class LayoutBuilderDemo extends StatefulWidget {
  const LayoutBuilderDemo({super.key});

  @override
  State<LayoutBuilderDemo> createState() => _LayoutBuilderDemoState();
}

class _LayoutBuilderDemoState extends State<LayoutBuilderDemo> {
  double _width = 360;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：拖动滑块改变容器宽度，观察布局切换（断点 400）'),
          Slider(
            min: 150,
            max: 600,
            value: _width,
            label: _width.round().toString(),
            onChanged: (v) => setState(() => _width = v),
          ),
          Center(
            child: Container(
              width: _width,
              decoration: BoxDecoration(border: Border.all(color: Colors.deepPurple, width: 2)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 400;
                  final items = [
                    for (var i = 1; i <= 4; i++)
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(4),
                        color: Colors.primaries[i * 3],
                        alignment: Alignment.center,
                        child: Text('$i'),
                      ),
                  ];
                  return Column(
                    children: [
                      Text(
                        'maxWidth = ${constraints.maxWidth.round()}，'
                        '${wide ? "横排" : "竖排"}',
                      ),
                      if (wide) Row(children: [for (final w in items) Expanded(child: w)]) else Column(children: items),
                    ],
                  );
                },
              ),
            ),
          ),
          const _Label('示例 2：根据宽度计算网格列数（每列至少 100）'),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 100).floor().clamp(1, 6);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (var i = 0; i < 6; i++)
                    Container(color: Colors.primaries[i * 2], alignment: Alignment.center, child: Text('列数 $columns')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ===================== SafeArea =====================
///
/// 【是什么】
/// 自动给子组件加上内边距，避开刘海、状态栏、圆角、底部手势条等
/// 系统遮挡区域（数据来自 MediaQuery.padding）。
///
/// 【属性】
/// - child:    子组件
/// - left / top / right / bottom: 是否避开对应方向，默认都为 true
/// - minimum:  最小内边距（即使系统区域为 0 也保留）
/// - maintainBottomViewPadding: 键盘弹出时是否仍保留底部 padding
///
/// 【注意】
/// - Scaffold 的 AppBar、BottomNavigationBar 已自带处理，body 里通常不用再包；
///   没有 AppBar 的全屏页面、自定义 Stack 顶部/底部栏才需要
/// - 同一层级重复嵌套 SafeArea 不会重复加（内层 padding 已被消耗）
/// - 模拟器 / 无刘海设备上看不出区别，需在真机或刘海模拟器验证
///
/// 【常见使用场景】
/// 1. 全屏页面（无 AppBar）顶部内容避开状态栏
/// 2. 底部按钮避开 iPhone 底部横条
/// 3. 横屏时避开左右刘海
class SafeAreaDemo extends StatelessWidget {
  const SafeAreaDemo({super.key});

  Widget _phone(String title, Widget child) => Column(
    children: [
      Text(title, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 4),
      Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // 用 MediaQuery 模拟一个有刘海的设备，让效果在任何设备上都可见
    const fakePadding = EdgeInsets.only(top: 40, bottom: 24);
    Widget content() => Container(color: Colors.amber, alignment: Alignment.center, child: const Text('内容'));
    Widget fakeScreen(Widget child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: fakePadding),
      child: Stack(
        children: [
          Container(color: Colors.grey.shade400),
          Positioned.fill(child: child),
          // 模拟刘海（顶部）与手势条（底部）
          Positioned(top: 0, left: 0, right: 0, height: 40, child: Container(color: Colors.black54)),
          Positioned(bottom: 0, left: 0, right: 0, height: 24, child: Container(color: Colors.black54)),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('示例 1：模拟设备上，不用 SafeArea vs 使用 SafeArea'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _phone('无 SafeArea（被遮挡）', fakeScreen(content())),
              _phone('有 SafeArea', fakeScreen(SafeArea(child: content()))),
            ],
          ),
          const _Label('示例 2：只避开顶部（bottom: false）'),
          Center(child: _phone('bottom: false', fakeScreen(SafeArea(bottom: false, child: content())))),
          const _Label('示例 3：minimum 保证最小边距'),
          SafeArea(
            minimum: const EdgeInsets.all(24),
            child: Container(
              height: 60,
              color: Colors.lightGreen,
              alignment: Alignment.center,
              child: const Text('至少 24 的边距'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
