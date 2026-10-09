import 'package:flutter/material.dart';

// 弹性布局：Flex / Expanded / Flexible / Spacer。

Widget _box(String text, Color color, {double? w = 50, double h = 50}) {
  return Container(
    width: w,
    height: h,
    color: color,
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// ===================== Flex =====================
///
/// 【是什么】
/// Flex 是 Row 和 Column 的父类：Row 就是 direction 固定为水平的 Flex，
/// Column 就是 direction 固定为垂直的 Flex。需要"根据条件切换水平/垂直"时直接用 Flex。
///
/// 【属性】
/// - direction:          必填，排列方向 Axis.horizontal / Axis.vertical
/// - children:           子组件，配合 Expanded / Flexible 可按比例分配空间
/// - mainAxisAlignment:  主轴对齐方式（同 Row/Column）
/// - crossAxisAlignment: 交叉轴对齐方式
/// - mainAxisSize:       max / min
/// - verticalDirection / textDirection: 排列方向的正反
/// - clipBehavior:       溢出内容的裁剪方式
///
/// 【注意】
/// - 平时直接用 Row / Column 即可，代码更直观
/// - 主轴方向必须有"有限空间"，Expanded/Flexible 才能工作
///   （在可滚动组件的滚动方向上使用会报错）
///
/// 【常见使用场景】
/// 1. 响应式布局：宽屏水平排列，窄屏垂直排列
/// 2. 封装通用组件时，由参数决定排列方向
class FlexDemo extends StatefulWidget {
  const FlexDemo({super.key});

  @override
  State<FlexDemo> createState() => _FlexDemoState();
}

class _FlexDemoState extends State<FlexDemo> {
  bool _horizontal = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：等价于 Row / Column
          _title('1. Flex(direction: horizontal) 等价于 Row'),
          Flex(
            direction: Axis.horizontal,
            children: [_box('A', Colors.red), _box('B', Colors.green), _box('C', Colors.blue)],
          ),
          _title('2. Flex(direction: vertical) 等价于 Column'),
          Flex(direction: Axis.vertical, children: [_box('A', Colors.red, h: 30), _box('B', Colors.green, h: 30)]),

          // 示例 3：点击按钮动态切换方向
          _title('3. 动态切换方向'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              title: Text(_horizontal ? '水平 Axis.horizontal' : '垂直 Axis.vertical'),
              value: _horizontal,
              onChanged: (v) => setState(() => _horizontal = v),
            ),
          ),
          Container(
            height: 160,
            color: Colors.grey.shade200,
            child: Flex(
              direction: _horizontal ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_box('1', Colors.orange), _box('2', Colors.teal), _box('3', Colors.purple)],
            ),
          ),

          // 示例 4：Flex + Expanded 按比例（1:2:1）
          _title('4. Flex + Expanded 按 flex 比例 1:2:1'),
          SizedBox(
            height: 60,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(flex: 1, child: _box('1', Colors.red, w: null)),
                Expanded(flex: 2, child: _box('2', Colors.green, w: null)),
                Expanded(flex: 1, child: _box('1', Colors.blue, w: null)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== Expanded =====================
///
/// 【是什么】
/// Expanded 只能用在 Row / Column / Flex 里，让子组件"撑满"主轴上的剩余空间。
/// 多个 Expanded 会按 flex 比例瓜分剩余空间。
///
/// 【属性】
/// - flex:  占比，默认 1。如 flex 分别为 1、2，则剩余空间按 1:2 分配
/// - child: 子组件，会被强制拉伸到分配到的空间（紧约束）
///
/// 【注意】
/// - Expanded 必须是 Flex 系列（Row/Column/Flex）的"直接子级"，
///   否则报 "Incorrect use of ParentDataWidget"
/// - 先排布没有 flex 的固定子项，再把剩余空间分给 Expanded
/// - 在 Row 中，子项（如 Text）过长导致溢出，用 Expanded 包裹即可自动换行
/// - Expanded 等价于 Flexible(fit: FlexFit.tight)
/// - 不能放在 SingleChildScrollView 的滚动方向里（空间无限，无法分配）
///
/// 【常见使用场景】
/// 1. 输入框 + 按钮：输入框 Expanded 占满剩余宽度
/// 2. 按比例分栏（左 1/3，右 2/3）
/// 3. 页面中"固定头部 + 自适应内容 + 固定底部"
/// 4. 解决 Row 中文字溢出
class ExpandedDemo extends StatelessWidget {
  const ExpandedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：一个 Expanded 占满剩余
          _title('1. 一个 Expanded 占满剩余宽度'),
          Row(
            children: [
              _box('固定', Colors.red),
              Expanded(child: _box('Expanded', Colors.green, w: null)),
              _box('固定', Colors.blue),
            ],
          ),

          // 示例 2：flex 比例
          _title('2. flex 比例 1 : 2 : 3'),
          Row(
            children: [
              Expanded(flex: 1, child: _box('1', Colors.red, w: null)),
              Expanded(flex: 2, child: _box('2', Colors.green, w: null)),
              Expanded(flex: 3, child: _box('3', Colors.blue, w: null)),
            ],
          ),

          // 示例 3：搜索框 + 按钮
          _title('3. 输入框 + 按钮'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: '请输入关键字', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('搜索')),
              ],
            ),
          ),

          // 示例 4：Row 中长文字用 Expanded 换行
          _title('4. 解决长文字溢出'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(child: Text('如果这里不使用 Expanded，这段很长的文字会超出屏幕宽度并出现溢出警告。')),
              ],
            ),
          ),

          // 示例 5：Column 中的 Expanded（需要有限高度）
          _title('5. Column 中纵向 Expanded（高度 180）'),
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(height: 30, color: Colors.indigo),
                Expanded(flex: 1, child: Container(color: Colors.amber)),
                Expanded(flex: 2, child: Container(color: Colors.lightGreen)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== Flexible =====================
///
/// 【是什么】
/// Flexible 与 Expanded 类似，也用于 Row / Column / Flex 中分配剩余空间，
/// 但它允许子组件"不必撑满"，只在需要时占用不超过分配的空间。
/// （Expanded 就是 fit 为 tight 的 Flexible）
///
/// 【属性】
/// - flex: 占比，默认 1
/// - fit:  FlexFit.loose（默认）子组件可以比分配空间小，按自身大小显示；
///         FlexFit.tight 子组件必须撑满分配的空间（等同 Expanded）
/// - child: 子组件
///
/// 【注意】
/// - 必须是 Row/Column/Flex 的直接子级
/// - 子组件自身想要的尺寸较小时，loose 让它保持小；过大时则被限制在分配空间内
/// - 内容有可能很长又不想强制占满时用 Flexible；想占满就用 Expanded
///
/// 【常见使用场景】
/// 1. 聊天气泡：文字短时气泡包裹内容，文字长时最大不超过一定宽度并换行
/// 2. 标签 + 可截断文字，前后有固定元素时
/// 3. 需要在剩余空间内"尽量"适配的场景
class FlexibleDemo extends StatelessWidget {
  const FlexibleDemo({super.key});

  Widget _bubble(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：loose vs tight
          _title('1. FlexFit.loose（默认）：内容小则不撑满'),
          Container(
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Flexible(child: _box('loose', Colors.red, w: 60)),
                _box('固定', Colors.blue),
              ],
            ),
          ),
          _title('2. FlexFit.tight：撑满，等同 Expanded'),
          Container(
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Flexible(fit: FlexFit.tight, child: _box('tight', Colors.red, w: 60)),
                _box('固定', Colors.blue),
              ],
            ),
          ),

          // 示例 3：聊天气泡
          _title('3. 聊天气泡：短文字包裹内容，长文字自动换行'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                    const SizedBox(width: 8),
                    Flexible(child: _bubble('你好', Colors.lightBlue.shade100)),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _bubble('这是一段比较长的消息，用来演示 Flexible 在内容过长时会限制在剩余空间内并自动换行。', Colors.lightBlue.shade100),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ],
            ),
          ),

          // 示例 4：flex 比例 + loose
          _title('4. 不同 flex 的 Flexible'),
          Row(
            children: [
              Flexible(flex: 1, fit: FlexFit.tight, child: _box('1', Colors.orange, w: null)),
              Flexible(flex: 3, fit: FlexFit.tight, child: _box('3', Colors.teal, w: null)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== Spacer =====================
///
/// 【是什么】
/// Spacer 是一个"空白占位"组件，在 Row / Column / Flex 中撑开并占据剩余空间，
/// 把其他子组件推向两侧。本质是 Expanded(child: SizedBox.shrink())。
///
/// 【属性】
/// - flex: 占比，默认 1，多个 Spacer 按比例分配剩余空间
///
/// 【注意】
/// - 同样必须是 Row/Column/Flex 的直接子级
/// - 只需要固定间隔时，用 SizedBox(width: 8) 更合适
/// - 在主轴无限空间（如 Row 放入横向滚动视图）里使用会报错
///
/// 【常见使用场景】
/// 1. 一行中"左侧标题 + 右侧按钮"，用 Spacer 推到两端
/// 2. 让某个元素靠底部 / 靠右
/// 3. 按比例在子项之间留白
class SpacerDemo extends StatelessWidget {
  const SpacerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：左右两端
          _title('1. 一个 Spacer：左右两端'),
          Row(children: [_box('左', Colors.red), const Spacer(), _box('右', Colors.blue)]),

          // 示例 2：三个元素，一个 Spacer
          _title('2. 前面靠左，后面靠右'),
          Row(children: [_box('A', Colors.red), _box('B', Colors.green), const Spacer(), _box('C', Colors.blue)]),

          // 示例 3：多个 Spacer 按 flex 分配
          _title('3. Spacer(flex: 1) 与 Spacer(flex: 3)'),
          Container(
            color: Colors.grey.shade200,
            child: Row(
              children: [
                _box('A', Colors.red),
                const Spacer(flex: 1),
                _box('B', Colors.green),
                const Spacer(flex: 3),
                _box('C', Colors.blue),
              ],
            ),
          ),

          // 示例 4：Column 中把内容推到底部
          _title('4. Column 中 Spacer：按钮靠底部'),
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Column(
              children: [
                const Text('顶部内容'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () {}, child: const Text('底部按钮')),
                ),
              ],
            ),
          ),

          // 示例 5：典型标题栏
          _title('5. 典型标题栏'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('我的订单', style: TextStyle(fontSize: 18)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('查看全部')),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
