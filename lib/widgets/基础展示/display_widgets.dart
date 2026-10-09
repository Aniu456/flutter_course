import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 基础展示：文本、图标、图片、富文本、分割线、头像、标签。

/// 示例标题：给每个示例加一个小标签
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ===================== Text =====================
///
/// 【是什么】
/// 显示一段单一样式的文字，是最常用的组件。
///
/// 【属性】
/// - data:            要显示的字符串（第一个位置参数）
/// - style:           TextStyle：fontSize 字号、fontWeight 粗细、color 颜色、
///                    fontStyle 斜体、letterSpacing 字间距、height 行高倍数、
///                    decoration 下划线/删除线、shadows 阴影
/// - textAlign:       多行文本的水平对齐（left/center/right/justify）
/// - maxLines:        最大行数，超出部分按 overflow 处理
/// - overflow:        溢出方式：clip 裁剪、ellipsis 省略号、fade 渐隐、visible
/// - softWrap:        是否自动换行，false 时只显示一行
/// - textScaler:      文字缩放（替代已废弃的 textScaleFactor）
/// - semanticsLabel:  无障碍朗读文本
/// - Text.rich:       构造器，使用 TextSpan 做富文本
///
/// 【注意】
/// - textAlign 只在 Text 自身宽度大于文字宽度时才有可见效果，
///   Text 默认是"包裹内容"的，需要外层给宽度（如 SizedBox / Container）
/// - 不设置 maxLines 时 overflow 通常不生效，文字会直接换行
/// - 在 Row 里放长文本要用 Expanded / Flexible 包裹，否则会溢出报错
/// - 未指定 style 时继承 DefaultTextStyle / Theme，可统一管理样式
///
/// 【常见使用场景】
/// 1. 标题、正文、说明文字
/// 2. 列表项标题（单行省略号）
/// 3. 价格（加删除线的原价）
/// 4. 超链接样式文字（下划线 + 颜色）
class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 基础样式 style'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hello Flutter 你好',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple, letterSpacing: 2),
            ),
          ),
          const _Label('2. 斜体 / 下划线 / 删除线'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              children: [
                Text('斜体', style: TextStyle(fontStyle: FontStyle.italic)),
                Text('下划线', style: TextStyle(decoration: TextDecoration.underline)),
                Text(
                  '¥99',
                  style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                ),
              ],
            ),
          ),
          const _Label('3. textAlign（需要有宽度才可见）'),
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            child: const Text('居中对齐 center', textAlign: TextAlign.center),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            color: Colors.amber.shade100,
            child: const Text('右对齐 right', textAlign: TextAlign.right),
          ),
          const _Label('4. maxLines + overflow'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '这是一段很长很长的文字，用来演示 maxLines 与 overflow：'
              '超过两行的部分会被省略号替代，这是列表中非常常见的写法。'
              '这是一段很长很长的文字，用来演示 maxLines 与 overflow。',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const _Label('5. height 行高 + 阴影'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '行高 2.0 的多行文字\n第二行文字',
              style: TextStyle(
                height: 2.0,
                fontSize: 18,
                shadows: [Shadow(color: Colors.black38, offset: Offset(1, 2), blurRadius: 3)],
              ),
            ),
          ),
          const _Label('6. Text.rich 混排'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                text: '价格：',
                children: [
                  TextSpan(
                    text: '¥59',
                    style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' /月'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Icon =====================
///
/// 【是什么】
/// 显示一个来自字体的矢量图标（Material Icons 内置数百个），
/// 可任意缩放、改色，不会失真。
///
/// 【属性】
/// - icon:          IconData，如 Icons.home、Icons.favorite
/// - size:          图标大小，默认 24
/// - color:         图标颜色，默认继承 IconTheme
/// - semanticLabel: 无障碍描述
/// - shadows:       图标阴影
/// - opticalSize / weight / fill / grade: 可变字体图标的细节参数（进阶）
///
/// 【注意】
/// - Icon 本身不可点击，需要点击用 IconButton 或外面包 InkWell / GestureDetector
/// - 多个图标统一样式可用 IconTheme 包裹
/// - 自定义图标字体可用 IconData(codePoint, fontFamily: ...)
/// - 如需彩色图片/位图，请用 Image 而不是 Icon
///
/// 【常见使用场景】
/// 1. 按钮、导航栏、列表项前后的图标
/// 2. 状态提示（成功 ✓ / 错误 ✗ / 警告）
/// 3. 评分星星、收藏心形
class IconDemo extends StatelessWidget {
  const IconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 基础图标（默认 24）'),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.home)),
          const _Label('2. size 与 color'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.favorite, size: 24, color: Colors.red),
                SizedBox(width: 12),
                Icon(Icons.favorite, size: 40, color: Colors.pink),
                SizedBox(width: 12),
                Icon(Icons.favorite, size: 64, color: Colors.purple),
              ],
            ),
          ),
          const _Label('3. 不同含义的图标'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Icon(Icons.error, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Icon(Icons.warning, color: Colors.orange, size: 32),
                SizedBox(width: 12),
                Icon(Icons.info, color: Colors.blue, size: 32),
              ],
            ),
          ),
          const _Label('4. shadows 阴影'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.star,
              size: 48,
              color: Colors.amber,
              shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 3))],
            ),
          ),
          const _Label('5. IconTheme 统一样式'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconThemeData(color: Colors.teal, size: 36),
              child: Row(
                children: [
                  Icon(Icons.wifi),
                  SizedBox(width: 12),
                  Icon(Icons.bluetooth),
                  SizedBox(width: 12),
                  Icon(Icons.battery_full),
                ],
              ),
            ),
          ),
          const _Label('6. 可点击：IconButton'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(icon: const Icon(Icons.thumb_up), color: Colors.blue, onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

/// ===================== Image =====================
///
/// 【是什么】
/// 显示图片。支持资源图(asset)、网络图(network)、文件(file)、内存(memory)。
/// 本示例不依赖网络与资源文件：用 errorBuilder 与 Icon 演示，
/// 并展示 fit 等属性的写法。
///
/// 【属性】
/// - Image.asset(name):      加载项目 assets 图片（需在 pubspec.yaml 声明）
/// - Image.network(url):     加载网络图片
/// - Image.file / .memory:   本地文件 / 内存字节
/// - width / height:         显示尺寸
/// - fit:                    BoxFit：contain 完整显示、cover 铺满裁剪、
///                           fill 拉伸、fitWidth / fitHeight、none、scaleDown
/// - alignment:              图片在区域内的对齐
/// - color + colorBlendMode: 给图片叠色
/// - repeat:                 图片小于区域时是否平铺
/// - loadingBuilder:         网络图加载中的占位
/// - errorBuilder:           加载失败时显示的组件
/// - frameBuilder:           做淡入等过渡动画
/// - cacheWidth/cacheHeight: 解码缩小，节省内存
///
/// 【注意】
/// - 使用 asset 必须在 pubspec.yaml 的 flutter: assets: 中声明并 flutter pub get
/// - 只设置 width 或 height 之一，图片会等比缩放；两者都设且 fit 默认 contain
/// - 网络图在 Android 需要 INTERNET 权限，macOS 需开启网络 entitlement
/// - 圆角图片：用 ClipRRect 包裹，或 Container 的 decoration.image
/// - 始终提供 errorBuilder，避免加载失败时界面难看
///
/// 【常见使用场景】
/// 1. 商品图、Banner、封面
/// 2. 用户头像（配合 ClipOval）
/// 3. 背景图
class ImageDemo extends StatelessWidget {
  const ImageDemo({super.key});

  // 一张故意加载失败的图，用 errorBuilder 展示兜底内容
  Widget _broken({BoxFit? fit, double w = 100, double h = 100}) {
    return Image.asset(
      'assets/not_exist.png',
      width: w,
      height: h,
      fit: fit,
      errorBuilder: (context, error, stack) => Container(
        width: w,
        height: h,
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, color: Colors.grey),
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
          const _Label('1. errorBuilder：图片加载失败时的兜底'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _broken()),
          const _Label('2. 圆角图片：ClipRRect'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _broken()),
          ),
          const _Label('3. 圆形图片：ClipOval'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipOval(child: _broken()),
          ),
          const _Label('4. 用 Container 的 decoration.image 做背景（此处用渐变代替）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.cyan]),
              ),
              child: const Text('背景图位置', style: TextStyle(color: Colors.white)),
            ),
          ),
          const _Label('5. 真实写法（复制到自己的项目使用）'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            width: double.infinity,
            child: const Text(
              "Image.asset('assets/logo.png', width: 100, fit: BoxFit.cover)\n"
              "Image.network('https://example.com/a.jpg',\n"
              "  fit: BoxFit.cover,\n"
              "  loadingBuilder: (c, child, p) => p == null ? child\n"
              "      : const CircularProgressIndicator(),\n"
              "  errorBuilder: (c, e, s) => const Icon(Icons.error))",
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== RichText =====================
///
/// 【是什么】
/// 在同一段文字中混合多种样式（颜色、字号、可点击片段等）。
/// 底层组件是 RichText，日常更推荐 Text.rich（会自动继承主题样式）。
///
/// 【属性】
/// - text:       一个 TextSpan 树
/// - TextSpan:   text 文本、style 样式、children 子片段、
///               recognizer 手势识别（如点击）、mouseCursor
/// - WidgetSpan: 在文字中插入任意组件（图标、徽标等）
/// - textAlign / maxLines / overflow / softWrap: 同 Text
///
/// 【注意】
/// - RichText 不继承 DefaultTextStyle 的颜色，直接使用会是白色/默认黑，
///   需要在根 TextSpan 的 style 里指定；Text.rich 无此问题
/// - recognizer（如 TapGestureRecognizer）需要自己创建并 dispose，
///   因此要点击的片段通常放在 StatefulWidget 里
/// - children 的样式会继承父 TextSpan 的 style
///
/// 【常见使用场景】
/// 1. 协议文案："我已阅读《用户协议》"，其中链接可点击
/// 2. 价格（符号小、数字大）
/// 3. 关键词高亮
/// 4. 文字中插入图标
class RichTextDemo extends StatefulWidget {
  const RichTextDemo({super.key});

  @override
  State<RichTextDemo> createState() => _RichTextDemoState();
}

class _RichTextDemoState extends State<RichTextDemo> {
  // 手势识别器需要手动释放
  late final TapGestureRecognizer _tap;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _tap = TapGestureRecognizer()..onTap = () => setState(() => _count++);
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(color: Colors.black87, fontSize: 16);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 多种样式混排'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: const TextSpan(
                style: base,
                children: [
                  TextSpan(text: '普通 '),
                  TextSpan(
                    text: '加粗红色 ',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '斜体蓝色 ',
                    style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                  ),
                  TextSpan(
                    text: '下划线',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
          const _Label('2. 价格：小符号 + 大数字'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.red),
                children: [
                  TextSpan(text: '¥', style: TextStyle(fontSize: 14)),
                  TextSpan(
                    text: '199',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '.00', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const _Label('3. 可点击的链接片段（recognizer）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                text: '我已阅读并同意',
                children: [
                  TextSpan(
                    text: '《用户协议》',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: _tap,
                  ),
                  TextSpan(text: '（已点击 $_count 次）'),
                ],
              ),
            ),
          ),
          const _Label('4. WidgetSpan：文字中插入组件'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: const TextSpan(
                style: base,
                children: [
                  TextSpan(text: '喜欢 '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                  TextSpan(text: ' Flutter，推荐使用 '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.thumb_up, color: Colors.blue, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const _Label('5. 关键词高亮 + maxLines'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: base,
                children: [
                  const TextSpan(text: '搜索结果：学习 '),
                  TextSpan(
                    text: 'Flutter',
                    style: TextStyle(backgroundColor: Colors.yellow.shade300, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        ' 的第一步是理解 Widget 树，再逐个掌握常用组件，'
                        '最后把它们组合成完整页面。这段文字很长，会被截断。',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Divider =====================
///
/// 【是什么】
/// 一条水平分割线，用来分隔列表项或内容区块。
/// 垂直方向对应 VerticalDivider。
///
/// 【属性】
/// - height:     Divider 占用的总高度（线在中间），不是线的粗细
/// - thickness:  线的粗细
/// - indent:     左侧缩进
/// - endIndent:  右侧缩进
/// - color:      线的颜色
/// - VerticalDivider: 同样有 width / thickness / indent / endIndent / color
///
/// 【注意】
/// - height 是占位高度，想要线粗用 thickness
/// - VerticalDivider 必须有确定高度（放在 Row 里需要用 SizedBox /
///   IntrinsicHeight 限定高度），否则高度 0 看不到线
/// - 在 ListView.separated 里用 Divider 最方便；ListTile 外层可用
///   ListTile.divideTiles
/// - 只想要空白间隔用 SizedBox，想要自定义样式线用 Container(height: 1, color: ...)
///
/// 【常见使用场景】
/// 1. 列表项之间分割
/// 2. 设置页分组
/// 3. 工具栏中的竖线分隔
/// 4. 文字中间带"或"字样的分割线
class DividerDemo extends StatelessWidget {
  const DividerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 默认 Divider'),
          const Text('  上方内容'),
          const Divider(),
          const Text('  下方内容'),
          const _Label('2. height（占位）与 thickness（粗细）'),
          const Divider(height: 40, thickness: 4, color: Colors.deepPurple),
          const _Label('3. indent / endIndent 缩进'),
          const Divider(indent: 40, endIndent: 40, thickness: 2, color: Colors.orange),
          const _Label('4. VerticalDivider（需要限定高度）'),
          const SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('首页'),
                VerticalDivider(width: 32, thickness: 1, color: Colors.grey),
                Text('分类'),
                VerticalDivider(width: 32, thickness: 1, color: Colors.grey),
                Text('我的'),
              ],
            ),
          ),
          const _Label('5. 带文字的分割线'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('或', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ),
          const _Label('6. 列表中使用 ListTile.divideTiles'),
          ...ListTile.divideTiles(
            context: context,
            tiles: const [
              ListTile(leading: Icon(Icons.wifi), title: Text('无线局域网')),
              ListTile(leading: Icon(Icons.bluetooth), title: Text('蓝牙')),
              ListTile(leading: Icon(Icons.battery_full), title: Text('电池')),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===================== CircleAvatar =====================
///
/// 【是什么】
/// 圆形头像组件，可显示图片、文字或图标。
///
/// 【属性】
/// - radius:            半径（直径 = 2 * radius），默认 20
/// - minRadius/maxRadius: 在约束下的最小/最大半径
/// - backgroundColor:   背景色
/// - foregroundColor:   文字/图标颜色
/// - backgroundImage:   背景图（ImageProvider，如 NetworkImage / AssetImage）
/// - foregroundImage:   前景图，加载成功才显示，失败时露出 child/背景
/// - onBackgroundImageError / onForegroundImageError: 图片加载失败回调
/// - child:             通常是 Text(首字母) 或 Icon
///
/// 【注意】
/// - 用 radius 控制大小，不要用 width/height
/// - backgroundImage 加载失败时需要提供 onBackgroundImageError，否则抛异常
/// - 想要带边框：外面套一层 CircleAvatar（边框色）再套一层小的
/// - 非圆形头像用 ClipRRect + Image，或 Container + BoxDecoration
///
/// 【常见使用场景】
/// 1. 用户头像 / 联系人列表
/// 2. 无头像时显示姓名首字母
/// 3. 头像右下角带在线状态
/// 4. 重叠头像组（群成员）
class CircleAvatarDemo extends StatelessWidget {
  const CircleAvatarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 文字头像'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(backgroundColor: Colors.indigo, foregroundColor: Colors.white, child: Text('张')),
          ),
          const _Label('2. 不同 radius'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(radius: 16, child: Text('S')),
                SizedBox(width: 12),
                CircleAvatar(radius: 28, child: Text('M')),
                SizedBox(width: 12),
                CircleAvatar(radius: 40, child: Text('L')),
              ],
            ),
          ),
          const _Label('3. 图标头像'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ),
          const _Label('4. 图片加载失败时回退到 child'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.shade200,
              foregroundImage: const AssetImage('assets/not_exist.png'),
              onForegroundImageError: (e, s) {},
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          const _Label('5. 带边框'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.pets, color: Colors.red, size: 32),
              ),
            ),
          ),
          const _Label('6. 右下角在线状态（Stack）'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white, size: 36),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const _Label('7. 重叠头像组'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              width: 48 + 3 * 30,
              child: Stack(
                children: [
                  for (var i = 0; i < 4; i++)
                    Positioned(
                      left: i * 30.0,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 21,
                          backgroundColor: Colors.primaries[i * 3],
                          child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Chip =====================
///
/// 【是什么】
/// 紧凑的"标签/小胶囊"组件，用于展示标签、筛选条件、联系人等。
/// 家族成员：Chip(展示)、InputChip(可删除/输入)、ChoiceChip(单选)、
/// FilterChip(多选筛选)、ActionChip(点击动作)。
///
/// 【属性】
/// - label:            标签内容（必填，通常是 Text）
/// - avatar:           左侧头像/图标
/// - deleteIcon:       自定义删除图标
/// - onDeleted:        设置后才显示删除图标，并响应点击
/// - backgroundColor:  背景色
/// - labelStyle:       文字样式
/// - side:             边框
/// - shape:            形状（默认胶囊形）
/// - padding / labelPadding: 内边距
/// - elevation:        阴影
/// - ChoiceChip / FilterChip: selected 是否选中、onSelected 回调、selectedColor
/// - ActionChip:       onPressed 点击回调
///
/// 【注意】
/// - 选中状态要自己用 setState 维护，所以演示用 StatefulWidget
/// - 大量 Chip 横向排列用 Wrap（会自动换行），不要用 Row（会溢出）
/// - Material 3 下 Chip 的默认外观与 M2 不同，必要时用 side / shape 调整
/// - 按钮样式的操作用 ElevatedButton 等，Chip 更适合表示"属性/标签"
///
/// 【常见使用场景】
/// 1. 文章标签、商品属性
/// 2. 搜索筛选条件（FilterChip）
/// 3. 单选分类（ChoiceChip）
/// 4. 邮件收件人（可删除的 InputChip）
class ChipDemo extends StatefulWidget {
  const ChipDemo({super.key});

  @override
  State<ChipDemo> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<ChipDemo> {
  final List<String> _tags = ['Flutter', 'Dart', 'Widget', 'Riverpod'];
  int _choice = 0;
  final Set<String> _filters = {'Dart'};
  int _actionCount = 0;

  @override
  Widget build(BuildContext context) {
    const options = ['全部', '热门', '最新'];
    const filterOptions = ['Flutter', 'Dart', 'Kotlin', 'Swift'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 基础 Chip + avatar'),
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('标签')),
              Chip(
                avatar: CircleAvatar(child: Text('A')),
                label: Text('带头像'),
              ),
              Chip(
                avatar: Icon(Icons.star, color: Colors.amber),
                label: Text('带图标'),
              ),
            ],
          ),
          const _Label('2. 自定义颜色 / 边框 / 形状'),
          Wrap(
            spacing: 8,
            children: [
              const Chip(
                label: Text('红底白字', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
              Chip(
                label: const Text('描边'),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.teal),
              ),
              Chip(
                label: const Text('小圆角'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
          const _Label('3. 可删除（点击 × 删除）'),
          Wrap(
            spacing: 8,
            children: [for (final t in _tags) Chip(label: Text(t), onDeleted: () => setState(() => _tags.remove(t)))],
          ),
          if (_tags.length < 4)
            TextButton(
              onPressed: () => setState(
                () => _tags
                  ..clear()
                  ..addAll(['Flutter', 'Dart', 'Widget', 'Riverpod']),
              ),
              child: const Text('重置标签'),
            ),
          const _Label('4. ChoiceChip 单选'),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < options.length; i++)
                ChoiceChip(
                  label: Text(options[i]),
                  selected: _choice == i,
                  onSelected: (_) => setState(() => _choice = i),
                ),
            ],
          ),
          const _Label('5. FilterChip 多选'),
          Wrap(
            spacing: 8,
            children: [
              for (final f in filterOptions)
                FilterChip(
                  label: Text(f),
                  selected: _filters.contains(f),
                  onSelected: (v) => setState(() {
                    v ? _filters.add(f) : _filters.remove(f);
                  }),
                ),
            ],
          ),
          const _Label('6. ActionChip 点击动作'),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text('点击计数：$_actionCount'),
            onPressed: () => setState(() => _actionCount++),
          ),
        ],
      ),
    );
  }
}
