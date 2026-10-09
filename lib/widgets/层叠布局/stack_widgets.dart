import 'package:flutter/material.dart';

// 层叠布局：Stack / Positioned / IndexedStack。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _box(String text, Color color, {double size = 100}) {
  return Container(
    width: size,
    height: size,
    color: color,
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

/// ===================== Stack =====================
///
/// 【是什么】
/// Stack 让子组件沿 Z 轴一层层叠放，后面的子组件盖在前面的上面。
/// 可配合 Positioned 精确指定子项相对 Stack 边缘的位置。
///
/// 【属性】
/// - children:     子组件列表，越靠后越在上层
/// - alignment:    "非定位子项"（没被 Positioned 包裹的）在 Stack 中的对齐位置，
///                 默认 AlignmentDirectional.topStart（左上角）
/// - fit:          非定位子项的约束方式：
///                 StackFit.loose（默认）子项可以按自身大小；
///                 StackFit.expand 强制子项撑满 Stack；
///                 StackFit.passthrough 把父约束直接传给子项
/// - clipBehavior: 超出 Stack 范围的子项如何裁剪，默认 Clip.hardEdge（会被裁掉！）
///                 想显示超出部分设为 Clip.none
/// - textDirection: 解析 alignment 的文字方向
///
/// 【尺寸规则】
/// - Stack 的大小由"非定位子项"中最大的那个决定；
///   若全是 Positioned 子项，Stack 会撑满父组件给的空间
///
/// 【注意】
/// - 超出 Stack 的 Positioned 子项默认被裁剪且点击无效，
///   需要 clipBehavior: Clip.none（但点击测试仍可能落在范围外而无效）
/// - 全部是 Positioned 时，需要保证父组件给了有限尺寸，
///   通常用 SizedBox / Container 固定大小
/// - 子项很多且只显示其中一个时，用 IndexedStack
///
/// 【常见使用场景】
/// 1. 图片上叠加文字 / 渐变遮罩
/// 2. 头像右上角的角标、红点
/// 3. 悬浮按钮、加载中遮罩
/// 4. 卡片的装饰元素叠加
class StackDemo extends StatelessWidget {
  const StackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：基础叠放，后面的盖在前面上，默认左上角对齐
          _title('1. 基础叠放（后者在上，默认左上对齐）'),
          Center(
            child: Stack(
              children: [
                _box('大', Colors.red, size: 120),
                _box('中', Colors.green, size: 80),
                _box('小', Colors.blue, size: 40),
              ],
            ),
          ),

          // 示例 2：alignment
          _title('2. alignment: Alignment.center'),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _box('大', Colors.red, size: 120),
                _box('中', Colors.green, size: 80),
                _box('小', Colors.blue, size: 40),
              ],
            ),
          ),

          // 示例 3：fit: expand
          _title('3. fit: StackFit.expand（子项撑满）'),
          SizedBox(
            width: 200,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.amber),
                const Center(child: Text('被撑满的子项')),
              ],
            ),
          ),

          // 示例 4：图片位 + 渐变遮罩 + 文字（用色块代替图片）
          _title('4. 图片卡片：底部渐变遮罩 + 标题'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.teal,
                      child: const Icon(Icons.landscape, size: 80, color: Colors.white54),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 12,
                      bottom: 10,
                      child: Text('山间风景', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 示例 5：clipBehavior —— 角标超出范围
          _title('5. clipBehavior: Clip.none（红点超出头像也能显示）'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 32)),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: const Text('99+', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Positioned =====================
///
/// 【是什么】
/// Positioned 只能用在 Stack 里，通过 left / top / right / bottom
/// 指定子组件相对 Stack 四条边的距离，实现"绝对定位"。
///
/// 【属性】
/// - left / top / right / bottom: 距 Stack 对应边的距离，可为负数（超出）
/// - width / height:              子项宽高
/// - child:                       子组件
/// - Positioned.fill(...):        四边默认 0，填满 Stack
/// - Positioned.fromRect / fromRelativeRect: 通过矩形定位
///
/// 【注意】
/// - 必须是 Stack 的直接子级，否则报 ParentDataWidget 错误
/// - 水平方向 left、right、width 三者最多设置两个，
///   垂直方向 top、bottom、height 同理，否则断言报错
/// - 只设置 left+right 时宽度被拉伸；只设置 left 时宽度由子组件自身决定
/// - 不设置任何值时，等同于普通的非定位子项
/// - 需要使用相对比例（如 50% 宽度）定位时，用 Align 而不是 Positioned
///
/// 【常见使用场景】
/// 1. 右上角关闭按钮、角标
/// 2. 底部悬浮的操作条
/// 3. 全屏遮罩（Positioned.fill）
/// 4. 在画布上随意摆放元素
class PositionedDemo extends StatelessWidget {
  const PositionedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：四个角
          _title('1. left / top / right / bottom 定位四角'),
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
            child: Stack(
              children: [
                Positioned(left: 0, top: 0, child: _box('左上', Colors.red, size: 50)),
                Positioned(right: 0, top: 0, child: _box('右上', Colors.green, size: 50)),
                Positioned(left: 0, bottom: 0, child: _box('左下', Colors.blue, size: 50)),
                Positioned(right: 0, bottom: 0, child: _box('右下', Colors.orange, size: 50)),
                Positioned(left: 60, top: 55, child: _box('偏移', Colors.purple, size: 50)),
              ],
            ),
          ),

          // 示例 2：同时设置 left 和 right 拉伸宽度
          _title('2. left + right 同时设置：宽度被拉伸'),
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  right: 20,
                  top: 20,
                  height: 40,
                  child: Container(
                    color: Colors.teal,
                    alignment: Alignment.center,
                    child: const Text('left:20 right:20 height:40', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // 示例 3：Positioned.fill 做遮罩
          _title('3. Positioned.fill：全覆盖遮罩（加载中）'),
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.lightBlue.shade100,
                    alignment: Alignment.center,
                    child: const Text('页面内容'),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black38,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),

          // 示例 4：关闭按钮 + 底部操作条
          _title('4. 右上角关闭按钮 + 底部操作条'),
          Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                const Center(child: Text('内容区域')),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(8),
                    child: const Text('底部操作条', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== IndexedStack =====================
///
/// 【是什么】
/// IndexedStack 是 Stack 的子类：所有子组件都会被创建并保留状态，
/// 但每次只显示 index 指定的那一个，其余隐藏（不绘制、不响应点击）。
///
/// 【属性】
/// - index:        当前显示的子组件下标，为 null 时一个都不显示
/// - children:     子组件列表
/// - alignment:    子项对齐方式，默认左上
/// - sizing:       StackFit：loose / expand / passthrough
/// - clipBehavior: 裁剪方式
///
/// 【注意】
/// - 所有子项都会提前构建，子项很多或很重时耗内存、启动慢
/// - 优点是切换时保持各子页面的状态（如滚动位置、输入内容不丢失）
/// - 大小由所有子项中最大者决定，而不仅是当前显示的那个
/// - 需要"懒加载"时，不要用 IndexedStack，改用 PageView 或普通条件渲染
///
/// 【常见使用场景】
/// 1. 底部导航栏切换页面并保持各页状态
/// 2. Tab 内容切换且不想重建
/// 3. 多步骤表单的各步骤保持输入内容
class IndexedStackDemo extends StatefulWidget {
  const IndexedStackDemo({super.key});

  @override
  State<IndexedStackDemo> createState() => _IndexedStackDemoState();
}

class _IndexedStackDemoState extends State<IndexedStackDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('点击下方按钮切换；在第 1 页输入文字后切走再切回，内容仍然保留'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('页 1'), icon: Icon(Icons.edit)),
              ButtonSegment(value: 1, label: Text('页 2'), icon: Icon(Icons.favorite)),
              ButtonSegment(value: 2, label: Text('页 3'), icon: Icon(Icons.settings)),
            ],
            selected: {_index},
            onSelectionChanged: (s) => setState(() => _index = s.first),
          ),
        ),
        const SizedBox(height: 12),
        // IndexedStack 用 Expanded 占满剩余高度
        Expanded(
          child: IndexedStack(
            index: _index,
            alignment: Alignment.topCenter,
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(labelText: '页 1：输入内容会被保留', border: OutlineInputBorder()),
                ),
              ),
              Center(child: Icon(Icons.favorite, size: 80, color: Colors.pink)),
              Center(child: Icon(Icons.settings, size: 80, color: Colors.indigo)),
            ],
          ),
        ),
      ],
    );
  }
}
