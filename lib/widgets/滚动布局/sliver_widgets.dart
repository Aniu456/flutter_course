import 'package:flutter/material.dart';

// 滚动进阶：SliverAppBar / ReorderableListView。

/// ===================== SliverAppBar =====================
///
/// 【是什么】
/// 放在 CustomScrollView 中、能随滚动伸缩的 AppBar，
/// 常配合 FlexibleSpaceBar 做"大图头部 → 折叠成标题栏"的效果。
///
/// 【属性】
/// - expandedHeight: 展开时的总高度
/// - flexibleSpace: 通常是 FlexibleSpaceBar(title, background, collapseMode)
/// - pinned: 折叠后是否固定在顶部（不完全滚出屏幕）
/// - floating: 向下滑动时是否立刻出现（不必滚回顶部）
/// - snap: 与 floating 一起使用，出现 / 收起时自动吸附到完整状态
/// - stretch: 在顶部继续下拉时是否拉伸背景（配合 BouncingScrollPhysics）
/// - SliverAppBar.medium / .large: Material 3 的中 / 大标题样式
///
/// 【注意】
/// - snap: true 必须同时 floating: true
/// - 只能放在 CustomScrollView / NestedScrollView 的 slivers 中
/// - 和普通列表搭配时用 SliverList / SliverGrid，而不是 ListView
///
/// 【常见使用场景】
/// 个人主页、商品详情页、文章详情页的可折叠头部
class SliverAppBarDemo extends StatefulWidget {
  const SliverAppBarDemo({super.key});

  @override
  State<SliverAppBarDemo> createState() => _SliverAppBarDemoState();
}

class _SliverAppBarDemoState extends State<SliverAppBarDemo> {
  bool _pinned = true;
  bool _floating = false;
  bool _snap = false;

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _switch('pinned', _pinned, (v) => setState(() => _pinned = v)),
            _switch(
              'floating',
              _floating,
              (v) => setState(() {
                _floating = v;
                if (!v) _snap = false; // snap 依赖 floating
              }),
            ),
            _switch(
              'snap',
              _snap,
              (v) => setState(() {
                _snap = v;
                if (v) _floating = true;
              }),
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: CustomScrollView(
            // Key 变化时重建，确保切换 floating / snap 后立刻生效
            key: ValueKey('$_pinned$_floating$_snap'),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 200,
                pinned: _pinned,
                floating: _floating,
                snap: _snap,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('SliverAppBar'),
                  background: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.landscape, size: 100, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: 30,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text('列表项 ${i + 1}'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===================== ReorderableListView =====================
///
/// 【是什么】
/// 可以拖拽排序的列表。
///
/// 【属性】
/// - children / itemBuilder + itemCount: 列表项，每一项必须有唯一 Key
/// - onReorderItem(oldIndex, newIndex): 在这里修改数据顺序（Flutter 3.41+ 推荐）
/// - buildDefaultDragHandles: 是否自动加拖拽手柄（移动端默认长按整项拖动）
/// - proxyDecorator: 自定义拖动中条目的外观
/// - header / footer: 列表头尾
///
/// 【注意】
/// - 经典坑：旧的 onReorder 回调里，如果 oldIndex < newIndex 要先 newIndex -= 1
///   （移除旧元素后后面的下标都前移了一位）；新的 onReorderItem 已经帮你修正好了
/// - 每一项必须有 Key（一般用 ValueKey(数据 id)）
/// - 自定义手柄：buildDefaultDragHandles: false + ReorderableDragStartListener
///
/// 【常见使用场景】
/// 待办优先级排序、频道 / 标签排序、播放列表
class ReorderableListViewDemo extends StatefulWidget {
  const ReorderableListViewDemo({super.key});

  @override
  State<ReorderableListViewDemo> createState() => _ReorderableListViewDemoState();
}

class _ReorderableListViewDemoState extends State<ReorderableListViewDemo> {
  final List<String> _items = ['推荐', '关注', '热榜', '视频', '科技', '体育', '财经', '娱乐'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('按住右侧 ≡ 拖动排序\n当前顺序：${_items.join(' / ')}', textAlign: TextAlign.center),
        ),
        const Divider(height: 1),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: _items.length,
            // onReorderItem 给出的 newIndex 已经修正过，直接 removeAt + insert 即可
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                key: ValueKey(item),
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item),
                // 自定义拖拽手柄：按住右侧图标即可拖动
                trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
              );
            },
          ),
        ),
      ],
    );
  }
}
