import 'package:flutter/material.dart';

// 线性布局：Row（水平排列）与 Column（垂直排列）。

/// 示例中使用的带标签的色块
Widget _box(String text, Color color, {double w = 50, double h = 50}) {
  return Container(
    width: w,
    height: h,
    color: color,
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

/// 示例标题
Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// ===================== Row =====================
///
/// 【是什么】
/// Row 把多个子组件沿"水平方向"从左到右排成一行。
/// 水平方向是它的"主轴"，垂直方向是"交叉轴"。
///
/// 【属性】
/// - children:           子组件列表
/// - mainAxisAlignment:  主轴（水平）对齐方式：
///                       start / end / center 靠起点 / 终点 / 居中；
///                       spaceBetween 两端对齐，子项之间等距；
///                       spaceAround 每个子项两侧空白相等；
///                       spaceEvenly 所有空白（含两端）完全相等
/// - crossAxisAlignment: 交叉轴（垂直）对齐方式：
///                       start / end / center / stretch（拉伸填满高度）/ baseline（文字基线对齐）
/// - mainAxisSize:       主轴占用空间：max（默认，尽量占满）/ min（包裹内容）
/// - textDirection:      水平排列方向（ltr 从左到右，rtl 从右到左）
/// - verticalDirection:  交叉轴方向（down / up）
/// - textBaseline:       使用 baseline 对齐时需指定的基线类型
///
/// 【注意】
/// - Row 在水平方向不限制子组件宽度，子项总宽超出时会出现黄黑条纹溢出报错
///   （RenderFlex overflowed）。解决：用 Expanded / Flexible 包裹，
///   或改用 Wrap、SingleChildScrollView(scrollDirection: Axis.horizontal)
/// - Row 的高度由最高的子项决定；放在无限高度的容器中也没问题，
///   但 crossAxisAlignment: stretch 需要高度有界
/// - 在 Row 里直接放 ListView / TextField 等"宽度无限"的组件会报错，需用 Expanded 包裹
/// - 子项之间要留空隙，可用 SizedBox(width: 8) 或 Spacer
///
/// 【常见使用场景】
/// 1. 列表项：头像 + 文字 + 右侧图标
/// 2. 工具栏、底部操作栏的按钮排列
/// 3. 表单中"标签 + 输入框"
/// 4. 图标与文字并排
class RowDemo extends StatelessWidget {
  const RowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：mainAxisAlignment 各种取值
          _title('1. mainAxisAlignment'),
          for (final a in [
            MainAxisAlignment.start,
            MainAxisAlignment.center,
            MainAxisAlignment.end,
            MainAxisAlignment.spaceBetween,
            MainAxisAlignment.spaceAround,
            MainAxisAlignment.spaceEvenly,
          ])
            Container(
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: a,
                children: [_box('A', Colors.red, h: 30), _box('B', Colors.green, h: 30), _box('C', Colors.blue, h: 30)],
              ),
            ),

          // 示例 2：crossAxisAlignment（Row 高度由容器 100 决定）
          _title('2. crossAxisAlignment: start / center / end / stretch'),
          for (final a in [
            CrossAxisAlignment.start,
            CrossAxisAlignment.center,
            CrossAxisAlignment.end,
            CrossAxisAlignment.stretch,
          ])
            Container(
              height: 80,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: a,
                children: [
                  Container(
                    width: 50,
                    height: 30,
                    color: Colors.orange,
                    alignment: Alignment.center,
                    child: Text(a.name),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.teal,
                    alignment: Alignment.center,
                    child: Text(a.name),
                  ),
                ],
              ),
            ),

          // 示例 3：mainAxisSize.min——Row 只包裹内容，配合 Center 居中
          _title('3. mainAxisSize: min（包裹内容）'),
          Center(
            child: Container(
              color: Colors.amber.shade100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.amber),
                  Text('只占内容宽度'),
                ],
              ),
            ),
          ),

          // 示例 4：textDirection: rtl 反向排列
          _title('4. textDirection: rtl（从右往左）'),
          Row(
            textDirection: TextDirection.rtl,
            children: [_box('1', Colors.red), _box('2', Colors.green), _box('3', Colors.blue)],
          ),

          // 示例 5：baseline 基线对齐——大小不同的文字底部对齐
          _title('5. crossAxisAlignment: baseline'),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('大字', style: TextStyle(fontSize: 36)),
              SizedBox(width: 8),
              Text('小字', style: TextStyle(fontSize: 14)),
            ],
          ),

          // 示例 6：典型列表项——头像 + 文字(Expanded) + 图标
          _title('6. 典型列表项'),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 12),
                // Expanded 让文字占满剩余宽度，过长时自动换行而不溢出
                Expanded(child: Text('这是一段很长很长的文字，用来演示在 Row 中如何避免溢出，Expanded 会让它自动换行。')),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ===================== Column =====================
///
/// 【是什么】
/// Column 把多个子组件沿"垂直方向"从上到下排成一列。
/// 垂直方向是它的"主轴"，水平方向是"交叉轴"（与 Row 正好相反）。
///
/// 【属性】
/// - children:           子组件列表
/// - mainAxisAlignment:  主轴（垂直）对齐：start / end / center /
///                       spaceBetween / spaceAround / spaceEvenly
/// - crossAxisAlignment: 交叉轴（水平）对齐：start / end / center / stretch / baseline
/// - mainAxisSize:       max（默认，尽量占满高度）/ min（包裹内容）
/// - textDirection:      交叉轴水平方向的起点（影响 crossAxisAlignment 的 start/end）
/// - verticalDirection:  down（默认，从上到下）/ up（从下到上）
///
/// 【注意】
/// - Column 不会滚动！子项总高超过屏幕会溢出报错，
///   解决：外面包 SingleChildScrollView，或直接用 ListView
/// - 在 Column 里放 ListView / GridView 等"高度无限"的组件会报
///   "unbounded height"，需用 Expanded 或 SizedBox 限定高度
/// - Column 默认宽度是子项中最宽者（交叉轴默认 center 对齐），
///   想让子项撑满宽度用 crossAxisAlignment: stretch
/// - 想让 Column 在 Scaffold.body 中居中，可用 Center 包裹，或 mainAxisAlignment: center
///
/// 【常见使用场景】
/// 1. 页面整体纵向结构：标题 + 内容 + 按钮
/// 2. 表单：多个输入框纵向排列
/// 3. 卡片内的"图片 + 标题 + 描述"
/// 4. 设置页的多行条目
class ColumnDemo extends StatelessWidget {
  const ColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 示例 1：mainAxisAlignment——需要给 Column 一个固定高度才能看出效果
          _title('1. mainAxisAlignment（高度 160）'),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                for (final a in [
                  MainAxisAlignment.start,
                  MainAxisAlignment.center,
                  MainAxisAlignment.end,
                  MainAxisAlignment.spaceBetween,
                  MainAxisAlignment.spaceAround,
                  MainAxisAlignment.spaceEvenly,
                ])
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: a,
                        children: [
                          _box('A', Colors.red, w: 30, h: 30),
                          _box('B', Colors.green, w: 30, h: 30),
                          _box('C', Colors.blue, w: 30, h: 30),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '从左到右依次为：start / center / end / spaceBetween / spaceAround / spaceEvenly',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),

          // 示例 2：crossAxisAlignment
          _title('2. crossAxisAlignment: start / center / end / stretch'),
          for (final a in [
            CrossAxisAlignment.start,
            CrossAxisAlignment.center,
            CrossAxisAlignment.end,
            CrossAxisAlignment.stretch,
          ])
            Container(
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
              child: Column(
                crossAxisAlignment: a,
                children: [Container(color: Colors.orange, padding: const EdgeInsets.all(6), child: Text(a.name))],
              ),
            ),

          // 示例 3：mainAxisSize.min——Column 只包裹内容
          _title('3. mainAxisSize: min'),
          Center(
            child: Container(
              color: Colors.amber.shade100,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  Text('包裹内容'),
                ],
              ),
            ),
          ),

          // 示例 4：verticalDirection: up 反向排列
          _title('4. verticalDirection: up（从下往上）'),
          Center(
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: [_box('1', Colors.red), _box('2', Colors.green), _box('3', Colors.blue)],
            ),
          ),

          // 示例 5：Column 中放可伸缩区域——Expanded 分配剩余高度
          _title('5. Column + Expanded（固定高度 200）'),
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Container(
                  height: 40,
                  color: Colors.indigo,
                  alignment: Alignment.center,
                  child: const Text('Header 固定 40', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  child: Container(
                    color: Colors.lightGreen,
                    alignment: Alignment.center,
                    child: const Text('Expanded 占满剩余'),
                  ),
                ),
                Container(
                  height: 30,
                  color: Colors.indigo,
                  alignment: Alignment.center,
                  child: const Text('Footer 固定 30', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
