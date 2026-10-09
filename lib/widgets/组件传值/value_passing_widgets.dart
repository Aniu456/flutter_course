/// 组件传值：Flutter 中组件之间如何传递数据
///
/// 核心思想：Flutter 是"数据向下流、事件向上传"的单向数据流——
/// 数据通过构造函数 / InheritedWidget 向下流给子孙，
/// 子孙通过回调 / Notification 把事件向上通知给祖先，祖先修改状态后重新 build。
///
/// 【场景 → 推荐方式】
///
/// | 场景                           | 推荐方式                                  | Demo                          |
/// | ------------------------------ | ----------------------------------------- | ----------------------------- |
/// | 父 → 子（直接子级）            | 构造函数参数                              | ConstructorPassingDemo        |
/// | 子 → 父                        | 回调函数 VoidCallback / ValueChanged      | CallbackPassingDemo           |
/// | 兄弟组件互相通信               | 状态提升到共同父组件                      | LiftStateUpDemo               |
/// | 跨多层向下传（主题、用户信息） | InheritedWidget / InheritedNotifier       | InheritedWidgetPassingDemo    |
/// | 多个组件共享一份可变状态       | ValueNotifier / ChangeNotifier + 监听组件 | ValueNotifierPassingDemo      |
/// | 深层子孙向祖先汇报事件         | Notification + NotificationListener       | NotificationPassingDemo       |
/// | 父直接命令子（滚动、校验表单） | GlobalKey / Controller（谨慎使用）        | GlobalKeyPassingDemo          |
/// | 页面之间传值                   | push 构造参数 + pop 返回结果              | RoutePassingDemo              |
/// | 大型应用全局状态               | Provider / Riverpod / Bloc 等             | StateManagementOverviewDemo   |
///
/// 选择原则：能用最简单的方式就不用复杂的——
/// 构造函数 > 状态提升 > ValueNotifier > InheritedWidget > 第三方状态管理。
library;

import 'package:flutter/material.dart';

/// 各示例共用的小标题 + 内容卡片（仅本文件内部使用）
class _PassingSection extends StatelessWidget {
  const _PassingSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// 纯文字说明块（等宽字体，便于展示伪代码 / 图表）
class _PassingNote extends StatelessWidget {
  const _PassingNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
  }
}

/// ===================== 1. 构造函数传值（父 → 子） =====================
///
/// 【是什么】
/// 最基础、最常用的传值方式：父组件在创建子组件时，把数据作为构造函数参数传进去，
/// 子组件用 final 字段保存并在 build 中使用。
///
/// 【数据流向】
/// 父 ──(构造参数)──> 子，单向、只读。父组件 setState 重建后会用新参数创建新的
/// 子组件配置，子组件随之刷新。
///
/// 【属性/要点】
/// - final 字段:   Widget 是不可变的，所有字段必须 final
/// - required:     命名参数必填，漏传编译期报错
/// - 命名参数:     `{required this.title, this.count = 0}`，调用处可读性好
/// - 默认值:       可选参数写 `this.count = 0`，默认值必须是编译期常量
/// - 可空类型:     `String?` 表示可不传
/// - 传 Widget:    参数类型写 Widget，调用方可注入任意 UI（类似"插槽"），
///                 例如 Card 的 child、Scaffold 的 appBar
/// - 传函数:       参数类型写函数，见 CallbackPassingDemo
/// - super.key:    把 key 传给父类，几乎所有自定义组件都应保留
///
/// 【注意】
/// - 不要在 StatefulWidget 的 State 里修改 widget.xxx（它是 final 的）；
///   需要可变副本时在 initState 中复制，并在 didUpdateWidget 中处理参数变化
/// - 传值层级很深时会出现"层层透传"（prop drilling），此时考虑 InheritedWidget
/// - 能加 const 的构造一定加 const，可减少不必要的重建
///
/// 【常见使用场景】
/// 1. 列表项组件接收数据模型
/// 2. 通用按钮 / 卡片接收文字、颜色、图标
/// 3. 通过 Widget 参数定制布局区域（如自定义 AppBar 的 leading）
///
/// 【优缺点】
/// 优点：简单、类型安全、数据流向一目了然、编译期检查。
/// 缺点：只能逐层传递，层级深时繁琐；只能父传子，不能反向。
class ConstructorPassingDemo extends StatefulWidget {
  const ConstructorPassingDemo({super.key});

  @override
  State<ConstructorPassingDemo> createState() => _ConstructorPassingDemoState();
}

class _ConstructorPassingDemoState extends State<ConstructorPassingDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：required 与命名参数
          const _PassingSection(
            title: '1. required + 命名参数',
            child: _PassingProfileCard(name: '小明', age: 18),
          ),

          // 示例 2：使用默认值与可选参数
          const _PassingSection(
            title: '2. 默认值 / 可空参数（未传 age，显示默认值 0；传了 tag）',
            child: _PassingProfileCard(name: '小红', tag: 'VIP'),
          ),

          // 示例 3：父组件状态变化 → 新参数传给子组件
          _PassingSection(
            title: '3. 父组件 setState，子组件跟着刷新',
            // 用 Wrap 而不是 Row：窄屏手机上放不下时自动换行，避免溢出
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _PassingCountView(count: _count),
                ElevatedButton(onPressed: () => setState(() => _count++), child: const Text('父组件 +1')),
              ],
            ),
          ),

          // 示例 4：把 Widget 当参数传入（插槽）
          const _PassingSection(
            title: '4. 传 Widget 作为参数（插槽）',
            child: _PassingFrame(
              header: Text('我是外部传入的 header'),
              body: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('我是外部传入的 body'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PassingProfileCard extends StatelessWidget {
  const _PassingProfileCard({required this.name, this.age = 0, this.tag});

  final String name;
  final int age;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Text('$name，年龄 $age'),
        if (tag != null) ...[const SizedBox(width: 8), Chip(label: Text(tag!))],
      ],
    );
  }
}

class _PassingCountView extends StatelessWidget {
  const _PassingCountView({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Text('收到的 count = $count');
}

class _PassingFrame extends StatelessWidget {
  const _PassingFrame({required this.header, required this.body});

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold),
          child: header,
        ),
        const Divider(),
        body,
      ],
    );
  }
}

/// 自定义回调类型：一次带回多个参数
typedef PassingItemSelected = void Function(int index, String name);

/// ===================== 2. 回调函数传值（子 → 父） =====================
///
/// 【是什么】
/// 子组件无法直接修改父组件的数据，于是父组件把一个"函数"通过构造函数传给子组件，
/// 子组件在合适时机调用它，并把数据作为参数带回去，父组件在函数里 setState。
///
/// 【数据流向】
/// 子 ──(调用回调，携带数据)──> 父；配合构造函数传值就构成完整的双向通信：
/// 数据向下、事件向上。
///
/// 【属性/要点】
/// - VoidCallback:      `void Function()`，无参数无返回值，如 onPressed
/// - ValueChanged`<T>`:   `void Function(T value)`，携带一个新值，如 onChanged
/// - ValueSetter`<T>`:    与 ValueChanged 等价，语义偏"设置值"
/// - 自定义 typedef:    `typedef PassingItemSelected = void Function(int index, String name);`
///                      参数多时起别名，提高可读性
/// - 回调命名约定:      以 on 开头 + 动词，如 onTap、onChanged、onSubmitted
/// - 可选回调:          类型写成 `VoidCallback?`，调用时用 `onTap?.call()`
///
/// 【注意】
/// - 回调在父组件的 State 中执行，注意异步后用 `if (!mounted) return;`
/// - 不要在 build 中直接调用回调（会触发 build 期间 setState 的异常）
/// - 写 `onPressed: fn` 传引用，而不是 `onPressed: fn()`（那是立刻调用）
///
/// 【常见使用场景】
/// 1. 按钮点击、开关切换、输入框内容变化
/// 2. 列表项被选中 / 删除，通知列表页处理
/// 3. 自定义表单控件把值回传给表单
///
/// 【优缺点】
/// 优点：简单直观、类型安全、没有额外依赖。
/// 缺点：只能传给直接持有回调的父级，跨多层要层层转发。
class CallbackPassingDemo extends StatefulWidget {
  const CallbackPassingDemo({super.key});

  @override
  State<CallbackPassingDemo> createState() => _CallbackPassingDemoState();
}

class _CallbackPassingDemoState extends State<CallbackPassingDemo> {
  int _taps = 0;
  bool _switchValue = false;
  String _selected = '（未选择）';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：VoidCallback —— 只通知"发生了"，不带数据
          _PassingSection(
            title: '1. VoidCallback：点击了 $_taps 次',
            child: _PassingTapButton(onTap: () => setState(() => _taps++)),
          ),

          // 示例 2：ValueChanged<bool> —— 带回新值
          _PassingSection(
            title: '2. ValueChanged<bool>：开关 = $_switchValue',
            child: _PassingToggle(value: _switchValue, onChanged: (v) => setState(() => _switchValue = v)),
          ),

          // 示例 3：自定义 typedef，一次带回多个参数
          _PassingSection(
            title: '3. 自定义 typedef：选中 $_selected',
            child: _PassingChoiceList(
              items: const ['苹果', '香蕉', '橙子'],
              onSelected: (index, name) => setState(() => _selected = '#$index $name'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PassingTapButton extends StatelessWidget {
  const _PassingTapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ElevatedButton(onPressed: onTap, child: const Text('子组件按钮'));
}

class _PassingToggle extends StatelessWidget {
  const _PassingToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Switch(value: value, onChanged: onChanged);
}

class _PassingChoiceList extends StatelessWidget {
  const _PassingChoiceList({required this.items, required this.onSelected});

  final List<String> items;
  final PassingItemSelected onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < items.length; i++)
          ActionChip(label: Text(items[i]), onPressed: () => onSelected(i, items[i])),
      ],
    );
  }
}

/// ===================== 3. 状态提升（兄弟组件通信） =====================
///
/// 【是什么】
/// 兄弟组件之间没有直接的引用关系，无法直接互相传值。解决办法是把"共享的状态"
/// 提升到它们最近的共同父组件，由父组件持有状态：
/// 父把状态通过构造函数传给兄弟 A、B，A 通过回调通知父修改，父 setState 后 A、B 都刷新。
///
/// 【数据流向】
/// 兄弟 A ──回调──> 父(持有状态) ──构造参数──> 兄弟 B（以及 A 自己）
///
/// 【属性/要点】
/// - 找到共同父组件: 状态放在能覆盖所有使用者的"最低"祖先上，不要放太高
/// - 状态只有一份:   "单一数据源"，子组件只读，避免多份副本不同步
/// - 子组件尽量无状态: 用 StatelessWidget + 参数 + 回调，易复用、易测试
///
/// 【注意】
/// - 提升后父组件 build 范围变大，setState 会重建整个子树，
///   性能敏感处可把不变的子组件声明为 const，或改用 ValueNotifier 局部刷新
/// - 兄弟间隔了很多层时，层层转发会很繁琐，改用 InheritedWidget / 状态管理
///
/// 【常见使用场景】
/// 1. 筛选栏改变条件，列表同步刷新
/// 2. 输入框内容实时预览
/// 3. 购物车数量：商品列表加购，底部栏显示总数
///
/// 【优缺点】
/// 优点：思路统一、数据流清晰、无依赖。
/// 缺点：层级深时转发繁琐；父组件会承担较多逻辑。
class LiftStateUpDemo extends StatefulWidget {
  const LiftStateUpDemo({super.key});

  @override
  State<LiftStateUpDemo> createState() => _LiftStateUpDemoState();
}

class _LiftStateUpDemoState extends State<LiftStateUpDemo> {
  // 状态提升：两个兄弟共享的唯一数据源
  double _celsius = 25;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _PassingSection(
            title: '兄弟 A（滑块）修改 → 父组件 → 兄弟 B（显示）刷新',
            child: Column(
              children: [
                _PassingCelsiusSlider(value: _celsius, onChanged: (v) => setState(() => _celsius = v)),
                const SizedBox(height: 8),
                _PassingFahrenheitText(celsius: _celsius),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _PassingNote(
              '        Parent(State: _celsius)\n'
              '         /                  \\\n'
              '  Slider(A)  --onChanged-->  父 setState\n'
              '  Text(B)   <--celsius----   父 build',
            ),
          ),
        ],
      ),
    );
  }
}

class _PassingCelsiusSlider extends StatelessWidget {
  const _PassingCelsiusSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(value: value, min: -20, max: 50, label: '${value.toStringAsFixed(1)}°C', onChanged: onChanged),
        ),
        SizedBox(width: 70, child: Text('${value.toStringAsFixed(1)} °C')),
      ],
    );
  }
}

class _PassingFahrenheitText extends StatelessWidget {
  const _PassingFahrenheitText({required this.celsius});

  final double celsius;

  @override
  Widget build(BuildContext context) {
    final f = celsius * 9 / 5 + 32;
    return Text('华氏温度：${f.toStringAsFixed(1)} °F');
  }
}

/// ===================== 4. InheritedWidget（跨层级传值） =====================
///
/// 【是什么】
/// InheritedWidget 是 Flutter 内置的"向下共享数据"机制：放在树的上层，
/// 任意深度的子孙都可以通过 context 直接取到数据，无需层层传参。
/// Theme、MediaQuery、Directionality 都是 InheritedWidget。
///
/// 【数据流向】
/// 祖先(InheritedWidget 持有数据) ──context 查找──> 任意后代，只读向下。
///
/// 【属性/要点】
/// - updateShouldNotify(old):  数据变化时返回 true，才会通知依赖者重建
/// - context.dependOnInheritedWidgetOfExactType`<T>`():
///     查找最近的 T 并"注册依赖"，T 更新后当前组件会重建
/// - context.getInheritedWidgetOfExactType`<T>`():
///     只查找、不注册依赖，之后不会因更新而重建（用于只读一次）
/// - of(context) 约定:  `static PassingUserScope of(BuildContext context)`
///     封装查找逻辑，找不到时给出清晰的断言信息；maybeOf 返回可空
/// - InheritedNotifier`<T extends Listenable>`:
///     内部持有 Listenable（如 ChangeNotifier），其 notifyListeners
///     会自动让依赖者重建，不必自己重新创建 InheritedWidget
/// - InheritedModel:   可按"方面(aspect)"精确依赖，只在关心的部分变化时重建
///
/// 【注意】
/// - InheritedWidget 本身不可变，想"修改"数据需要：
///   ① 放在 StatefulWidget 的 build 里，用 setState 重建；
///   ② 或使用 InheritedNotifier + ChangeNotifier
/// - 在 initState 中不能使用 dependOn...（此时依赖尚未建立），
///   应放在 didChangeDependencies 或 build 中
/// - 查找的 context 必须在 InheritedWidget 之下，否则找不到（常用 Builder 解决）
/// - 本文件类名加 Passing 前缀，避免与 state_widgets.dart 中的类重名
///
/// 【常见使用场景】
/// 1. 主题 / 语言 / 用户登录信息等全局只读配置
/// 2. 深层组件共享同一个 Controller / Store
/// 3. 作为 Provider 等状态管理库的底层原理
///
/// 【优缺点】
/// 优点：官方内置、跨任意层级、只重建依赖者。
/// 缺点：样板代码多；"修改数据"需要配合 State 或 Notifier；粒度较粗。
class InheritedWidgetPassingDemo extends StatefulWidget {
  const InheritedWidgetPassingDemo({super.key});

  @override
  State<InheritedWidgetPassingDemo> createState() => _InheritedWidgetPassingDemoState();
}

class _InheritedWidgetPassingDemoState extends State<InheritedWidgetPassingDemo> {
  String _userName = '游客';
  final PassingCounterModel _model = PassingCounterModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：普通 InheritedWidget + setState 重建
          PassingUserScope(
            userName: _userName,
            child: _PassingSection(
              title: '1. InheritedWidget：中间层不传参，深层组件直接读取',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PassingMiddleLayer(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(onPressed: () => setState(() => _userName = '小明'), child: const Text('登录为小明')),
                      OutlinedButton(onPressed: () => setState(() => _userName = '游客'), child: const Text('退出')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 示例 2：InheritedNotifier —— 数据可变，无需 setState
          PassingCounterScope(
            notifier: _model,
            child: const _PassingSection(
              title: '2. InheritedNotifier：深层组件读取并修改',
              child: Row(children: [_PassingCounterText(), SizedBox(width: 12), _PassingCounterButton()]),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 示例 1：只读用户信息
class PassingUserScope extends InheritedWidget {
  const PassingUserScope({super.key, required this.userName, required super.child});

  final String userName;

  /// of(context) 约定：找不到时直接报清晰的错误
  static PassingUserScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'context 之上没有 PassingUserScope');
    return scope!;
  }

  static PassingUserScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PassingUserScope>();
  }

  @override
  bool updateShouldNotify(PassingUserScope oldWidget) => userName != oldWidget.userName;
}

class _PassingMiddleLayer extends StatelessWidget {
  const _PassingMiddleLayer();

  // 注意：这里没有任何 userName 参数
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.only(left: 12), child: _PassingDeepLayer());
}

class _PassingDeepLayer extends StatelessWidget {
  const _PassingDeepLayer();

  @override
  Widget build(BuildContext context) {
    final name = PassingUserScope.of(context).userName;
    return Text('深层组件读到的用户：$name');
  }
}

/// 示例 2：可变的计数模型
class PassingCounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class PassingCounterScope extends InheritedNotifier<PassingCounterModel> {
  const PassingCounterScope({super.key, required PassingCounterModel notifier, required super.child})
    : super(notifier: notifier);

  static PassingCounterModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PassingCounterScope>();
    assert(scope != null, 'context 之上没有 PassingCounterScope');
    return scope!.notifier!;
  }
}

class _PassingCounterText extends StatelessWidget {
  const _PassingCounterText();

  @override
  Widget build(BuildContext context) => Text('计数 = ${PassingCounterScope.of(context).count}');
}

class _PassingCounterButton extends StatelessWidget {
  const _PassingCounterButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: PassingCounterScope.of(context).increment, child: const Text('+1'));
  }
}

/// ===================== 5. ValueNotifier / ChangeNotifier =====================
///
/// 【是什么】
/// 观察者模式的内置实现：数据放在一个 Listenable 对象中，需要的组件去"监听"，
/// 数据变化时只刷新这些监听者，不需要 setState，也不需要共同父组件持有状态。
///
/// 【数据流向】
/// 任何持有 notifier 引用的地方修改数据 ──notifyListeners──> 所有监听者刷新。
///
/// 【属性/要点】
/// - ValueNotifier`<T>`:  持有单个值 value，赋新值（!= 旧值）自动通知；
///                      对 List / 对象内部修改不会触发，需重新赋值新对象
/// - ChangeNotifier:    自定义模型 `class Cart extends ChangeNotifier`，
///                      修改字段后手动 notifyListeners()
/// - ValueListenableBuilder`<T>`: 监听 ValueListenable，builder(context, value, child)；
///                      child 参数用于放不变的子树，避免重建
/// - ListenableBuilder: 监听任意 Listenable（如 ChangeNotifier）
///                      builder(context, child)
/// - addListener / removeListener: 手动订阅，需要成对出现
/// - dispose():         创建者负责释放，否则内存泄漏
///
/// 【注意】
/// - 谁创建谁 dispose，一般在 State.dispose 中调用
/// - dispose 之后再调用 notifyListeners 会报错
/// - 把 notifier 传给其他组件的方式：构造函数 / InheritedWidget / 全局变量
///   （全局单例简单但不易测试，小项目可用）
///
/// 【常见使用场景】
/// 1. 局部刷新：计数器、进度、开关，避免整页 setState
/// 2. 多个不相关组件共享一份状态
/// 3. 简易的购物车、设置、主题切换
///
/// 【优缺点】
/// 优点：官方内置、粒度细、写法短、无需父组件。
/// 缺点：需要手动管理生命周期；复杂依赖、异步状态需自行组织。
class ValueNotifierPassingDemo extends StatefulWidget {
  const ValueNotifierPassingDemo({super.key});

  @override
  State<ValueNotifierPassingDemo> createState() => _ValueNotifierPassingDemoState();
}

class _ValueNotifierPassingDemoState extends State<ValueNotifierPassingDemo> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final PassingCartModel _cart = PassingCartModel();

  @override
  void dispose() {
    _counter.dispose();
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 本方法不依赖 _counter / _cart 的值，修改它们不会触发整页重建
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：ValueNotifier + ValueListenableBuilder，两个不相关组件共享
          _PassingSection(
            title: '1. ValueNotifier：按钮与显示是独立组件',
            child: Row(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _counter,
                  builder: (context, value, child) => Text('count = $value'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: () => _counter.value++, child: const Text('+1')),
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _counter,
                  builder: (context, value, child) => Chip(label: Text(value.isEven ? '偶数' : '奇数')),
                ),
              ],
            ),
          ),

          // 示例 2：ChangeNotifier + ListenableBuilder
          _PassingSection(
            title: '2. ChangeNotifier + ListenableBuilder：购物车',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListenableBuilder(
                  listenable: _cart,
                  builder: (context, child) => Text(
                    '商品：${_cart.items.isEmpty ? '空' : _cart.items.join('、')}'
                    '（共 ${_cart.items.length} 件）',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(onPressed: () => _cart.add('商品${_cart.items.length + 1}'), child: const Text('添加')),
                    OutlinedButton(onPressed: _cart.clear, child: const Text('清空')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class PassingCartModel extends ChangeNotifier {
  final List<String> _items = [];

  /// 对外只读视图，防止绕过 notifyListeners 修改
  List<String> get items => List.unmodifiable(_items);

  void add(String item) {
    _items.add(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// ===================== 6. Notification（子向祖先冒泡） =====================
///
/// 【是什么】
/// Notification 是沿 Widget 树"向上冒泡"的事件机制。后代调用 `dispatch(context)`
/// 发出通知，祖先用 NotificationListener 接收。ScrollNotification 就是典型例子。
///
/// 【数据流向】
/// 后代 ──dispatch──> 逐级向上 ──> 最近的匹配 NotificationListener（可继续上传）。
///
/// 【属性/要点】
/// - 自定义通知:      `class MyNotification extends Notification { final ...; }`
/// - dispatch(context): 从该 context 所在位置开始向上派发
/// - NotificationListener`<T>`: 只接收类型为 T 的通知
/// - onNotification:  返回 true 表示"已处理，停止冒泡"；
///                    返回 false 继续向上传给更上层的监听器
///
/// 【注意】
/// - 必须是后代 → 祖先，兄弟、父 → 子都收不到
/// - dispatch 用的 context 必须在监听器之下（必要时用 Builder）
/// - 通知是同步的，不要在监听回调里做耗时操作
/// - 中间层无需知道通知的存在，耦合低；但数据流不如回调直观，不要滥用
///
/// 【常见使用场景】
/// 1. 监听滚动位置（ScrollNotification）做回到顶部按钮、导航栏渐变
/// 2. 深层表单项通知外层"内容已修改"
/// 3. 封装组件库，子组件向外层容器汇报事件
///
/// 【优缺点】
/// 优点：中间层不需要转发回调，解耦；可被多层拦截。
/// 缺点：隐式、不易追踪；只支持向上；无返回值。
class NotificationPassingDemo extends StatefulWidget {
  const NotificationPassingDemo({super.key});

  @override
  State<NotificationPassingDemo> createState() => _NotificationPassingDemoState();
}

class _NotificationPassingDemoState extends State<NotificationPassingDemo> {
  int _score = 0;
  String _lastScroll = '（尚未滚动）';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：自定义 Notification
          _PassingSection(
            title: '1. 自定义 Notification：总分 $_score',
            child: NotificationListener<PassingScoreNotification>(
              onNotification: (n) {
                setState(() => _score += n.delta);
                return true; // 已处理，不再向上冒泡
              },
              child: const _PassingNotifyMiddle(),
            ),
          ),

          // 示例 2：系统的 ScrollNotification
          _PassingSection(
            title: '2. ScrollNotification：$_lastScroll',
            child: SizedBox(
              height: 100,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  final text = '滚动偏移 ${n.metrics.pixels.toStringAsFixed(0)}';
                  if (text != _lastScroll) {
                    // 滚动通知可能在布局阶段派发，延后到帧结束再 setState
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _lastScroll = text);
                    });
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (context, i) => ListTile(dense: true, title: Text('第 $i 行')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class PassingScoreNotification extends Notification {
  const PassingScoreNotification(this.delta);

  final int delta;
}

class _PassingNotifyMiddle extends StatelessWidget {
  const _PassingNotifyMiddle();

  // 中间层完全不知道通知的存在
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(4), child: _PassingNotifyButtons());
}

class _PassingNotifyButtons extends StatelessWidget {
  const _PassingNotifyButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => const PassingScoreNotification(10).dispatch(context),
          child: const Text('+10 分'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => const PassingScoreNotification(-5).dispatch(context),
          child: const Text('-5 分'),
        ),
      ],
    );
  }
}

/// ===================== 7. GlobalKey（父直接调用子 State） =====================
///
/// 【是什么】
/// GlobalKey 在整个应用内唯一，可以拿到对应 Widget 的 State 对象
/// （`key.currentState`）、Element（`currentContext`）或 RenderObject，
/// 从而让父组件"命令式"地直接调用子 State 的公开方法。
///
/// 【数据流向】
/// 父 ──key.currentState?.method()──> 子 State（命令式，绕过构造参数）。
///
/// 【属性/要点】
/// - `GlobalKey<MyState>()`: 创建并保存在父 State 的字段中，不要在 build 里新建
/// - currentState:         可能为 null（组件未挂载时），必须用 `?.` 判断
/// - currentContext:       可用于获取尺寸、位置、Scrollable.ensureVisible
/// - 官方典型用法:        `GlobalKey<FormState>` 调用 validate/save，
///                        `GlobalKey<ScaffoldState>`、NavigatorState 等
///
/// 【注意 / 不推荐的原因】
/// 1. 破坏单向数据流，父子强耦合，子 State 类必须公开，重构困难
/// 2. currentState 可能为 null，调用时机不当会失效
/// 3. GlobalKey 较重，需要全局注册；同一 key 不能同时用于两个组件
/// 4. 命令式代码难以测试、难以追踪状态来源
/// 替代方案：优先用 Controller（如 TextEditingController、ScrollController，
/// 本质也是 Listenable）、回调或状态提升；只有 Form 校验等官方约定场景才用。
///
/// 【常见使用场景】
/// 1. 表单整体校验 / 重置（FormState）
/// 2. 调用 ScaffoldMessenger / Navigator 的方法
/// 3. 获取某组件的位置和大小
///
/// 【优缺点】
/// 优点：能直接调用，快速解决"命令子组件做事"的需求。
/// 缺点：强耦合、隐式、可空、难测试，属于"最后手段"。
class GlobalKeyPassingDemo extends StatefulWidget {
  const GlobalKeyPassingDemo({super.key});

  @override
  State<GlobalKeyPassingDemo> createState() => _GlobalKeyPassingDemoState();
}

class _GlobalKeyPassingDemoState extends State<GlobalKeyPassingDemo> {
  final GlobalKey<PassingCounterPanelState> _panelKey = GlobalKey<PassingCounterPanelState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _formResult = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：父组件直接调用子 State 的方法
          _PassingSection(
            title: '1. 自定义子 State：父调用 increase / reset',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PassingCounterPanel(key: _panelKey),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(onPressed: () => _panelKey.currentState?.increase(), child: const Text('父：让子 +1')),
                    OutlinedButton(onPressed: () => _panelKey.currentState?.reset(), child: const Text('父：让子重置')),
                  ],
                ),
              ],
            ),
          ),

          // 示例 2：官方推荐的 GlobalKey 用法——Form 校验
          _PassingSection(
            title: '2. GlobalKey<FormState>：validate() 校验',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '姓名（必填）'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '姓名不能为空' : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final ok = _formKey.currentState?.validate() ?? false;
                      setState(() => _formResult = ok ? '校验通过' : '校验失败');
                    },
                    child: const Text('提交'),
                  ),
                  if (_formResult.isNotEmpty) Text(_formResult),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 被 GlobalKey 访问的子组件；State 必须公开才能在外部使用其类型
class PassingCounterPanel extends StatefulWidget {
  const PassingCounterPanel({super.key});

  @override
  State<PassingCounterPanel> createState() => PassingCounterPanelState();
}

class PassingCounterPanelState extends State<PassingCounterPanel> {
  int _value = 0;

  void increase() => setState(() => _value++);

  void reset() => setState(() => _value = 0);

  @override
  Widget build(BuildContext context) => Text('子组件内部的值：$_value');
}

/// ===================== 8. 页面间传值（路由） =====================
///
/// 【是什么】
/// 页面（Route）本质也是 Widget，页面间传值沿用同样的原则：
/// 去程用构造函数传参，返程用 `Navigator.pop(context, result)` 携带结果。
///
/// 【数据流向】
/// A 页 ──push(构造参数)──> B 页；B 页 ──pop(result)──> A 页 `await` 拿到结果。
///
/// 【属性/要点】
/// - 传参:     `Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(id: 1)))`
/// - 取结果:   `final r = await Navigator.push<String>(...)`；
///             用户点返回键关闭页面时 r 为 null，必须处理
/// - 返回:     `Navigator.pop(context, '结果')`
/// - 命名路由: `pushNamed(context, '/detail', arguments: obj)`，
///             目标页用 `ModalRoute.of(context)?.settings.arguments` 读取
///             （类型不安全，复杂项目建议用 go_router 等方案）
///
/// 【注意】
/// - await 之后使用 context 前先判断 mounted
/// - 页面之间需要大量共享数据时，不要靠参数传递，应使用全局状态管理
/// - 详细的路由用法请查看"导航 / 路由"相关目录
///
/// 【常见使用场景】
/// 1. 列表 → 详情页传 id / 模型
/// 2. 选择器页面（选城市、选联系人）返回选择结果
/// 3. 确认页返回 true / false
///
/// 【优缺点】
/// 优点：与普通构造传参一致、类型安全（`push<T>`）。
/// 缺点：只适合相邻页面一次性传值，不适合跨多个页面共享。
class RoutePassingDemo extends StatefulWidget {
  const RoutePassingDemo({super.key});

  @override
  State<RoutePassingDemo> createState() => _RoutePassingDemoState();
}

class _RoutePassingDemoState extends State<RoutePassingDemo> {
  String _result = '（尚无返回结果）';

  Future<void> _openPicker() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const _PassingPickerPage(title: '选择水果', options: ['苹果', '香蕉', '橙子']),
      ),
    );
    if (!mounted) return;
    setState(() => _result = picked ?? '（用户直接返回，没有选择）');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _PassingSection(
            title: '1. push 传构造参数 + pop 返回结果',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(onPressed: _openPicker, child: const Text('打开选择页')),
                const SizedBox(height: 8),
                Text('返回结果：$_result'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _PassingNote(
              'A: final r = await Navigator.push<String>(\n'
              '     context, MaterialPageRoute(builder: (_) => B(title: ..)));\n'
              'B: Navigator.pop(context, "苹果");   // r == "苹果"',
            ),
          ),
        ],
      ),
    );
  }
}

class _PassingPickerPage extends StatelessWidget {
  const _PassingPickerPage({required this.title, required this.options});

  final String title;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          for (final option in options) ListTile(title: Text(option), onTap: () => Navigator.of(context).pop(option)),
        ],
      ),
    );
  }
}

/// ===================== 9. 状态管理方案概览 =====================
///
/// 【是什么】
/// 当应用变大、状态要被很多页面共享时，上面的手动方式会变得繁琐，
/// 社区提供了各种状态管理库。它们的本质都是：
/// "把状态放到组件树之外或之上 + 让需要的组件订阅 + 状态变化只刷新订阅者"。
/// 本文件不引入任何包，仅作概览（伪代码仅为示意，使用前请查阅各自官方文档）。
///
/// 【方案对比】
/// | 方案     | 核心思想                                  | 学习成本 | 适用规模         |
/// | -------- | ----------------------------------------- | -------- | ---------------- |
/// | Provider | InheritedWidget 的封装 + ChangeNotifier   | 低       | 小 ~ 中型        |
/// | Riverpod | Provider 作者的升级版，不依赖 context     | 中       | 中 ~ 大型        |
/// | Bloc     | 事件(Event) → 状态(State) 的流，职责分明  | 中高     | 大型、团队协作   |
/// | GetX     | 状态 + 路由 + 依赖注入一体，写法最简      | 低       | 小 ~ 中型        |
/// | MobX 等  | 响应式 observable                         | 中       | 视团队偏好       |
///
/// 【注意】
/// - 先用好内置方案（setState、状态提升、ValueNotifier、InheritedWidget），
///   确实遇到"层层传递、难以维护"再引入库
/// - 一个项目尽量统一一种主方案，不要混用太多
/// - 选型要看团队熟悉度、测试要求、社区维护情况，而不是追新
///
/// 【选型建议】
/// 1. 学习阶段 / 小应用 / 原型：setState + ValueNotifier
/// 2. 中小型应用，想要官方推荐、简单：Provider
/// 3. 中大型、重视可测试与编译期安全：Riverpod
/// 4. 大型团队、业务流程复杂、需要清晰分层：Bloc
/// 5. 追求快速开发的个人项目：GetX（注意其耦合度较高）
///
/// 【优缺点】
/// 优点：规范化、可测试、粒度细、适合协作。
/// 缺点：引入依赖和学习成本，过度设计会让小项目更复杂。
class StateManagementOverviewDemo extends StatelessWidget {
  const StateManagementOverviewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          _PassingSection(
            title: '1. 状态管理方案：数据流图',
            child: _PassingNote(
              'Provider / Riverpod（订阅式）\n'
              '  Store(状态) --notify--> Consumer/watch 的 Widget\n'
              '  Widget --读取/调用方法--> Store\n'
              '\n'
              'Bloc（事件流）\n'
              '  UI --Event--> Bloc --State--> UI\n'
              '\n'
              'GetX（响应式）\n'
              '  Controller(.obs 变量) --Obx 自动订阅--> UI',
            ),
          ),
          _PassingSection(
            title: '2. Provider 伪代码',
            child: _PassingNote(
              'class Counter extends ChangeNotifier { ... }\n'
              '\n'
              '// 顶层注入\n'
              'ChangeNotifierProvider(\n'
              '  create: (_) => Counter(),\n'
              '  child: MyApp(),\n'
              ')\n'
              '// 读取并订阅\n'
              'final c = context.watch<Counter>();\n'
              '// 只调用方法，不订阅\n'
              'context.read<Counter>().increment();',
            ),
          ),
          _PassingSection(
            title: '3. Riverpod 伪代码',
            child: _PassingNote(
              'final counterProvider = StateProvider<int>((ref) => 0);\n'
              '\n'
              'class Page extends ConsumerWidget {\n'
              '  Widget build(BuildContext context, WidgetRef ref) {\n'
              '    final n = ref.watch(counterProvider);\n'
              '    return ElevatedButton(\n'
              '      onPressed: () => ref.read(counterProvider.notifier).state++,\n'
              '      child: Text("\$n"),\n'
              '    );\n'
              '  }\n'
              '}',
            ),
          ),
          _PassingSection(
            title: '4. Bloc 伪代码',
            child: _PassingNote(
              'class CounterBloc extends Bloc<CounterEvent, int> {\n'
              '  CounterBloc() : super(0) {\n'
              '    on<Increment>((event, emit) => emit(state + 1));\n'
              '  }\n'
              '}\n'
              '\n'
              'BlocBuilder<CounterBloc, int>(\n'
              '  builder: (context, count) => Text("\$count"),\n'
              ')\n'
              'context.read<CounterBloc>().add(Increment());',
            ),
          ),
          _PassingSection(
            title: '5. GetX 伪代码',
            child: _PassingNote(
              'class CounterController extends GetxController {\n'
              '  final count = 0.obs;\n'
              '  void increment() => count++;\n'
              '}\n'
              '\n'
              'final c = Get.put(CounterController());\n'
              'Obx(() => Text("\${c.count}"));',
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
