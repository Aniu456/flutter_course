import 'package:flutter/material.dart';

// 表格布局：Table。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _cell(String text, {bool header = false}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: TextStyle(fontWeight: header ? FontWeight.bold : FontWeight.normal)),
  );
}

/// ===================== Table =====================
///
/// 【是什么】
/// 按行列网格排列子组件，同一列宽度一致、同一行高度一致。
/// 每一行是一个 TableRow，所有 TableRow 的子组件数量必须相同。
///
/// 【属性】
/// - children: `List<TableRow>`，每行的 children 数量必须一致
/// - columnWidths: 每列宽度 `Map<int, TableColumnWidth>`
///   FixedColumnWidth(80) 固定 / FlexColumnWidth(2) 按比例 /
///   IntrinsicColumnWidth() 按内容（较耗性能）/ FractionColumnWidth(0.3) 按百分比
/// - defaultColumnWidth: 未指定的列使用的宽度，默认 FlexColumnWidth(1)
/// - border: TableBorder.all(...) / TableBorder.symmetric(...)
/// - defaultVerticalAlignment: 单元格垂直对齐
/// - TableRow.decoration: 整行背景（斑马纹、表头）
///
/// 【注意】
/// - Table 不能滚动、不能合并单元格；数据量大请用 ListView 或 DataTable
/// - 需要排序、选择行的数据表格可用 DataTable / PaginatedDataTable
///
/// 【常见使用场景】
/// 课程表、参数对照表、简单的数据展示、表单的标签-值对齐
class TableDemo extends StatelessWidget {
  const TableDemo({super.key});

  static const _rows = [('周一', '数学', '语文', '英语'), ('周二', '物理', '化学', '体育'), ('周三', 'Flutter', 'Dart', '算法')];

  @override
  Widget build(BuildContext context) {
    final headerColor = Theme.of(context).colorScheme.primaryContainer;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 课程表：TableBorder.all + 表头背景 + 斑马纹'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(6)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: headerColor),
                children: [
                  _cell('', header: true),
                  _cell('第1节', header: true),
                  _cell('第2节', header: true),
                  _cell('第3节', header: true),
                ],
              ),
              for (var i = 0; i < _rows.length; i++)
                TableRow(
                  decoration: BoxDecoration(color: i.isOdd ? Colors.grey.withValues(alpha: 0.1) : null),
                  children: [
                    _cell(_rows[i].$1, header: true),
                    _cell(_rows[i].$2),
                    _cell(_rows[i].$3),
                    _cell(_rows[i].$4),
                  ],
                ),
            ],
          ),
        ),
        _title('2. columnWidths：固定 80 / 按内容 / 剩余按比例 2:1'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: IntrinsicColumnWidth(),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
            },
            border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade400)),
            children: [
              TableRow(children: [_cell('固定80'), _cell('按内容宽'), _cell('flex 2'), _cell('flex 1')]),
              TableRow(children: [_cell('A'), _cell('IntrinsicColumnWidth'), _cell('B'), _cell('C')]),
            ],
          ),
        ),
        _title('3. 标签-值对齐（无边框）'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            columnWidths: const {0: IntrinsicColumnWidth()},
            children: [
              for (final (k, v) in [('姓名', '张三'), ('邮箱', 'zhangsan@example.com'), ('所在城市', '上海')])
                TableRow(children: [_cell('$k：', header: true), _cell(v)]),
            ],
          ),
        ),
      ],
    );
  }
}
