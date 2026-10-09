import 'package:flutter/material.dart';

// 按钮：Material 3 中的各种常用按钮。

/// 统一的小标题，演示用
Widget _label(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
  child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
);

/// ===================== ElevatedButton =====================
///
/// 【是什么】
/// 带阴影（凸起）的填充按钮，用于页面中最主要、最需要强调的操作。
///
/// 【属性】
/// - onPressed:    点击回调；设为 null 时按钮变为禁用（灰色）状态
/// - onLongPress:  长按回调
/// - child:        按钮内容，通常是 Text
/// - style:        ButtonStyle，推荐用 ElevatedButton.styleFrom(...) 构建：
///                 backgroundColor 背景色、foregroundColor 文字/图标色、
///                 elevation 阴影、padding 内边距、minimumSize 最小尺寸、
///                 shape 形状（如 RoundedRectangleBorder / StadiumBorder）、
///                 side 边框、textStyle 文字样式
/// - focusNode / autofocus: 焦点相关
/// - clipBehavior: 内容裁剪方式
/// - ElevatedButton.icon: 命名构造，额外提供 icon 参数，图标在文字左侧
///
/// 【注意】
/// - onPressed 和 onLongPress 都为 null 才会禁用
/// - 按钮默认有最小尺寸（约 64x40），想更小需设置 minimumSize
/// - 想让按钮占满宽度：用 SizedBox(width: double.infinity, ...) 包裹
/// - 样式想随状态变化（按下、禁用）用 ButtonStyle 的 WidgetStateProperty
/// - 重要程度从高到低：FilledButton > ElevatedButton > OutlinedButton > TextButton
///
/// 【常见使用场景】
/// 1. 提交表单、登录、确认
/// 2. 页面主操作（立即购买）
/// 3. 带图标的操作按钮
class ElevatedButtonDemo extends StatefulWidget {
  const ElevatedButtonDemo({super.key});

  @override
  State<ElevatedButtonDemo> createState() => _ElevatedButtonDemoState();
}

class _ElevatedButtonDemoState extends State<ElevatedButtonDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础：点击计数 $_count'),
          ElevatedButton(onPressed: () => setState(() => _count++), child: const Text('点我 +1')),
          _label('2. 禁用（onPressed: null）'),
          const ElevatedButton(onPressed: null, child: Text('禁用')),
          _label('3. 自定义颜色 / 圆角 / 阴影'),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('橙色圆角'),
          ),
          _label('4. 胶囊形 StadiumBorder'),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            child: const Text('胶囊按钮'),
          ),
          _label('5. 带图标 ElevatedButton.icon'),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.send), label: const Text('发送')),
          _label('6. 占满宽度 + 长按'),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('长按触发'))),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('登录（长按试试）'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== TextButton =====================
///
/// 【是什么】
/// 无背景、无阴影的文字按钮，视觉最轻，用于次要操作。
///
/// 【属性】
/// - onPressed / onLongPress: 点击 / 长按回调，onPressed 为 null 时禁用
/// - child:        按钮内容
/// - style:        TextButton.styleFrom(...)：foregroundColor 文字色、
///                 backgroundColor 背景色、padding、textStyle、
///                 shape、overlayColor 按下水波纹颜色、minimumSize
/// - TextButton.icon: 带图标的版本
///
/// 【注意】
/// - 点击区域默认较小，注意最小触控尺寸（约 48dp）
/// - 想要"链接"的感觉，可把 textStyle 设置 decoration: underline
/// - 对话框、卡片底部的操作区常用 TextButton
///
/// 【常见使用场景】
/// 1. 对话框的"取消 / 确定"
/// 2. 忘记密码、查看更多等链接式操作
/// 3. 工具栏、卡片内的次要操作
class TextButtonDemo extends StatelessWidget {
  const TextButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础'),
          TextButton(onPressed: () {}, child: const Text('文字按钮')),
          _label('2. 禁用'),
          const TextButton(onPressed: null, child: Text('禁用')),
          _label('3. 自定义文字色与背景'),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.teal),
            child: const Text('有背景的 TextButton'),
          ),
          _label('4. 带图标'),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite_border), label: const Text('收藏')),
          _label('5. 链接样式（下划线）'),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              textStyle: const TextStyle(decoration: TextDecoration.underline),
            ),
            child: const Text('忘记密码？'),
          ),
          _label('6. 在对话框中使用'),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('提示'),
                content: const Text('确定要删除吗？'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定')),
                ],
              ),
            ),
            child: const Text('打开对话框'),
          ),
        ],
      ),
    );
  }
}

/// ===================== OutlinedButton =====================
///
/// 【是什么】
/// 带边框、透明背景的按钮，强调程度介于 ElevatedButton 与 TextButton 之间。
///
/// 【属性】
/// - onPressed / onLongPress: 回调，onPressed 为 null 时禁用
/// - child:        按钮内容
/// - style:        OutlinedButton.styleFrom(...)：
///                 side 边框（BorderSide：颜色/宽度）、shape 形状、
///                 foregroundColor 文字与水波纹色、backgroundColor 背景色、
///                 padding、minimumSize
/// - OutlinedButton.icon: 带图标版本
///
/// 【注意】
/// - 边框用 side 设置，而不是 border
/// - 想让边框随状态变化，用 WidgetStateProperty.resolveWith
/// - 常与 ElevatedButton 并排：主操作用实心、次操作用 Outlined
///
/// 【常见使用场景】
/// 1. "取消 / 返回"等次要但需要明显的按钮
/// 2. 与主按钮并列的备选操作
/// 3. 筛选标签、选项类按钮
class OutlinedButtonDemo extends StatelessWidget {
  const OutlinedButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础'),
          OutlinedButton(onPressed: () {}, child: const Text('描边按钮')),
          _label('2. 禁用'),
          const OutlinedButton(onPressed: null, child: Text('禁用')),
          _label('3. 自定义边框颜色/宽度'),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
            ),
            child: const Text('红色粗边框'),
          ),
          _label('4. 胶囊形'),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
            child: const Text('胶囊'),
          ),
          _label('5. 带图标'),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('下载')),
          _label('6. 与主按钮并排'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () {}, child: const Text('取消')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(onPressed: () {}, child: const Text('确定')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===================== IconButton =====================
///
/// 【是什么】
/// 只显示图标的点击按钮，常用于 AppBar、工具栏。
/// Material 3 提供 4 种变体：标准、filled、filledTonal、outlined。
///
/// 【属性】
/// - icon:         图标组件（必填），通常 Icon(Icons.xxx)
/// - onPressed:    点击回调，null 时禁用
/// - iconSize:     图标大小，默认 24
/// - color:        图标颜色
/// - tooltip:      长按/悬停时的文字提示（也利于无障碍，建议总是设置）
/// - isSelected / selectedIcon: 切换（选中）状态及选中时显示的图标
/// - style:        IconButton.styleFrom(...)：backgroundColor、shape 等
/// - padding:      内边距，默认 8
/// - IconButton.filled / filledTonal / outlined: 三种带背景的变体
///
/// 【注意】
/// - 点击区域默认 48x48，即使图标很小
/// - 做"切换"效果要自己维护状态：isSelected + setState
/// - 没有文字，务必加 tooltip
///
/// 【常见使用场景】
/// 1. AppBar 的 actions（搜索、更多）
/// 2. 点赞 / 收藏等可切换图标
/// 3. 输入框前后缀的小按钮
class IconButtonDemo extends StatefulWidget {
  const IconButtonDemo({super.key});

  @override
  State<IconButtonDemo> createState() => _IconButtonDemoState();
}

class _IconButtonDemoState extends State<IconButtonDemo> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础 + tooltip（长按可见提示）'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search), tooltip: '搜索'),
          _label('2. 大小与颜色'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.home), iconSize: 40, color: Colors.green),
          _label('3. 禁用'),
          const IconButton(onPressed: null, icon: Icon(Icons.delete)),
          _label('4. 切换状态（isSelected + selectedIcon）'),
          IconButton(
            isSelected: _liked,
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => setState(() => _liked = !_liked),
            tooltip: '点赞',
          ),
          _label('5. 三种 Material 3 变体'),
          Row(
            children: [
              IconButton.filled(onPressed: () {}, icon: const Icon(Icons.add)),
              const SizedBox(width: 8),
              IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.add)),
              const SizedBox(width: 8),
              IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.add)),
            ],
          ),
          _label('6. 自定义背景与形状'),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== FloatingActionButton =====================
///
/// 【是什么】
/// 悬浮操作按钮（FAB），浮在页面内容之上，代表当前页面最主要的操作。
/// 通常通过 Scaffold.floatingActionButton 放置，默认在右下角。
///
/// 【属性】
/// - onPressed:    点击回调
/// - child:        图标，通常 Icon
/// - tooltip:      提示文字
/// - backgroundColor / foregroundColor: 背景色 / 图标色
/// - elevation:    阴影高度
/// - shape:        形状，默认圆角矩形（M3），可设为 CircleBorder()
/// - mini:         是否使用小尺寸（40）
/// - heroTag:      Hero 动画标识；同一页面有多个 FAB 时必须设置不同值或 null
/// - FloatingActionButton.small / large / extended：
///                 小号 / 大号 / 带文字的扩展版（label + icon）
/// - Scaffold.floatingActionButtonLocation: 控制位置（centerFloat、endFloat 等）
///
/// 【注意】
/// - 一个页面最好只有一个 FAB
/// - 直接放在普通 Widget 里不会自动定位，需使用 Scaffold 或 Stack + Positioned
/// - 多个 FAB 同屏会因 heroTag 冲突报错
///
/// 【常见使用场景】
/// 1. 新建 / 添加（新增笔记、发布）
/// 2. 回到顶部
/// 3. 拍照、撰写消息
class FloatingActionButtonDemo extends StatefulWidget {
  const FloatingActionButtonDemo({super.key});

  @override
  State<FloatingActionButtonDemo> createState() => _FloatingActionButtonDemoState();
}

class _FloatingActionButtonDemoState extends State<FloatingActionButtonDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // FAB 要定位在页面角落，所以这里用 Stack + Positioned 模拟；
    // 在真实页面中直接使用 Scaffold(floatingActionButton: ...) 即可。
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('点击次数：$_count（右下角的 FAB 会 +1）'),
              _label('1. 标准 FAB'),
              FloatingActionButton(
                heroTag: 'fab1',
                onPressed: () => setState(() => _count++),
                tooltip: '加一',
                child: const Icon(Icons.add),
              ),
              _label('2. small / large'),
              Row(
                children: [
                  FloatingActionButton.small(heroTag: 'fab2', onPressed: () {}, child: const Icon(Icons.edit)),
                  const SizedBox(width: 16),
                  FloatingActionButton.large(heroTag: 'fab3', onPressed: () {}, child: const Icon(Icons.camera_alt)),
                ],
              ),
              _label('3. 圆形 + 自定义颜色'),
              FloatingActionButton(
                heroTag: 'fab4',
                onPressed: () {},
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.favorite),
              ),
              _label('4. 扩展 FAB（图标 + 文字）'),
              FloatingActionButton.extended(
                heroTag: 'fab5',
                onPressed: () {},
                icon: const Icon(Icons.navigation),
                label: const Text('开始导航'),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'fab-corner',
            onPressed: () => setState(() => _count++),
            child: const Icon(Icons.plus_one),
          ),
        ),
      ],
    );
  }
}
