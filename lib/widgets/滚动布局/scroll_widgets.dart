import 'package:flutter/material.dart';

// 滚动布局：ListView / GridView / SingleChildScrollView / CustomScrollView / PageView。

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 彩色方块，用于填充滚动内容
class _Box extends StatelessWidget {
  const _Box(this.index, {this.width});
  final int index;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: Colors.primaries[index % Colors.primaries.length].shade300,
      child: Text('$index', style: const TextStyle(color: Colors.white)),
    );
  }
}

/// ===================== ListView =====================
///
/// 【是什么】
/// 可滚动的线性列表（默认纵向）。最常用的滚动组件。
/// 四种构造方式：
/// - ListView(children: [...])          一次性创建所有子项，适合少量固定内容
/// - ListView.builder(...)              按需懒加载，适合大量/无限数据（推荐）
/// - ListView.separated(...)            builder + 分隔组件
/// - ListView.custom(...)               自定义 SliverChildDelegate（进阶）
///
/// 【属性】
/// - scrollDirection:  滚动方向，Axis.vertical（默认）/ Axis.horizontal
/// - reverse:          是否反向（聊天界面常用）
/// - controller:       ScrollController，监听/控制滚动位置
/// - physics:          滚动物理效果：BouncingScrollPhysics 回弹、
///                     ClampingScrollPhysics 夹紧、NeverScrollableScrollPhysics 禁止滚动
/// - shrinkWrap:       true 时高度取决于内容（性能较差，慎用）
/// - padding:          列表内边距
/// - itemExtent:       固定每项主轴长度，可提升性能
/// - itemCount:        builder 的项数；不传则无限
/// - itemBuilder:      (context, index) 创建子项
/// - separatorBuilder: separated 的分隔组件
/// - cacheExtent:      预渲染区域大小
///
/// 【注意】
/// - ListView 在主轴方向需要有限空间：不能直接放在 Column 里，
///   需用 Expanded / SizedBox 限定高度，否则报 unbounded height 错误
/// - 横向 ListView 必须给出高度（如 SizedBox(height: ...)）
/// - 大数据别用 children 直接展开，用 builder
/// - 嵌套在另一个滚动组件里时，用 shrinkWrap: true + physics: NeverScrollableScrollPhysics，
///   或改用 CustomScrollView + Sliver
///
/// 【常见使用场景】
/// 1. 消息/商品/联系人列表
/// 2. 设置页
/// 3. 横向滑动的卡片/标签栏
/// 4. 聊天记录（reverse）
class ListViewDemo extends StatelessWidget {
  const ListViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 整体用 Column 的 Expanded 分配高度，每个示例都是有界高度
    return Column(
      children: [
        const _Label('1. 横向 ListView（必须限定高度）'),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (var i = 0; i < 10; i++) Padding(padding: const EdgeInsets.only(right: 8), child: _Box(i, width: 80)),
            ],
          ),
        ),
        const _Label('2. ListView.builder（懒加载，1000 项也不卡）'),
        Expanded(
          child: ListView.builder(
            itemCount: 1000,
            itemExtent: 56,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(child: Text('$index')),
              title: Text('第 $index 项'),
              subtitle: const Text('builder 只创建屏幕可见的项'),
            ),
          ),
        ),
        const _Label('3. ListView.separated（带分割线 + 回弹物理效果）'),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: 20,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                ListTile(title: Text('Item $index'), trailing: const Icon(Icons.chevron_right)),
          ),
        ),
      ],
    );
  }
}

/// ===================== GridView =====================
///
/// 【是什么】
/// 可滚动的网格（二维）布局。
/// 构造方式：
/// - GridView.count(crossAxisCount: n)       固定列数
/// - GridView.extent(maxCrossAxisExtent: x)  每项最大宽度，自适应列数
/// - GridView.builder(gridDelegate: ...)     懒加载，大量数据推荐
/// - GridView(gridDelegate, children)        通用写法
///
/// 【属性】
/// - gridDelegate:      布局规则：
///     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount 列数)
///     SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent 最大宽)
/// - crossAxisCount:    交叉轴列数
/// - mainAxisSpacing:   主轴方向（纵向滚动时是行）间距
/// - crossAxisSpacing:  交叉轴方向间距
/// - childAspectRatio:  子项 宽/高 比，默认 1.0
/// - mainAxisExtent:    固定每项主轴长度（与 childAspectRatio 二选一）
/// - scrollDirection / reverse / controller / physics / shrinkWrap / padding:
///                      与 ListView 相同
///
/// 【注意】
/// - 子项高度由 childAspectRatio 决定，内容高度不固定会溢出；
///   需要高度自适应的瀑布流请使用 flutter_staggered_grid_view 等第三方库
/// - 同样需要有界高度，不能直接放进 Column（用 Expanded）
/// - 大数据用 GridView.builder
///
/// 【常见使用场景】
/// 1. 相册、商品宫格
/// 2. 九宫格功能入口
/// 3. 应用图标列表
class GridViewDemo extends StatelessWidget {
  const GridViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Label('1. GridView.count：固定 3 列 + 间距'),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            children: [for (var i = 0; i < 12; i++) _Box(i)],
          ),
        ),
        const _Label('2. GridView.extent：每项最大 100，自适应列数；childAspectRatio 2'),
        Expanded(
          child: GridView.extent(
            maxCrossAxisExtent: 100,
            childAspectRatio: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            children: [for (var i = 0; i < 20; i++) _Box(i)],
          ),
        ),
        const _Label('3. GridView.builder：懒加载 + gridDelegate'),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 200,
            itemBuilder: (context, index) => _Box(index),
          ),
        ),
      ],
    );
  }
}

/// ===================== SingleChildScrollView =====================
///
/// 【是什么】
/// 让"一个子组件"可以滚动。当内容超出屏幕（如表单、长页面、软键盘弹出）
/// 又不需要列表懒加载时使用。
///
/// 【属性】
/// - child:            唯一的子组件，通常是 Column / Row
/// - scrollDirection:  滚动方向，默认纵向
/// - reverse:          是否反向
/// - padding:          内边距
/// - controller:       ScrollController
/// - physics:          滚动物理效果
/// - primary:          是否使用 PrimaryScrollController
/// - clipBehavior:     裁剪方式
/// - keyboardDismissBehavior: 拖动时是否收起键盘
///
/// 【注意】
/// - 会一次性构建全部子组件，内容很多（几百项以上）请用 ListView.builder
/// - child 为 Column 时，不要在里面再放 Expanded / Flexible（高度无界会报错），
///   也不要再放没限定高度的 ListView
/// - 想让内容较少时撑满屏幕：用 LayoutBuilder + ConstrainedBox(minHeight) + IntrinsicHeight
/// - 横向滚动同理，child 用 Row
///
/// 【常见使用场景】
/// 1. 长表单（避免键盘遮挡溢出）
/// 2. 详情页
/// 3. 横屏时内容溢出的兜底
/// 4. 横向的标签栏
class SingleChildScrollViewDemo extends StatelessWidget {
  const SingleChildScrollViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Label('1. 横向 SingleChildScrollView + Row'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var i = 0; i < 15; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(label: Text('标签 $i'), onPressed: () {}),
                ),
            ],
          ),
        ),
        const _Label('2. 纵向 SingleChildScrollView + Column（长表单）'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                for (var i = 0; i < 12; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      decoration: InputDecoration(labelText: '输入框 $i', border: const OutlineInputBorder()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ===================== CustomScrollView + Slivers =====================
///
/// 【是什么】
/// 用多个 Sliver（"碎片"）拼成一个统一滚动区域，可以混合
/// 折叠标题栏、列表、网格等，滚动联动、性能好。
///
/// 【属性】
/// - slivers:           Sliver 列表（必须都是 Sliver 系列组件）
/// - 常用 Sliver：
///     SliverAppBar         可折叠/悬浮的标题栏（pinned / floating / snap /
///                          expandedHeight / flexibleSpace）
///     SliverList           列表（delegate: SliverChildBuilderDelegate 等）
///     SliverGrid           网格（gridDelegate + delegate）
///     SliverToBoxAdapter   把普通组件放进 Sliver 世界
///     SliverPadding        给 Sliver 加内边距
///     SliverPersistentHeader 自定义吸顶头部
///     SliverFillRemaining  填满剩余空间
/// - controller / physics / scrollDirection / reverse / shrinkWrap: 同 ListView
///
/// 【注意】
/// - slivers 里不能直接放普通 Widget（如 Container），要用 SliverToBoxAdapter 包裹
/// - SliverAppBar 的 pinned 固定在顶部、floating 向下滑时立即出现、
///   snap 配合 floating 自动吸附
/// - 使用 SliverAppBar 时，外层 Scaffold 不应再设置 appBar
/// - 需要列表 + 网格 + 头部联动滚动时才用，单一列表直接用 ListView
///
/// 【常见使用场景】
/// 1. 商品详情页（顶部大图折叠 + 内容列表）
/// 2. 首页：Banner + 宫格 + 列表混排
/// 3. 吸顶分组标题
class CustomScrollViewDemo extends StatelessWidget {
  const CustomScrollViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 示例 1：可折叠、固定的标题栏
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('SliverAppBar'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // 示例 2：SliverToBoxAdapter 放普通组件
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.all(16), child: Text('SliverToBoxAdapter：把普通组件放进 CustomScrollView')),
        ),
        // 示例 3：SliverGrid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) => _Box(index), childCount: 9),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.all(16), child: Text('下面是 SliverList')),
        ),
        // 示例 4：SliverList
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(leading: const Icon(Icons.label), title: Text('列表项 $index')),
            childCount: 30,
          ),
        ),
      ],
    );
  }
}

/// ===================== PageView =====================
///
/// 【是什么】
/// 一页一页滑动的容器，每个子项占满整个视口。用于轮播图、引导页、
/// 选项卡内容区。
///
/// 【属性】
/// - children / PageView.builder(itemCount, itemBuilder): 页面内容
/// - controller:      PageController：initialPage 初始页、
///                    viewportFraction 每页占视口比例（<1 可露出相邻页）、
///                    keepPage；可调用 animateToPage / jumpToPage
/// - scrollDirection: 滑动方向，默认横向
/// - reverse:         反向
/// - pageSnapping:    是否自动吸附到整页，默认 true
/// - physics:         滚动效果，NeverScrollableScrollPhysics 禁止手势滑动
/// - onPageChanged:   页面切换回调，参数为新页索引
/// - allowImplicitScrolling: 预加载相邻页
///
/// 【注意】
/// - 必须有有界高度（放入 Expanded / SizedBox）
/// - PageController 需要在 State 中创建并 dispose
/// - 每页默认会被销毁重建，需保持状态用 AutomaticKeepAliveClientMixin
/// - 自动轮播需自己用 Timer 调 animateToPage，并在 dispose 取消
/// - 底部导航 + 页面切换推荐 IndexedStack 或 TabBarView
///
/// 【常见使用场景】
/// 1. 首页轮播图 Banner
/// 2. 新手引导页
/// 3. 图片浏览器
/// 4. 卡片式切换（viewportFraction）
class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  final PageController _controller = PageController();
  final PageController _cardController = PageController(viewportFraction: 0.8);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Label('1. 基础 PageView + 指示点 + 按钮控制（onPageChanged）'),
        Expanded(
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.primaries[i * 3].shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('第 ${i + 1} 页', style: const TextStyle(fontSize: 24, color: Colors.white)),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
            for (var i = 0; i < 4; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _current == i ? Colors.blue : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () =>
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
          ],
        ),
        const _Label('2. viewportFraction 0.8：露出相邻页的卡片式'),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _cardController,
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _Box(index)),
            ),
          ),
        ),
        const _Label('3. 纵向 PageView（scrollDirection: Axis.vertical）'),
        SizedBox(
          height: 100,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 5,
            itemBuilder: (context, index) => _Box(index + 5),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
