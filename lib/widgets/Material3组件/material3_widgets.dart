import 'package:flutter/material.dart';

// Material 3 组件：NavigationBar / NavigationRail / SegmentedButton / SearchBar / Badge。
// Flutter 3.16 起 useMaterial3 默认为 true，这些是 M3 推荐的新组件。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

const _destinations = [
  ('首页', Icons.home_outlined, Icons.home),
  ('发现', Icons.explore_outlined, Icons.explore),
  ('消息', Icons.chat_bubble_outline, Icons.chat_bubble),
  ('我的', Icons.person_outline, Icons.person),
];

/// ===================== NavigationBar =====================
///
/// 【是什么】
/// Material 3 的底部导航栏，用来替代 BottomNavigationBar：
/// 更高、选中项带"药丸"形指示器，适合 3~5 个顶级页面。
///
/// 【属性】
/// - destinations: `List<NavigationDestination>(icon, selectedIcon, label)`
/// - selectedIndex: 当前选中下标
/// - onDestinationSelected: 点击回调，在里面 setState 更新下标
/// - labelBehavior: 文字显示方式（总是 / 仅选中 / 从不）
/// - indicatorColor / backgroundColor / height: 外观
///
/// 【注意】
/// - 放在 Scaffold.bottomNavigationBar 位置
/// - 切换页面想保留各页状态，body 用 IndexedStack
/// - 宽屏（平板 / 桌面）建议换成 NavigationRail
///
/// 【常见使用场景】
/// App 主框架的底部 Tab
class NavigationBarDemo extends StatefulWidget {
  const NavigationBarDemo({super.key});

  @override
  State<NavigationBarDemo> createState() => _NavigationBarDemoState();
}

class _NavigationBarDemoState extends State<NavigationBarDemo> {
  int _index = 0;
  NavigationDestinationLabelBehavior _labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_destinations[_index].$3, size: 72),
            Text('当前页面：${_destinations[_index].$1}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            const Text('labelBehavior'),
            const SizedBox(height: 8),
            SegmentedButton<NavigationDestinationLabelBehavior>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: NavigationDestinationLabelBehavior.alwaysShow, label: Text('总是')),
                ButtonSegment(value: NavigationDestinationLabelBehavior.onlyShowSelected, label: Text('仅选中')),
                ButtonSegment(value: NavigationDestinationLabelBehavior.alwaysHide, label: Text('隐藏')),
              ],
              selected: {_labelBehavior},
              onSelectionChanged: (s) => setState(() => _labelBehavior = s.first),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        labelBehavior: _labelBehavior,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final (i, (label, icon, selected)) in _destinations.indexed)
            NavigationDestination(
              icon: i == 2 ? Badge.count(count: 3, child: Icon(icon)) : Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}

/// ===================== NavigationRail =====================
///
/// 【是什么】
/// 竖向的侧边导航栏，适合平板、桌面等宽屏布局；功能等同于 NavigationBar。
///
/// 【属性】
/// - destinations: `List<NavigationRailDestination>(icon, selectedIcon, label)`
/// - selectedIndex / onDestinationSelected: 选中状态与回调
/// - extended: 是否展开（图标 + 文字横排）
/// - labelType: 未展开时文字显示方式（none / selected / all）
/// - leading / trailing: 顶部（如 FAB）、底部附加组件
/// - minWidth / minExtendedWidth / groupAlignment: 尺寸与对齐
///
/// 【注意】
/// - 通常放在 Row 里，右侧用 Expanded 放内容，中间加 VerticalDivider
/// - extended 为 true 时 labelType 必须是 none
/// - 结合 LayoutBuilder：窄屏用 NavigationBar，宽屏用 NavigationRail（响应式布局）
///
/// 【常见使用场景】
/// 平板 / 桌面 / Web 的主导航，邮件客户端、管理后台
class NavigationRailDemo extends StatefulWidget {
  const NavigationRailDemo({super.key});

  @override
  State<NavigationRailDemo> createState() => _NavigationRailDemoState();
}

class _NavigationRailDemoState extends State<NavigationRailDemo> {
  int _index = 0;
  bool _extended = false;
  NavigationRailLabelType _labelType = NavigationRailLabelType.all;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _index,
          extended: _extended,
          labelType: _extended ? NavigationRailLabelType.none : _labelType,
          onDestinationSelected: (i) => setState(() => _index = i),
          leading: FloatingActionButton.small(onPressed: () {}, elevation: 0, child: const Icon(Icons.edit)),
          destinations: [
            for (final (label, icon, selected) in _destinations)
              NavigationRailDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: Text(label)),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('当前：${_destinations[_index].$1}', style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('extended（展开）'),
                value: _extended,
                onChanged: (v) => setState(() => _extended = v),
              ),
              const Text('labelType（未展开时生效）'),
              const SizedBox(height: 8),
              // 窄屏下展开 Rail 后空间很小，用 FittedBox 等比缩小避免溢出
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SegmentedButton<NavigationRailLabelType>(
                  showSelectedIcon: false,
                  segments: [
                    for (final type in NavigationRailLabelType.values)
                      ButtonSegment(value: type, label: Text(type.name), enabled: !_extended),
                  ],
                  selected: {_labelType},
                  onSelectionChanged: (s) => setState(() => _labelType = s.first),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Size { s, m, l, xl }

enum _Topping { cheese, ham, mushroom, pepper }

/// ===================== SegmentedButton =====================
///
/// 【是什么】
/// Material 3 的分段按钮：一组相连的选项，支持单选或多选，
/// 替代以前的 ToggleButtons。
///
/// 【属性】
/// - segments: `List<ButtonSegment<T>>(value, label, icon, enabled)`
/// - selected: `Set<T>`，当前选中的值（单选时只有一个元素）
/// - onSelectionChanged: 选择变化回调，参数是新的 `Set<T>`
/// - multiSelectionEnabled: 是否允许多选，默认 false
/// - emptySelectionAllowed: 是否允许一个都不选，默认 false
/// - showSelectedIcon: 选中项是否显示对勾
/// - style: SegmentedButton.styleFrom(...) 自定义样式
///
/// 【注意】
/// - selected 是 Set，单选时取 newSelection.first
/// - 选项过多（超过 5 个）或文字较长时，改用 DropdownMenu / ChoiceChip
///
/// 【常见使用场景】
/// 视图切换（列表 / 网格）、筛选条件、尺寸 / 规格选择
class SegmentedButtonDemo extends StatefulWidget {
  const SegmentedButtonDemo({super.key});

  @override
  State<SegmentedButtonDemo> createState() => _SegmentedButtonDemoState();
}

class _SegmentedButtonDemoState extends State<SegmentedButtonDemo> {
  bool _grid = false;
  _Size _size = _Size.m;
  Set<_Topping> _toppings = {_Topping.cheese};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 单选 + 图标：视图切换'),
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('列表'), icon: Icon(Icons.view_list)),
              ButtonSegment(value: true, label: Text('网格'), icon: Icon(Icons.grid_view)),
            ],
            selected: {_grid},
            onSelectionChanged: (s) => setState(() => _grid = s.first),
          ),
        ),
        _title('2. 单选：尺寸（XL 禁用）'),
        Center(
          child: SegmentedButton<_Size>(
            segments: const [
              ButtonSegment(value: _Size.s, label: Text('S')),
              ButtonSegment(value: _Size.m, label: Text('M')),
              ButtonSegment(value: _Size.l, label: Text('L')),
              ButtonSegment(value: _Size.xl, label: Text('XL'), enabled: false),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
        ),
        _title('3. 多选 + 允许全不选：披萨配料'),
        Center(
          child: SegmentedButton<_Topping>(
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            segments: const [
              ButtonSegment(value: _Topping.cheese, label: Text('芝士')),
              ButtonSegment(value: _Topping.ham, label: Text('火腿')),
              ButtonSegment(value: _Topping.mushroom, label: Text('蘑菇')),
              ButtonSegment(value: _Topping.pepper, label: Text('青椒')),
            ],
            selected: _toppings,
            onSelectionChanged: (s) => setState(() => _toppings = s),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '结果：${_grid ? '网格' : '列表'}视图，尺寸 ${_size.name.toUpperCase()}，'
            '配料 ${_toppings.isEmpty ? '无' : _toppings.map((t) => t.name).join(', ')}',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// ===================== SearchBar / SearchAnchor =====================
///
/// 【是什么】
/// - SearchBar：Material 3 的胶囊形搜索输入框，本身就是一个特殊的输入框
/// - SearchAnchor：点击后展开全屏 / 浮层的"搜索视图"，展示建议列表
///
/// 【SearchBar 属性】
/// - controller / hintText / leading / trailing
/// - onChanged / onSubmitted / onTap
/// - elevation / backgroundColor / shape / padding: 外观
///
/// 【SearchAnchor 用法】
/// - SearchAnchor.bar(suggestionsBuilder: (context, controller) => [...])：
///   直接得到一个"点击即展开"的搜索栏
/// - 选中建议后调用 controller.closeView(text) 关闭搜索视图
///
/// 【注意】
/// - 建议列表很长时 suggestionsBuilder 可以返回异步结果（`Future<Iterable<Widget>>`）
/// - 需要防抖时自己用 Timer 处理 onChanged
///
/// 【常见使用场景】
/// 应用内搜索、筛选列表、带历史记录的搜索页
class SearchBarDemo extends StatefulWidget {
  const SearchBarDemo({super.key});

  @override
  State<SearchBarDemo> createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<SearchBarDemo> {
  static const _all = [
    'Container',
    'Row',
    'Column',
    'Stack',
    'ListView',
    'GridView',
    'Text',
    'Image',
    'Icon',
    'Card',
    'NavigationBar',
    'SegmentedButton',
    'SearchBar',
    'Badge',
    'AnimatedList',
    'Hero',
    'Table',
    'Wrap',
  ];

  String _query = '';
  String _picked = '（未选择）';

  @override
  Widget build(BuildContext context) {
    final filtered = _all.where((e) => e.toLowerCase().contains(_query.toLowerCase())).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. SearchAnchor.bar：点击展开搜索视图，选择建议'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchAnchor.bar(
            barHintText: '搜索组件',
            suggestionsBuilder: (context, controller) {
              final q = controller.text.toLowerCase();
              return _all
                  .where((e) => e.toLowerCase().contains(q))
                  .map(
                    (e) => ListTile(
                      leading: const Icon(Icons.widgets_outlined),
                      title: Text(e),
                      onTap: () {
                        controller.closeView(e);
                        setState(() => _picked = e);
                      },
                    ),
                  );
            },
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Text('选中：$_picked')),
        _title('2. SearchBar：边输入边过滤下方列表'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBar(
            hintText: '过滤组件名',
            leading: const Icon(Icons.search),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(onPressed: () => setState(() => _query = ''), icon: const Icon(Icons.clear)),
            ],
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: filtered.isEmpty
              ? const Text('没有匹配的组件')
              : Wrap(spacing: 8, runSpacing: 8, children: [for (final e in filtered) Chip(label: Text(e))]),
        ),
      ],
    );
  }
}

/// ===================== Badge =====================
///
/// 【是什么】
/// Material 3 的徽章（角标 / 小红点），叠加在图标等组件的右上角。
///
/// 【属性】
/// - label: 徽章内容；不设置时显示为小圆点
/// - Badge.count(count: n)：显示数字，超过 maxCount（默认 999）显示 999+
/// - isLabelVisible: 是否显示徽章（为 0 时通常隐藏）
/// - backgroundColor / textColor: 颜色
/// - offset / alignment: 位置微调
/// - smallSize / largeSize: 小圆点 / 带文字时的尺寸
///
/// 【注意】
/// - Badge 不改变 child 的布局尺寸，只是画在上面
/// - 早期常用第三方 badges 包，现在官方 Badge 已足够
///
/// 【常见使用场景】
/// 未读消息数、购物车数量、新功能小红点
class BadgeDemo extends StatefulWidget {
  const BadgeDemo({super.key});

  @override
  State<BadgeDemo> createState() => _BadgeDemoState();
}

class _BadgeDemoState extends State<BadgeDemo> {
  int _count = 5;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 小红点 / 文字 / 数字'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Badge(child: Icon(Icons.notifications, size: 32)),
            const Badge(label: Text('NEW'), child: Icon(Icons.local_offer, size: 32)),
            Badge.count(count: _count, isLabelVisible: _count > 0, child: const Icon(Icons.mail, size: 32)),
            Badge.count(count: 1234, child: const Icon(Icons.chat, size: 32)),
          ],
        ),
        _title('2. isLabelVisible：数量为 0 时自动隐藏'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: _count > 0 ? () => setState(() => _count--) : null, icon: const Icon(Icons.remove)),
            Badge.count(count: _count, isLabelVisible: _count > 0, child: const Icon(Icons.shopping_cart, size: 40)),
            IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add)),
          ],
        ),
        _title('3. 自定义颜色与位置'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Badge(
              backgroundColor: Colors.green,
              label: const Text('在线'),
              offset: const Offset(8, -4),
              child: const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            ),
            const Badge(
              alignment: Alignment.bottomRight,
              smallSize: 12,
              backgroundColor: Colors.orange,
              child: CircleAvatar(radius: 24, child: Text('A')),
            ),
          ],
        ),
      ],
    );
  }
}
