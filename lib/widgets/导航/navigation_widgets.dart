import 'package:flutter/material.dart';

// 导航：Scaffold / AppBar / BottomNavigationBar / TabBar / Drawer / Navigator

Widget _label(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
);

Widget _frame(Widget child, {double height = 260}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    height: height,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  ),
);

/// ===================== Scaffold =====================
///
/// 【是什么】
/// Scaffold 是 Material 风格页面的"骨架"，提供 AppBar、body、
/// 底部导航栏、抽屉、悬浮按钮等标准位置，一个页面通常对应一个 Scaffold。
///
/// 【属性】
/// - appBar:                  顶部应用栏（通常是 AppBar）
/// - body:                    页面主体内容
/// - floatingActionButton:    悬浮按钮（FAB）
/// - floatingActionButtonLocation: FAB 位置，如 centerFloat、endFloat
/// - drawer / endDrawer:      左侧 / 右侧抽屉
/// - bottomNavigationBar:     底部导航栏
/// - bottomSheet:             常驻底部面板
/// - backgroundColor:         页面背景色
/// - resizeToAvoidBottomInset: 键盘弹出时是否缩小 body，默认 true
/// - extendBody / extendBodyBehindAppBar: body 是否延伸到底栏 / AppBar 之下
///
/// 【注意】
/// - body 会被给予"紧约束"，直接放 Container 设置宽高会被忽略，需用 Center/Align 包裹
/// - body 内容较高时请用 SingleChildScrollView / ListView，避免溢出
/// - Scaffold.of(context) 需要拿到 Scaffold 下面的 context（用 Builder）
/// - 键盘遮挡输入框时可设 resizeToAvoidBottomInset 或让内容可滚动
///
/// 【常见使用场景】
/// 1. 每个页面的最外层骨架
/// 2. 带悬浮"添加"按钮的列表页
/// 3. 带底部 Tab 的主页
/// 4. 带侧边栏的页面
class ScaffoldDemo extends StatelessWidget {
  const ScaffoldDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('示例 1：appBar + body + FAB（居中悬浮）'),
          _frame(
            Scaffold(
              appBar: AppBar(title: const Text('标题')),
              body: const Center(child: Text('body 主体')),
              floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            ),
          ),
          _label('示例 2：自定义背景色 + 底部栏 + 右侧抽屉按钮'),
          _frame(
            Scaffold(
              backgroundColor: Colors.amber.shade50,
              appBar: AppBar(
                title: const Text('带抽屉'),
                // 隐藏默认的 endDrawer 图标，改用自己的按钮
                actions: [
                  Builder(
                    builder: (ctx) =>
                        IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openEndDrawer()),
                  ),
                ],
              ),
              endDrawer: const Drawer(child: Center(child: Text('右侧抽屉'))),
              body: const Center(child: Text('点右上角打开 endDrawer')),
              bottomNavigationBar: const BottomAppBar(height: 48, child: Center(child: Text('bottomNavigationBar'))),
            ),
          ),
          _label('示例 3：body 被紧约束，需用 Align 放松'),
          _frame(
            Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: Container(width: 100, height: 60, color: Colors.teal),
              ),
            ),
            height: 100,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== AppBar =====================
///
/// 【是什么】
/// AppBar 是页面顶部的应用栏，通常放标题、返回按钮、操作菜单，
/// 作为 Scaffold.appBar 使用。
///
/// 【属性】
/// - title:            标题组件
/// - leading:          左侧组件（默认自动返回键/抽屉键）
/// - actions:          右侧操作按钮列表
/// - centerTitle:      标题是否居中
/// - backgroundColor / foregroundColor: 背景色 / 文字图标颜色
/// - elevation:        阴影高度
/// - automaticallyImplyLeading: 是否自动生成 leading
/// - bottom:           底部区域，常放 TabBar（PreferredSizeWidget）
/// - flexibleSpace:    背景层，可放渐变
/// - toolbarHeight:    工具栏高度
/// - shape:            形状，如圆角底边
///
/// 【注意】
/// - appBar 需要实现 PreferredSizeWidget，普通 Container 不能直接用，
///   可用 PreferredSize 包裹自定义组件
/// - 页面可滚动折叠时使用 SliverAppBar
/// - actions 过多时用 PopupMenuButton 收纳
///
/// 【常见使用场景】
/// 1. 页面标题 + 返回键
/// 2. 右上角搜索 / 更多菜单
/// 3. 带 Tab 的顶栏
/// 4. 渐变色、自定义高度的顶栏
class AppBarDemo extends StatelessWidget {
  const AppBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('示例 1：title + leading + actions'),
          AppBar(
            leading: const Icon(Icons.arrow_back),
            title: const Text('文章详情'),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),
          _label('示例 2：centerTitle + 颜色 + 阴影'),
          AppBar(
            title: const Text('居中标题'),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 6,
          ),
          _label('示例 3：flexibleSpace 渐变背景'),
          AppBar(
            title: const Text('渐变'),
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.pink])),
            ),
          ),
          _label('示例 4：PopupMenuButton 菜单 + 自定义高度 + 圆角'),
          AppBar(
            toolbarHeight: 72,
            title: const Text('更多菜单'),
            backgroundColor: Colors.teal.shade100,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('选择了 $v'))),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: '设置', child: Text('设置')),
                  PopupMenuItem(value: '关于', child: Text('关于')),
                ],
              ),
            ],
          ),
          _label('示例 5：bottom 放 TabBar'),
          SizedBox(
            height: kToolbarHeight + kTextTabBarHeight,
            child: DefaultTabController(
              length: 2,
              child: AppBar(
                title: const Text('带 Tab'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: '推荐'),
                    Tab(text: '关注'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== BottomNavigationBar =====================
///
/// 【是什么】
/// 底部导航栏，用于在 3~5 个顶级页面之间切换。
///
/// 【属性】
/// - items:               BottomNavigationBarItem 列表（icon、label，至少 2 项）
/// - currentIndex:        当前选中项
/// - onTap:               点击回调，需自己 setState 更新 currentIndex
/// - type:                fixed（固定）/ shifting（选中放大带动画）
/// - selectedItemColor / unselectedItemColor: 选中/未选中颜色
/// - backgroundColor:     背景色
/// - showSelectedLabels / showUnselectedLabels: 是否显示文字
/// - iconSize / selectedFontSize 等: 大小
///
/// 【注意】
/// - 超过 3 项时 type 默认变为 shifting，且未选中项可能看不到文字，
///   建议显式设置 type: fixed
/// - 切换页面时通常配合 IndexedStack 保持各页状态
/// - Material 3 推荐使用 NavigationBar（用法类似）
///
/// 【常见使用场景】
/// 1. App 主界面：首页/发现/消息/我的
/// 2. 配合 IndexedStack 保持页面状态
class BottomNavigationBarDemo extends StatefulWidget {
  const BottomNavigationBarDemo({super.key});

  @override
  State<BottomNavigationBarDemo> createState() => _BottomNavigationBarDemoState();
}

class _BottomNavigationBarDemoState extends State<BottomNavigationBarDemo> {
  int _index = 0;
  int _index2 = 0;
  int _index3 = 0;

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    const pages = ['首页内容', '发现内容', '我的内容'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('示例 1：基础用法 + IndexedStack 切换页面'),
          _frame(
            Scaffold(
              body: IndexedStack(
                index: _index,
                children: [for (final p in pages) Center(child: Text(p))],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: _items,
              ),
            ),
            height: 200,
          ),
          _label('示例 2：自定义颜色，只显示选中项文字'),
          _frame(
            Scaffold(
              body: Center(child: Text(pages[_index2])),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _index2,
                onTap: (i) => setState(() => _index2 = i),
                selectedItemColor: Colors.deepOrange,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.grey.shade100,
                showUnselectedLabels: false,
                items: _items,
              ),
            ),
            height: 200,
          ),
          _label('示例 3：type: shifting（选中项展开 + 各自背景色）'),
          _frame(
            Scaffold(
              body: Center(child: Text(pages[_index3])),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.shifting,
                currentIndex: _index3,
                onTap: (i) => setState(() => _index3 = i),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页', backgroundColor: Colors.blue),
                  BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现', backgroundColor: Colors.green),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的', backgroundColor: Colors.purple),
                ],
              ),
            ),
            height: 200,
          ),
          _label('示例 4：Material 3 的 NavigationBar（推荐）'),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: '首页'),
              NavigationDestination(icon: Icon(Icons.explore), label: '发现'),
              NavigationDestination(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== TabBar + TabBarView =====================
///
/// 【是什么】
/// TabBar 是一排标签，TabBarView 是与之联动的可左右滑动的内容页，
/// 两者通过同一个 TabController 联动（DefaultTabController 可自动提供）。
///
/// 【属性】
/// - TabBar.tabs:                 标签列表（Tab(text/icon)）
/// - TabBar.controller:           控制器；不传则用最近的 DefaultTabController
/// - TabBar.isScrollable:         标签多时可横向滚动
/// - TabBar.indicatorColor / indicatorWeight / indicatorSize: 指示器样式
/// - TabBar.labelColor / unselectedLabelColor / labelStyle: 文字样式
/// - TabBar.onTap:                点击回调
/// - TabBarView.children:         内容页，数量必须与 tabs 一致
/// - TabBarView.physics:          滑动效果，NeverScrollableScrollPhysics 禁止滑动
/// - DefaultTabController.length: 标签数量
///
/// 【注意】
/// - tabs 与 children 数量必须相同，否则报错
/// - TabBarView 需要有限高度，放在 Column 里要用 Expanded
/// - 自己创建 TabController 必须 with SingleTickerProviderStateMixin 并 dispose
/// - 想保持每页状态，使用 AutomaticKeepAliveClientMixin
///
/// 【常见使用场景】
/// 1. 新闻客户端的频道切换
/// 2. 详情页的"简介/评论/相关"分栏
/// 3. 顶部 AppBar.bottom 中放置 Tab
class TabBarDemo extends StatefulWidget {
  const TabBarDemo({super.key});

  @override
  State<TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _page(String t, Color c) => Container(color: c, alignment: Alignment.center, child: Text(t));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('示例 1：DefaultTabController + TabBar + TabBarView'),
          _frame(
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '新闻'),
                      Tab(icon: Icon(Icons.star), text: '收藏'),
                      Tab(icon: Icon(Icons.settings)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _page('新闻页', Colors.blue.shade50),
                        _page('收藏页', Colors.green.shade50),
                        _page('设置页', Colors.orange.shade50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            height: 200,
          ),
          _label('示例 2：自己的 TabController + 自定义样式 + 代码切换'),
          _frame(
            Column(
              children: [
                TabBar(
                  controller: _controller,
                  labelColor: Colors.deepOrange,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepOrange,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'A'),
                    Tab(text: 'B'),
                    Tab(text: 'C'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      _page('A 页', Colors.red.shade50),
                      _page('B 页', Colors.purple.shade50),
                      _page('C 页', Colors.teal.shade50),
                    ],
                  ),
                ),
              ],
            ),
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(onPressed: () => _controller.animateTo(2), child: const Text('跳到 C')),
          ),
          _label('示例 3：isScrollable 标签很多时可滚动'),
          DefaultTabController(
            length: 8,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [for (var i = 1; i <= 8; i++) Tab(text: '频道$i')],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== Drawer =====================
///
/// 【是什么】
/// 从屏幕侧边滑出的导航面板，作为 Scaffold.drawer / endDrawer 使用。
///
/// 【属性】
/// - child:            内容，常用 ListView
/// - backgroundColor:  背景色
/// - width:            宽度（默认 304）
/// - elevation:        阴影
/// - shape:            形状
/// 配套组件：
/// - DrawerHeader / UserAccountsDrawerHeader: 抽屉头部
/// - ListTile:         抽屉菜单项
/// - Scaffold.drawer / endDrawer: 左 / 右抽屉
/// - Scaffold.of(context).openDrawer(): 代码打开；Navigator.pop 关闭
///
/// 【注意】
/// - 设置了 Scaffold.drawer 后 AppBar 会自动出现菜单图标
/// - 内容可能超出高度时务必用 ListView
/// - 点击菜单项后记得 Navigator.pop(context) 关闭抽屉
/// - 大屏幕可考虑 NavigationRail 常驻侧边栏
///
/// 【常见使用场景】
/// 1. App 的侧边主菜单
/// 2. 用户信息 + 设置入口
/// 3. 筛选条件面板（endDrawer）
class DrawerDemo extends StatefulWidget {
  const DrawerDemo({super.key});

  @override
  State<DrawerDemo> createState() => _DrawerDemoState();
}

class _DrawerDemoState extends State<DrawerDemo> {
  String _selected = '首页';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('示例 1：UserAccountsDrawerHeader + ListTile（点击 AppBar 左侧菜单）'),
          _frame(
            Scaffold(
              appBar: AppBar(title: Text('当前：$_selected')),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const UserAccountsDrawerHeader(
                      accountName: Text('小明'),
                      accountEmail: Text('xiaoming@example.com'),
                      currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
                    ),
                    for (final item in const {'首页': Icons.home, '收藏': Icons.favorite, '设置': Icons.settings}.entries)
                      ListTile(
                        leading: Icon(item.value),
                        title: Text(item.key),
                        selected: _selected == item.key,
                        onTap: () {
                          setState(() => _selected = item.key);
                          Navigator.pop(context); // 关闭抽屉
                        },
                      ),
                  ],
                ),
              ),
              body: Center(child: Text('$_selected 页面')),
            ),
            height: 360,
          ),
          _label('示例 2：自定义宽度的 endDrawer + 代码打开'),
          _frame(
            Scaffold(
              endDrawer: Drawer(
                width: 200,
                backgroundColor: Colors.amber.shade100,
                child: const Center(child: Text('筛选面板')),
              ),
              body: Center(
                child: Builder(
                  builder: (ctx) =>
                      ElevatedButton(onPressed: () => Scaffold.of(ctx).openEndDrawer(), child: const Text('打开右侧抽屉')),
                ),
              ),
            ),
            height: 200,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== Navigator =====================
///
/// 【是什么】
/// Navigator 以"栈"的方式管理页面（Route）：push 入栈显示新页面，
/// pop 出栈返回上一页。MaterialApp 内部已自带一个 Navigator。
///
/// 【属性 / 常用方法】
/// - Navigator.push(context, route):        进入新页面
/// - Navigator.pop(context, [result]):      返回，可带结果给上一页
/// - Navigator.pushReplacement:             替换当前页（不能返回）
/// - Navigator.pushAndRemoveUntil:          入栈并清除之前的页面
/// - Navigator.popUntil / maybePop / canPop: 连续返回 / 安全返回 / 判断
/// - Navigator.pushNamed(context, '/x'):    命名路由，需在 MaterialApp.routes 注册
/// - MaterialPageRoute(builder:, fullscreenDialog:): 页面路由，是否以全屏对话框样式
/// - await push 的返回值:                    接收下个页面 pop 的结果
///
/// 【注意】
/// - 异步 await 之后使用 context 前先检查 mounted
/// - 命名路由对复杂传参不方便，大型项目可用 go_router 等方案
/// - 页面返回结果类型要与 `push<T>` 的泛型一致
///
/// 【常见使用场景】
/// 1. 列表进入详情页
/// 2. 选择页返回选择结果（如选城市）
/// 3. 登录成功后替换首页并清空栈
class NavigatorDemo extends StatefulWidget {
  const NavigatorDemo({super.key});

  @override
  State<NavigatorDemo> createState() => _NavigatorDemoState();
}

class _NavigatorDemoState extends State<NavigatorDemo> {
  String _result = '（还没有结果）';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('示例 1：push 进入新页面，并通过 pop 返回'),
        ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DetailPage(title: '详情页'))),
          child: const Text('push 详情页'),
        ),
        const SizedBox(height: 16),
        const Text('示例 2：接收上一页返回的结果'),
        ElevatedButton(
          onPressed: () async {
            final r = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const _SelectPage()));
            if (!mounted) return;
            setState(() => _result = r ?? '用户直接返回');
          },
          child: const Text('选择一个水果'),
        ),
        Text('结果：$_result'),
        const SizedBox(height: 16),
        const Text('示例 3：fullscreenDialog 全屏对话框式页面'),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(fullscreenDialog: true, builder: (_) => const _DetailPage(title: '全屏对话框')),
          ),
          child: const Text('fullscreenDialog'),
        ),
        const SizedBox(height: 16),
        const Text('示例 4：连续 push，popUntil 回到第一个页面'),
        ElevatedButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const _DetailPage(title: '第 1 层', depth: 1))),
          child: const Text('进入多层页面'),
        ),
      ],
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.title, this.depth = 0});

  final String title;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('返回 (pop)')),
            if (depth > 0) ...[
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _DetailPage(title: '第 ${depth + 1} 层', depth: depth + 1),
                  ),
                ),
                child: const Text('再进一层'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('回到最初页面 (popUntil)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectPage extends StatelessWidget {
  const _SelectPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择水果')),
      body: ListView(
        children: [
          for (final f in ['苹果', '香蕉', '橙子']) ListTile(title: Text(f), onTap: () => Navigator.pop(context, f)),
        ],
      ),
    );
  }
}
