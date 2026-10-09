import 'package:flutter/material.dart';

// 显示与隐藏：Visibility / Offstage，以及与 Opacity、if 判断的对比。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// 带内部计数的方块：用来观察隐藏后"状态"是否还在。
class _StatefulBox extends StatefulWidget {
  const _StatefulBox(this.color);

  final Color color;

  @override
  State<_StatefulBox> createState() => _StatefulBoxState();
}

class _StatefulBoxState extends State<_StatefulBox> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _count++),
      child: Container(
        width: 90,
        height: 60,
        color: widget.color,
        alignment: Alignment.center,
        child: Text('点我 $_count', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// ===================== Visibility / Offstage =====================
///
/// 【是什么】
/// - Visibility：控制子组件显示 / 隐藏，可选择隐藏时是否保留空间、状态、动画、交互
/// - Offstage：offstage: true 时子组件仍然布局（仍在树中、状态保留），但不绘制、不占空间
///
/// 【Visibility 属性】
/// - visible: 是否显示
/// - replacement: 隐藏时显示的替代组件，默认 SizedBox.shrink()
/// - maintainState: 隐藏时是否保留 State（为 true 时内部用 Offstage 实现）
/// - maintainAnimation / maintainSize / maintainInteractivity: 依次叠加的保留选项，
///   maintainSize 需要前两个都为 true
///
/// 【几种"隐藏"方式对比】
/// | 方式                      | 占空间 | 保留状态 | 可点击 |
/// |---------------------------|--------|----------|--------|
/// | if (show) widget          | 否     | 否       | 否     |
/// | Visibility(visible:false) | 否     | 否       | 否     |
/// | Visibility + maintainState| 否     | 是       | 否     |
/// | Offstage(offstage: true)  | 否     | 是       | 否     |
/// | Visibility + maintainSize | 是     | 是       | 可选   |
/// | Opacity(opacity: 0)       | 是     | 是       | 是 ⚠️  |
///
/// 【注意】
/// - Offstage 中的子组件仍在布局、动画仍在跑，隐藏大量内容会浪费性能
/// - 只是简单的显示 / 不显示，直接用 if 最清晰
///
/// 【常见使用场景】
/// 根据权限显示按钮、折叠面板、Tab 预加载（Offstage / IndexedStack）
class VisibilityDemo extends StatefulWidget {
  const VisibilityDemo({super.key});

  @override
  State<VisibilityDemo> createState() => _VisibilityDemoState();
}

class _VisibilityDemoState extends State<VisibilityDemo> {
  bool _visible = true;

  Widget _row(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 12))),
          Container(color: Colors.grey.shade300, child: child),
          Container(width: 40, height: 60, color: Colors.black26, alignment: Alignment.center, child: const Text('邻居')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SwitchListTile(
          title: const Text('visible'),
          subtitle: const Text('先点几下各个色块让计数增加，再关闭开关、重新打开，观察计数是否保留'),
          value: _visible,
          onChanged: (v) => setState(() => _visible = v),
        ),
        _title('灰色背景 = 组件所占空间；"邻居"会不会移动 = 是否保留空间'),
        _row('if (visible)', _visible ? const _StatefulBox(Colors.red) : const SizedBox.shrink()),
        _row('Visibility 默认', Visibility(visible: _visible, child: const _StatefulBox(Colors.orange))),
        _row(
          'Visibility\nreplacement',
          Visibility(
            visible: _visible,
            replacement: const SizedBox(width: 90, height: 60, child: Center(child: Text('已隐藏'))),
            child: const _StatefulBox(Colors.amber),
          ),
        ),
        _row(
          'Visibility\nmaintainState',
          Visibility(visible: _visible, maintainState: true, child: const _StatefulBox(Colors.green)),
        ),
        _row(
          'Visibility\nmaintainSize',
          Visibility(
            visible: _visible,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: const _StatefulBox(Colors.teal),
          ),
        ),
        _row('Offstage', Offstage(offstage: !_visible, child: const _StatefulBox(Colors.blue))),
        _row('Opacity(0)', Opacity(opacity: _visible ? 1 : 0, child: const _StatefulBox(Colors.purple))),
      ],
    );
  }
}
