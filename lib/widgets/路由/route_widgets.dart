/// ===================== 路由 (Route / Navigator) 速查 =====================
///
/// 路由 = "页面 + 页面之间的跳转关系"。Flutter 里每个页面是一个 Route，
/// 所有 Route 由 Navigator 以"栈"的形式管理：push 入栈、pop 出栈。
///
/// | 场景                         | 用哪个 API                                              |
/// |------------------------------|---------------------------------------------------------|
/// | 跳到新页面                   | Navigator.push(MaterialPageRoute(...))                  |
/// | 返回上一页                   | Navigator.pop(context) / maybePop                       |
/// | 判断能否返回                 | Navigator.canPop(context)                               |
/// | 页面返回时带回数据           | await push`<T>`() + pop(context, result)                  |
/// | 给下一页传数据               | 构造函数 / pushNamed(arguments:) / onGenerateRoute      |
/// | 按名字跳转                   | MaterialApp.routes + Navigator.pushNamed                |
/// | 动态路径 / 参数解析 / 守卫   | MaterialApp.onGenerateRoute                             |
/// | 找不到路由时兜底（404）      | MaterialApp.onUnknownRoute                              |
/// | 替换当前页（启动页、登录页） | pushReplacement / pushReplacementNamed                  |
/// | 清空栈并进入新页（登录成功） | pushAndRemoveUntil(route, (r) => false)                 |
/// | 一次回退多层                 | popUntil / popAndPushNamed                              |
/// | 移除栈中间某一页             | removeRoute                                             |
/// | 自定义转场动画               | PageRouteBuilder + FadeTransition / SlideTransition ... |
/// | 共享元素动画                 | Hero（两个页面使用相同 tag）                            |
/// | 自下而上的全屏弹出页         | MaterialPageRoute(fullscreenDialog: true)               |
/// | 拦截返回键 / 二次确认退出    | PopScope(canPop, onPopInvokedWithResult)                |
/// | 底部导航且各 Tab 独立返回栈  | 每个 Tab 一个嵌套 Navigator + `GlobalKey<NavigatorState>` |
/// | 监听页面进入/离开            | NavigatorObserver / RouteObserver + RouteAware          |
/// | 深度链接 / Web URL / 复杂路由 | Router API（Navigator 2.0）或 go_router 等路由包       |
///
/// 说明：本项目的 main.dart 只有 `home:`，没有 routes 表，所以需要命名路由的示例
/// 都是在页面内部嵌入一个"独立的 Navigator"（带边框的小盒子）来演示，
/// 效果与真实 App 完全一致，只是作用范围限定在盒子内。
library;

import 'package:flutter/material.dart';

// ============================ 公共辅助 ============================

/// 带标题和说明的示例分组。
class _Section extends StatelessWidget {
  const _Section({required this.title, this.desc, required this.child});

  final String title;
  final String? desc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (desc != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(desc!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 固定高度、带边框的盒子，用来承载嵌套 Navigator。
class _NavBox extends StatelessWidget {
  const _NavBox({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

/// 通用演示页面：AppBar + 一组按钮/文字。
/// AppBar 会在 Navigator.canPop 为 true 时自动出现返回箭头。
class _DemoPage extends StatelessWidget {
  const _DemoPage({required this.title, this.color, this.children = const []});

  final String title;
  final Color? color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(title: Text(title), backgroundColor: color),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: children)],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.onPressed);

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}

/// 等宽字体的代码块（用于文字说明类示例）。
class _Code extends StatelessWidget {
  const _Code(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF263238), borderRadius: BorderRadius.circular(6)),
      child: SelectableText(
        code,
        style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 12, height: 1.4),
      ),
    );
  }
}

/// 允许在构建/路由回调期间安全更新的 ValueNotifier：
/// NavigatorObserver / RouteAware 的回调可能发生在 build 阶段，
/// 直接修改 value 会触发 "setState during build"，所以推迟到帧结束后。
class _SafeNotifier<T> extends ValueNotifier<T> {
  _SafeNotifier(super.value);

  bool _disposed = false;

  void setLater(T v) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) value = v;
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

// ============================ 1. Navigator 基础 ============================

/// ===================== Navigator 基础 =====================
///
/// 【是什么】
/// Navigator 是管理一组 Route 的"栈"组件。MaterialApp 内部自带一个根 Navigator，
/// 平时写的 `Navigator.of(context).push(...)` 就是往这个栈里压入新页面。
/// MaterialPageRoute 是 Material 风格的页面路由（Android 上从下往上淡入，
/// iOS 上从右往左滑入并支持边缘滑动返回）。
///
/// 路由栈概念图（栈顶是用户当前看到的页面）：
/// ```
///   push(C)              pop()
///  ┌────────┐          ┌────────┐
///  │ C 详情 │ <- 栈顶  │        │
///  ├────────┤          ├────────┤
///  │ B 列表 │          │ B 列表 │ <- 栈顶
///  ├────────┤          ├────────┤
///  │ A 首页 │          │ A 首页 │
///  └────────┘          └────────┘
/// ```
///
/// 【API / 参数】
/// - `Navigator.of(context).push<T>(Route<T>)`   入栈，返回 `Future<T?>`（页面出栈时完成）
/// - `Navigator.of(context).pop<T>([T result])`  栈顶出栈，result 会成为 push 的返回值
/// - Navigator.canPop(context)                  栈里是否还有可以返回的页面（栈深度 > 1）
/// - Navigator.maybePop(context)                "尝试返回"：会先询问 PopScope 是否允许，
///                                              不能返回时什么也不做；返回 `Future<bool>`
/// - MaterialPageRoute(builder:, settings:, maintainState:, fullscreenDialog:)
///     builder           构建页面的函数
///     settings          RouteSettings(name, arguments)，命名路由和观察者会用到
///     maintainState     页面被盖住后是否保留 State，默认 true
///     fullscreenDialog  是否以全屏弹窗方式出现（自下而上，AppBar 显示关闭按钮）
///
/// 【注意】
/// - pop 与 maybePop 的区别：pop 无视 PopScope 直接出栈（只剩一个页面时会报错/黑屏），
///   maybePop 会尊重 PopScope 并在最后一页时不动作，更安全；系统返回键走的就是 maybePop。
/// - `Navigator.of(context)` 找的是"离 context 最近的 Navigator"，
///   在嵌套 Navigator 里会得到内层栈；想操作最外层用 `rootNavigator: true`。
/// - 页面里的 context 必须在 Navigator 之下；在 MaterialApp 的同级创建的 context 会报
///   "Navigator operation requested with a context that does not include a Navigator"。
///
/// 【常见使用场景】
/// 1. 列表点击进入详情页，详情页返回
/// 2. 表单页完成后返回上一级
/// 3. 根据 canPop 决定是否显示返回按钮
class NavigatorBasicDemo extends StatelessWidget {
  const NavigatorBasicDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 示例 1：push 一个新页面，新页面里可以继续 push、pop、maybePop
        _Section(
          title: '1. push + MaterialPageRoute',
          desc: '点击进入第 1 层页面，页面里可继续压栈并观察 canPop / pop / maybePop',
          child: _Btn('push 第 1 层页面', () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _BasicPage(depth: 1)));
          }),
        ),

        // 示例 2：fullscreenDialog
        _Section(
          title: '2. fullscreenDialog',
          desc: '自下而上弹出，AppBar 左侧是关闭 (X) 而不是返回箭头',
          child: _Btn('以全屏弹窗方式 push', () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (_) => const _BasicPage(depth: 1, title: '全屏弹窗页'),
              ),
            );
          }),
        ),

        // 示例 3：栈概念图
        const _Section(
          title: '3. 路由栈示意',
          child: _Code(
            'push(A) -> [A]\n'
            'push(B) -> [A, B]\n'
            'push(C) -> [A, B, C]   <- C 是栈顶，用户看到的页面\n'
            'pop()   -> [A, B]\n'
            'canPop  -> true  (栈里还有 A、B)\n'
            'pop()   -> [A]\n'
            'canPop  -> false (只剩根页面，maybePop 不会有动作)',
          ),
        ),
      ],
    );
  }
}

class _BasicPage extends StatelessWidget {
  const _BasicPage({required this.depth, this.title});

  final int depth;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: title ?? '第 $depth 层页面',
      children: [
        Text('Navigator.canPop = ${Navigator.canPop(context)}'),
        _Btn('push 第 ${depth + 1} 层', () {
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _BasicPage(depth: depth + 1)));
        }),
        _Btn('pop', () => Navigator.of(context).pop()),
        _Btn('maybePop', () => Navigator.of(context).maybePop()),
      ],
    );
  }
}

// ============================ 2. 返回值 ============================

/// ===================== 路由返回值 =====================
///
/// 【是什么】
/// `push` 返回的是 `Future<T?>`：当被 push 的页面出栈时，Future 完成，
/// 值就是 `pop(context, result)` 传入的 result。这是"选择页 / 确认页把结果回传给上一页"
/// 的标准做法，不需要回调函数，也不需要全局状态。
///
/// 【API / 要点】
/// - `final r = await Navigator.of(context).push<String>(route);`   泛型 T 要和 pop 的类型一致
/// - `Navigator.of(context).pop('结果');`                           带结果返回
/// - 用户点 AppBar 返回箭头或系统返回键 -> 返回值是 null，所以接收方必须按可空处理
///
/// 【注意】
/// - await 之后再使用 context / setState，必须先检查 `mounted`（State 内）
///   或 `context.mounted`，否则触发 lint `use_build_context_synchronously`，
///   且页面已销毁时调用 setState 会报错。
/// - `push<T>` 的 T 写错（如 `push<int>` 却 pop 了 String）会在运行时抛类型转换异常。
/// - 如果要在 await 前后都用 Navigator，可先 `final nav = Navigator.of(context);`
///   缓存起来，这样 await 后不再需要用 context。
///
/// 【常见使用场景】
/// 1. 城市 / 联系人 / 日期选择页
/// 2. 编辑页保存后把新数据带回列表页
/// 3. 确认页返回 true / false
class RouteReturnValueDemo extends StatefulWidget {
  const RouteReturnValueDemo({super.key});

  @override
  State<RouteReturnValueDemo> createState() => _RouteReturnValueDemoState();
}

class _RouteReturnValueDemoState extends State<RouteReturnValueDemo> {
  String _fruit = '（尚未选择）';
  int _count = 0;

  Future<void> _pickFruit() async {
    final result = await Navigator.of(context)
        .push<String>(MaterialPageRoute<String>(builder: (_) => const _PickFruitPage()));
    // await 之后 State 可能已被销毁，先检查 mounted 再 setState
    if (!mounted) return;
    setState(() => _fruit = result ?? '（用户直接返回，结果为 null）');
  }

  Future<void> _editCount() async {
    final result = await Navigator.of(context)
        .push<int>(MaterialPageRoute<int>(builder: (_) => _CounterPage(initial: _count)));
    if (!mounted) return;
    if (result != null) setState(() => _count = result);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 示例 1：选择页回传字符串
        _Section(
          title: '1. await push<String> + pop(result)',
          desc: '选一个水果；若点左上角返回箭头，结果为 null',
          child: Row(
            children: [
              _Btn('去选择', _pickFruit),
              const SizedBox(width: 12),
              Expanded(child: Text('结果：$_fruit')),
            ],
          ),
        ),

        // 示例 2：编辑页回传 int，并处理 null
        _Section(
          title: '2. 编辑后回传，null 表示放弃',
          desc: '计数页点“保存”回传数字，点返回则保持原值',
          child: Row(children: [_Btn('编辑计数', _editCount), const SizedBox(width: 12), Text('当前值：$_count')]),
        ),
      ],
    );
  }
}

class _PickFruitPage extends StatelessWidget {
  const _PickFruitPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择水果')),
      body: ListView(
        children: [
          for (final f in const ['苹果', '香蕉', '橙子']) ListTile(title: Text(f), onTap: () => Navigator.of(context).pop(f)),
        ],
      ),
    );
  }
}

class _CounterPage extends StatefulWidget {
  const _CounterPage({required this.initial});

  final int initial;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑计数')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_value', style: const TextStyle(fontSize: 40)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => setState(() => _value--), icon: const Icon(Icons.remove)),
                IconButton(onPressed: () => setState(() => _value++), icon: const Icon(Icons.add)),
              ],
            ),
            _Btn('保存并返回', () => Navigator.of(context).pop(_value)),
          ],
        ),
      ),
    );
  }
}

// ============================ 3. 传参 ============================

/// 传参示例用的数据类。
class _UserArgs {
  const _UserArgs(this.id, this.name);

  final int id;
  final String name;
}

/// ===================== 路由传参 =====================
///
/// 【是什么】
/// 把数据交给下一个页面有三种常用方式，按推荐程度排序：
///
/// 1. 构造函数传参（推荐）：类型安全，编译期检查，IDE 能跳转。
///    `push(MaterialPageRoute(builder: (_) => UserPage(user: user)))`
/// 2. 命名路由 arguments：`pushNamed('/detail', arguments: obj)`，
///    目标页用 `ModalRoute.of(context)!.settings.arguments` 取出（Object?，需要强转）。
/// 3. onGenerateRoute 解析：在路由表中统一解析 `settings.name`（如 `/item/42`）
///    和 `settings.arguments`，转成构造函数参数，兼具命名路由与类型安全。
///
/// 【注意】
/// - `ModalRoute.of(context)` 依赖 InheritedWidget，要在 build 或
///   didChangeDependencies 里调用，不能在 initState 里调用。
/// - arguments 是 Object?，忘记传或类型不符时 `as` 强转会抛异常，
///   建议封装成专门的 Args 类并用 `is` 判断。
/// - 不要把大对象（图片字节、整个列表）塞进 arguments；传 id，到目标页再取。
/// - Web 上刷新页面 arguments 会丢失，需要保留的信息要放进 URL 路径或查询参数。
///
/// 【常见使用场景】
/// 1. 列表 -> 详情传 id / 模型
/// 2. 通知点击、深度链接携带参数跳转
/// 3. 路由统一鉴权后再构造页面
class RouteArgumentsDemo extends StatelessWidget {
  const RouteArgumentsDemo({super.key});

  // 示例中的“路由表”：集中解析路径与参数
  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);

    if (name == '/') {
      return MaterialPageRoute<void>(settings: settings, builder: (_) => const _ArgHome());
    }
    if (name == '/detail') {
      // 方式 2：页面自己用 ModalRoute 取 arguments
      return MaterialPageRoute<void>(settings: settings, builder: (_) => const _ArgDetailPage());
    }
    if (name == '/user') {
      // 方式 3：在 onGenerateRoute 中把 arguments 转成构造参数
      final args = settings.arguments;
      if (args is _UserArgs) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => _ArgInfoPage(title: '用户页', lines: ['id = ${args.id}', 'name = ${args.name}']),
        );
      }
    }
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'item') {
      // 路径参数：/item/42 -> id = 42
      final id = int.tryParse(uri.pathSegments[1]);
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _ArgInfoPage(title: '商品页', lines: ['路径 = $name', '解析出的 id = $id']),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _Section(title: '三种传参方式（盒子内是独立的 Navigator）', desc: '依次点击四个按钮进入对应页面，看页面如何拿到数据', child: SizedBox.shrink()),
        _NavBox(
          height: 320,
          child: Navigator(initialRoute: '/', onGenerateRoute: _onGenerateRoute),
        ),
      ],
    );
  }
}

class _ArgHome extends StatelessWidget {
  const _ArgHome();

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: '传参首页',
      children: [
        _Btn('① 构造函数传参', () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const _ArgInfoPage(title: '构造函数页', lines: ['text = Hello（直接传入构造函数）']),
            ),
          );
        }),
        _Btn('② pushNamed + arguments', () {
          Navigator.of(context).pushNamed('/detail', arguments: '来自首页的字符串');
        }),
        _Btn('③ onGenerateRoute 解析对象', () {
          Navigator.of(context).pushNamed('/user', arguments: const _UserArgs(7, '小明'));
        }),
        _Btn('④ 路径参数 /item/42', () {
          Navigator.of(context).pushNamed('/item/42');
        }),
      ],
    );
  }
}

class _ArgDetailPage extends StatelessWidget {
  const _ArgDetailPage();

  @override
  Widget build(BuildContext context) {
    // 在 build 中读取；arguments 是 Object?，先判断类型更安全
    final args = ModalRoute.of(context)!.settings.arguments;
    final text = args is String ? args : '（没有收到字符串参数）';
    return _ArgInfoPage(title: '详情页', lines: ['ModalRoute.of(context)!.settings.arguments', '= $text']);
  }
}

class _ArgInfoPage extends StatelessWidget {
  const _ArgInfoPage({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(title: title, children: [for (final l in lines) Text(l)]);
  }
}

// ============================ 4. 命名路由 ============================

/// ===================== 命名路由 =====================
///
/// 【是什么】
/// 给每个页面起一个字符串名字（如 `/settings`），用名字而不是 Route 对象跳转。
/// 名字到页面的映射由 MaterialApp 提供，查找顺序固定：
///   `home / initialRoute` -> `routes` 表 -> `onGenerateRoute` -> `onUnknownRoute`
///
/// 【MaterialApp 相关参数】
/// - routes:           `Map<String, WidgetBuilder>`，静态路由表（名字精确匹配）
/// - initialRoute:     启动时显示的路由名，默认 '/'
/// - onGenerateRoute:  routes 里找不到时调用，可解析动态路径、参数、做鉴权拦截
/// - onUnknownRoute:   onGenerateRoute 也返回 null 时兜底，常用来做 404 页
/// - home 与 routes 里的 '/' 不能同时存在，会触发断言
///
/// 【Navigator 方法】
/// - pushNamed(name, arguments:)             压入命名页面
/// - popAndPushNamed(name)                   先 pop 当前页再 push（有退出+进入两段动画）
/// - pushReplacementNamed(name)              用新页面替换当前页（当前页被销毁，不能返回）
/// - pushNamedAndRemoveUntil / popUntil      见"路由栈操作"
///
/// 【注意】
/// - 路由名写成常量（如 `static const settings = '/settings';`），避免拼写错误。
/// - 命名路由在传参类型安全、重构友好方面不如构造函数；官方对于复杂应用也推荐使用
///   Router API 或 go_router，但小项目用命名路由完全够用。
/// - 本 Demo 因为 main.dart 没有 routes 表，所以嵌入了一个"迷你 MaterialApp"来演示；
///   真实项目里把这些参数直接写到根 MaterialApp 即可。
///
/// 【常见使用场景】
/// 1. 多个入口复用同一页面（如通知、按钮、深度链接都跳到 /detail）
/// 2. 集中管理路由表，便于鉴权和埋点
/// 3. 未知路径显示 404 页面
class NamedRouteDemo extends StatelessWidget {
  const NamedRouteDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _Section(
          title: '迷你 MaterialApp：routes + initialRoute + onGenerateRoute + onUnknownRoute',
          desc: '尝试各个按钮；/gen/9 由 onGenerateRoute 处理，/nope 由 onUnknownRoute 处理',
          child: SizedBox.shrink(),
        ),
        _NavBox(
          height: 380,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {'/': (_) => const _NamedPage(), '/a': (_) => const _NamedPage(), '/b': (_) => const _NamedPage()},
            onGenerateRoute: (settings) {
              final name = settings.name ?? '';
              if (name.startsWith('/gen/')) {
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const _NamedPage(note: '由 onGenerateRoute 动态生成'),
                );
              }
              return null;
            },
            onUnknownRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const _NamedPage(note: '404：onUnknownRoute 兜底', error: true),
            ),
          ),
        ),
      ],
    );
  }
}

class _NamedPage extends StatelessWidget {
  const _NamedPage({this.note, this.error = false});

  final String? note;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final name = ModalRoute.of(context)?.settings.name ?? '?';
    final nav = Navigator.of(context);
    return _DemoPage(
      title: '路由名：$name',
      color: error ? Colors.red.shade50 : null,
      children: [
        if (note != null) Text(note!),
        _Btn('pushNamed /a', () => nav.pushNamed('/a')),
        _Btn('pushNamed /b', () => nav.pushNamed('/b')),
        _Btn('popAndPushNamed /b', () => nav.popAndPushNamed('/b')),
        _Btn('pushReplacementNamed /a', () => nav.pushReplacementNamed('/a')),
        _Btn('pushNamed /gen/9', () => nav.pushNamed('/gen/9')),
        _Btn('pushNamed /nope', () => nav.pushNamed('/nope')),
        _Btn('pop', () => nav.maybePop()),
      ],
    );
  }
}

// ============================ 5. 栈操作 ============================

/// 记录嵌套 Navigator 栈内容的观察者，同时负责生成带名字的页面。
class _StackTracker extends NavigatorObserver {
  final List<Route<dynamic>> routes = [];
  final _SafeNotifier<List<String>> names = _SafeNotifier<List<String>>(const []);
  int counter = 0;

  void _publish() {
    names.setLater([
      for (final r in routes)
        if (r.settings.name != null) r.settings.name!,
    ]);
  }

  void reset() {
    routes.clear();
    counter = 0;
    _publish();
  }

  Route<void> newRoute(String prefix) {
    final name = '$prefix${++counter}';
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => _StackPage(tracker: this, name: name),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
    _publish();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    _publish();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
    _publish();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : routes.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) {
      routes[i] = newRoute;
    }
    _publish();
  }

  void dispose() => names.dispose();
}

/// ===================== 路由栈操作 =====================
///
/// 【是什么】
/// 除了简单的 push / pop，Navigator 还能批量、定向地改写整个栈。
///
/// 【API】
/// - pushReplacement(route)
///     用新页面替换栈顶：[A, B] -> [A, C]。B 被销毁，用户无法回到 B。
///     场景：启动页(Splash)进入首页、登录页进入首页（保留更底层页面时）。
/// - pushAndRemoveUntil(route, predicate)
///     压入新页面，同时从栈顶往下移除，直到 predicate 返回 true 的那一页为止。
///     `(r) => false` 表示清空整个栈。场景：登录成功后清栈进入首页，退出登录回到登录页。
///     `ModalRoute.withName('/home')` 可以保留到某个名字的页面。
/// - popUntil(predicate)
///     连续 pop 直到 predicate 为 true；`(r) => r.isFirst` 回到根页面。
/// - removeRoute(route) / removeRouteBelow(anchor)
///     从栈中间删除指定页面（不播放动画），要先拿到 Route 对象（如通过 NavigatorObserver）。
/// - replace(oldRoute:, newRoute:)           替换栈中任意一页
///
/// 【注意】
/// - 清栈之后 canPop 为 false，Android 返回键会直接退出应用，这正是"登录后不能返回登录页"的目的。
/// - 被 remove 的页面不会触发 pop 动画，也不会让它的 push Future 以"正常返回"结束
///   （Future 会以 null 完成），接收返回值的一方要注意。
/// - 使用 Navigator.of(context) 之后若该页面被销毁（如 pushReplacement 之后），
///   不要再继续使用旧的 context。
///
/// 下面的示例中，盒子上方实时显示当前栈内容（栈底 -> 栈顶）。
///
/// 【常见使用场景】
/// 1. 启动页 -> 首页 (pushReplacement)
/// 2. 登录成功 -> 清栈进首页 (pushAndRemoveUntil)
/// 3. 多步骤表单完成后一次回到入口页 (popUntil)
/// 4. 退出登录 -> 清栈回到登录页
class RouteStackOpsDemo extends StatefulWidget {
  const RouteStackOpsDemo({super.key});

  @override
  State<RouteStackOpsDemo> createState() => _RouteStackOpsDemoState();
}

class _RouteStackOpsDemoState extends State<RouteStackOpsDemo> {
  final _StackTracker _tracker = _StackTracker();
  int _generation = 0;

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _Section(
          title: '当前路由栈（栈底 → 栈顶）',
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _tracker.names,
            builder: (_, names, _) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              child: Text(names.isEmpty ? '（空）' : names.join('  →  ')),
            ),
          ),
        ),
        _NavBox(
          height: 360,
          child: Navigator(
            key: ValueKey(_generation),
            observers: [_tracker],
            onGenerateRoute: (_) => _tracker.newRoute('启动页'),
          ),
        ),
        const SizedBox(height: 8),
        _Btn('重置示例', () {
          _tracker.reset();
          setState(() => _generation++);
        }),
      ],
    );
  }
}

class _StackPage extends StatelessWidget {
  const _StackPage({required this.tracker, required this.name});

  final _StackTracker tracker;
  final String name;

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return _DemoPage(
      title: name,
      children: [
        _Btn('push 新页', () => nav.push(tracker.newRoute('页面'))),
        _Btn('pushReplacement（启动页→首页）', () => nav.pushReplacement(tracker.newRoute('首页'))),
        _Btn('pushAndRemoveUntil 清栈（登录成功）', () {
          nav.pushAndRemoveUntil(tracker.newRoute('首页'), (route) => false);
        }),
        _Btn('popUntil 回到根页', () => nav.popUntil((route) => route.isFirst)),
        _Btn('removeRoute 删除下面一页', () {
          final rs = tracker.routes;
          if (rs.length >= 2) nav.removeRoute(rs[rs.length - 2]);
        }),
        _Btn('pop', () => nav.maybePop()),
      ],
    );
  }
}

// ============================ 6. 转场动画 ============================

/// ===================== 自定义转场动画 =====================
///
/// 【是什么】
/// MaterialPageRoute 的动画由平台决定。想要淡入、缩放、滑入等自定义效果时，
/// 使用 PageRouteBuilder，在 transitionsBuilder 里用动画组件包住新页面。
///
/// 【PageRouteBuilder 参数】
/// - pageBuilder:               构建页面 (context, animation, secondaryAnimation)
/// - transitionsBuilder:        构建转场 (context, animation, secondaryAnimation, child)
///     animation 是新页面进入/退出的 0→1 动画；secondaryAnimation 是"被盖住的页面"离开动画
/// - transitionDuration:        进入时长，默认 300ms
/// - reverseTransitionDuration: 返回时长
/// - opaque:                    是否不透明；false 时下面的页面仍可见（弹层效果）
/// - barrierColor / barrierDismissible / barrierLabel: 遮罩颜色、点击遮罩是否关闭
/// - fullscreenDialog:          MaterialPageRoute 的参数，自下而上弹出，AppBar 显示关闭按钮
///
/// 常用动画组件：FadeTransition(opacity)、SlideTransition(position: `Tween<Offset>`)、
/// ScaleTransition(scale)、RotationTransition(turns)，可嵌套组合。
/// 配合 CurvedAnimation 添加曲线（如 Curves.easeOutCubic）。
///
/// 【Hero】
/// 前后两个页面各放一个 tag 相同的 Hero，路由切换时 Flutter 会自动让它"飞"过去，
/// 实现共享元素动画。
///
/// 【注意】
/// - Hero 的 tag 在同一个页面内必须唯一，否则报错；列表里的 Hero 可用 id 做 tag。
/// - Hero 需要路由由带 HeroController 的 Navigator 驱动，MaterialApp 默认已提供；
///   自己创建嵌套 Navigator 时需要手动传入 observers: [HeroController()]。
/// - PageRouteBuilder 默认没有 iOS 侧滑返回手势；需要手势请使用 PageTransitionsTheme。
/// - 动画时长不宜超过 500ms，太慢会让用户觉得卡顿。
///
/// 【常见使用场景】
/// 1. 图片列表 -> 大图预览（Hero）
/// 2. 登录页淡入首页
/// 3. 半透明弹层页面（opaque: false）
/// 4. 新建内容的全屏弹窗页（fullscreenDialog）
class RouteTransitionDemo extends StatelessWidget {
  const RouteTransitionDemo({super.key});

  static Route<void> _fade(Widget page) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );

  static Route<void> _slide(Widget page) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(offset), child: child);
    },
  );

  static Route<void> _scale(Widget page) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );

  static Route<void> _overlay() => PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    barrierLabel: '关闭',
    pageBuilder: (context, _, _) => Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('opaque: false，下层页面仍可见', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              _Btn('关闭', () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    ),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );

  @override
  Widget build(BuildContext context) {
    void go(Route<void> route) => Navigator.of(context).push(route);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _Section(
          title: '1. FadeTransition / SlideTransition / ScaleTransition',
          child: Wrap(
            spacing: 8,
            children: [
              _Btn('淡入', () => go(_fade(const _DemoPage(title: '淡入页', color: Colors.lightBlue)))),
              _Btn('右侧滑入', () => go(_slide(const _DemoPage(title: '滑入页', color: Colors.lightGreen)))),
              _Btn('缩放 + 淡入', () => go(_scale(const _DemoPage(title: '缩放页', color: Colors.orangeAccent)))),
            ],
          ),
        ),
        _Section(
          title: '2. fullscreenDialog 与半透明弹层',
          child: Wrap(
            spacing: 8,
            children: [
              _Btn('fullscreenDialog', () {
                go(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const _DemoPage(title: '全屏弹窗页')));
              }),
              _Btn('opaque: false 弹层', () => go(_overlay())),
            ],
          ),
        ),
        _Section(
          title: '3. Hero 共享元素',
          desc: '点击下面的方块，两个页面中相同 tag 的 Hero 会"飞"过去',
          child: GestureDetector(
            onTap: () => go(_fade(const _HeroDetailPage())),
            child: const Hero(tag: 'route-demo-hero', child: _HeroBox(size: 80)),
          ),
        ),
      ],
    );
  }
}

class _HeroBox extends StatelessWidget {
  const _HeroBox({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(size / 6)),
      child: const Icon(Icons.star, color: Colors.white),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero 详情')),
      body: const Center(
        child: Hero(tag: 'route-demo-hero', child: _HeroBox(size: 240)),
      ),
    );
  }
}

// ============================ 7. PopScope ============================

/// ===================== PopScope 拦截返回 =====================
///
/// 【是什么】
/// PopScope 用来决定"当前页面能不能被返回"（系统返回键、iOS 侧滑、AppBar 返回箭头、
/// maybePop 都会经过它）。它取代了已废弃的 WillPopScope。
///
/// 【参数】
/// - canPop:                    是否允许直接出栈。false 时返回动作会被拦下
/// - onPopInvokedWithResult:    (bool didPop, T? result)；每次尝试返回都会回调
///     didPop == true  表示已经出栈了（canPop 为 true）
///     didPop == false 表示被拦截了，此时可弹出确认框，确认后再手动 `Navigator.pop`
/// - child:                     子组件
///
/// 【注意】
/// - 流程是：先拦截 → 询问用户 → 再主动 pop。在回调里手动 `Navigator.of(context).pop()`
///   是被允许的，不会再次被拦截。
/// - 回调里 await 之后要用 context，请提前缓存 `final nav = Navigator.of(context);`
///   或检查 `mounted`，避免 use_build_context_synchronously。
/// - canPop 可随状态动态变化（如"有未保存修改"才设为 false），不要永远设成 false，
///   否则用户无法正常返回，Android 上还可能导致无法退出应用。
/// - 旧的 `onPopInvoked(bool didPop)` 也已被 onPopInvokedWithResult 取代。
///
/// 【常见使用场景】
/// 1. 编辑页有未保存内容，返回前二次确认
/// 2. 首页"再按一次退出应用"
/// 3. 支付 / 上传过程中禁止返回
class PopScopeDemo extends StatelessWidget {
  const PopScopeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _Section(
          title: '1. 有未保存修改时，返回需确认',
          desc: '进入后输入文字，再点返回箭头 / 系统返回键',
          child: _Btn('打开编辑页', () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _ConfirmLeavePage()));
          }),
        ),
        _Section(
          title: '2. 二次确认退出（2 秒内连按两次）',
          child: _Btn('打开页面', () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _DoubleBackPage()));
          }),
        ),
      ],
    );
  }
}

class _ConfirmLeavePage extends StatefulWidget {
  const _ConfirmLeavePage();

  @override
  State<_ConfirmLeavePage> createState() => _ConfirmLeavePageState();
}

class _ConfirmLeavePageState extends State<_ConfirmLeavePage> {
  final TextEditingController _controller = TextEditingController();
  bool _dirty = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    final nav = Navigator.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('放弃修改？'),
        content: const Text('内容尚未保存，确定要离开吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('继续编辑')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('离开')),
        ],
      ),
    );
    if (leave == true && mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('编辑页')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: '输入任意内容后再返回'),
            onChanged: (v) {
              final dirty = v.isNotEmpty;
              if (dirty != _dirty) setState(() => _dirty = dirty);
            },
          ),
        ),
      ),
    );
  }
}

class _DoubleBackPage extends StatefulWidget {
  const _DoubleBackPage();

  @override
  State<_DoubleBackPage> createState() => _DoubleBackPageState();
}

class _DoubleBackPageState extends State<_DoubleBackPage> {
  DateTime? _last;

  void _onPop(bool didPop, Object? result) {
    if (didPop) return;
    final now = DateTime.now();
    if (_last != null && now.difference(_last!) < const Duration(seconds: 2)) {
      Navigator.of(context).pop();
      return;
    }
    _last = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('再按一次返回退出')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('再按一次退出')),
        body: const Center(child: Text('2 秒内连按两次返回才会离开')),
      ),
    );
  }
}

// ============================ 8. 嵌套 Navigator ============================

/// 路由变化时通知回调的观察者。
class _CallbackObserver extends NavigatorObserver {
  _CallbackObserver(this.onChanged);

  final VoidCallback onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => onChanged();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => onChanged();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => onChanged();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => onChanged();
}

/// ===================== 嵌套路由 / 底部导航保持各 Tab 独立栈 =====================
///
/// 【是什么】
/// 一个页面内部再放一个 Navigator，就拥有了独立的路由栈。
/// 典型用法是"底部导航 + 每个 Tab 一个 Navigator"：在 Tab A 里进入三层页面后切到 Tab B，
/// 再切回 A 时仍停留在第三层，底部导航栏始终可见。
///
/// 【实现要点】
/// - 每个 Tab：`Navigator(key: GlobalKey<NavigatorState>, onGenerateRoute: ...)`
/// - 用 IndexedStack 保存所有 Tab（切换时不销毁，状态得以保留）
/// - 返回键处理：根 Navigator 默认只会关闭整个页面，要先让"当前 Tab 的 Navigator"
///   消化返回事件：`PopScope(canPop: !当前Tab能否返回, onPopInvokedWithResult: (didPop, _) { 内层 maybePop })`
/// - 内层页面里 `Navigator.of(context)` 得到内层栈；要跳出到全屏页（隐藏底栏）用
///   `Navigator.of(context, rootNavigator: true).push(...)`
///
/// 【注意】
/// - 一定要给内层 Navigator 传 GlobalKey 并在 State 中持有，不能在 build 里每次 new，
///   否则每次重建栈都会丢失。
/// - IndexedStack 会同时构建所有 Tab，Tab 很多/很重时考虑懒加载。
/// - 嵌套 Navigator 里页面 AppBar 的返回箭头只会弹内层栈。
///
/// 【常见使用场景】
/// 1. 微信 / 淘宝式底部导航，各 Tab 页面栈互不影响
/// 2. 侧边栏 + 内容区的桌面 / 平板布局（内容区独立导航）
/// 3. 多步骤向导嵌在一个大页面里
class NestedNavigatorDemo extends StatefulWidget {
  const NestedNavigatorDemo({super.key});

  @override
  State<NestedNavigatorDemo> createState() => _NestedNavigatorDemoState();
}

class _NestedNavigatorDemoState extends State<NestedNavigatorDemo> {
  static const _tabs = ['首页', '发现', '我的'];

  final List<GlobalKey<NavigatorState>> _keys = List.generate(_tabs.length, (_) => GlobalKey<NavigatorState>());
  late final List<_CallbackObserver> _observers = List.generate(_tabs.length, (_) => _CallbackObserver(_refresh));
  int _index = 0;
  bool _innerCanPop = false;

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final can = _keys[_index].currentState?.canPop() ?? false;
      if (can != _innerCanPop) setState(() => _innerCanPop = can);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _Section(title: '每个 Tab 拥有独立的路由栈', desc: '在“首页”里连续 push 几层，切到“发现”再切回来，栈仍然保留', child: SizedBox.shrink()),
        _NavBox(
          height: 420,
          child: PopScope(
            canPop: !_innerCanPop,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _keys[_index].currentState?.maybePop();
            },
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Navigator(
                          key: _keys[i],
                          observers: [_observers[i]],
                          onGenerateRoute: (settings) => MaterialPageRoute<void>(
                            settings: settings,
                            builder: (_) => _TabPage(tab: _tabs[i], depth: 1),
                          ),
                        ),
                    ],
                  ),
                ),
                BottomNavigationBar(
                  currentIndex: _index,
                  onTap: (i) {
                    setState(() => _index = i);
                    _refresh();
                  },
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
                    BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.tab, required this.depth});

  final String tab;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: '$tab · 第 $depth 层',
      children: [
        _Btn('在本 Tab 内 push', () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _TabPage(tab: tab, depth: depth + 1),
            ),
          );
        }),
        _Btn('回到本 Tab 根页', () => Navigator.of(context).popUntil((r) => r.isFirst)),
      ],
    );
  }
}

// ============================ 9. 路由观察者 ============================

/// 汇总路由事件日志。
class _EventLog {
  final _SafeNotifier<List<String>> lines = _SafeNotifier<List<String>>(const []);
  final List<String> _items = [];

  void add(String s) {
    _items.add(s);
    lines.setLater(List.of(_items));
  }

  void clear() {
    _items.clear();
    lines.setLater(const []);
  }

  void dispose() => lines.dispose();
}

class _LogObserver extends NavigatorObserver {
  _LogObserver(this.log);

  final _EventLog log;

  String _n(Route<dynamic>? r) => r?.settings.name ?? '-';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.add('[Navigator] didPush ${_n(route)}（上一页 ${_n(previousRoute)}）');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      log.add('[Navigator] didPop ${_n(route)}（回到 ${_n(previousRoute)}）');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      log.add('[Navigator] didReplace ${_n(oldRoute)} → ${_n(newRoute)}');
}

/// ===================== NavigatorObserver / RouteObserver / RouteAware =====================
///
/// 【是什么】
/// - NavigatorObserver：挂到 Navigator.observers（MaterialApp.navigatorObservers）上，
///   能收到该 Navigator 所有的 didPush / didPop / didRemove / didReplace / didStartUserGesture 回调，
///   适合做全局的页面埋点、日志、统计。
/// - `RouteObserver<R extends Route>`：NavigatorObserver 的子类，额外支持"订阅某个具体页面"。
/// - RouteAware：页面 State 混入该接口并订阅后，能感知自己的四种状态变化：
///     didPush()      自己被压入栈（首次进入）
///     didPopNext()   盖在上面的页面被弹出，自己重新可见（返回到本页）
///     didPushNext()  有新页面盖到自己上面（自己被遮住）
///     didPop()       自己被弹出
///
/// 【使用步骤】
/// 1. 创建 `final routeObserver = RouteObserver<ModalRoute<void>>();`
/// 2. 注册：`MaterialApp(navigatorObservers: [routeObserver])`
/// 3. State `with RouteAware`，在 didChangeDependencies 里
///    `routeObserver.subscribe(this, ModalRoute.of(context)!)`
/// 4. dispose 里 `routeObserver.unsubscribe(this)`
///
/// 【注意】
/// - 一定要 unsubscribe，否则泄漏；订阅要放在 didChangeDependencies 而非 initState。
/// - 回调可能发生在 build 阶段，不要在里面直接 setState，需要刷新 UI 时延迟到帧后。
/// - 观察者只管它所注册的那个 Navigator；嵌套 Navigator 需单独注册。
/// - "从详情页返回后刷新列表" 用 didPopNext 比 await push 更通用。
///
/// 【常见使用场景】
/// 1. 页面曝光 / 停留时长埋点
/// 2. 返回到某页时刷新数据、恢复视频播放、暂停动画
/// 3. 页面被遮挡时暂停定时器 / 传感器
class RouteObserverDemo extends StatefulWidget {
  const RouteObserverDemo({super.key});

  @override
  State<RouteObserverDemo> createState() => _RouteObserverDemoState();
}

class _RouteObserverDemoState extends State<RouteObserverDemo> {
  final RouteObserver<ModalRoute<void>> _routeObserver = RouteObserver<ModalRoute<void>>();
  final _EventLog _log = _EventLog();
  late final _LogObserver _logObserver = _LogObserver(_log);

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _Section(
          title: '路由事件日志',
          desc: 'push / pop 之后观察 [Navigator]（全局观察者）与 [RouteAware]（页面自己）的回调顺序',
          child: SizedBox.shrink(),
        ),
        _NavBox(
          height: 280,
          child: Navigator(
            observers: [_routeObserver, _logObserver],
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              settings: const RouteSettings(name: '页面1'),
              builder: (_) => _AwarePage(name: '页面1', level: 1, observer: _routeObserver, log: _log),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('日志：', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: _log.clear, child: const Text('清空')),
          ],
        ),
        ValueListenableBuilder<List<String>>(
          valueListenable: _log.lines,
          builder: (_, lines, _) => Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Text(lines.isEmpty ? '（暂无事件）' : lines.join('\n'), style: const TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _AwarePage extends StatefulWidget {
  const _AwarePage({required this.name, required this.level, required this.observer, required this.log});

  final String name;
  final int level;
  final RouteObserver<ModalRoute<void>> observer;
  final _EventLog log;

  @override
  State<_AwarePage> createState() => _AwarePageState();
}

class _AwarePageState extends State<_AwarePage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) widget.observer.subscribe(this, route);
  }

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => widget.log.add('[RouteAware] ${widget.name} didPush（进入）');

  @override
  void didPopNext() => widget.log.add('[RouteAware] ${widget.name} didPopNext（上层页面返回，重新可见）');

  @override
  void didPushNext() => widget.log.add('[RouteAware] ${widget.name} didPushNext（被新页面盖住）');

  @override
  void didPop() => widget.log.add('[RouteAware] ${widget.name} didPop（被弹出）');

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: widget.name,
      children: [
        _Btn('push 下一页', () {
          final next = widget.level + 1;
          final name = '页面$next';
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              settings: RouteSettings(name: name),
              builder: (_) => _AwarePage(name: name, level: next, observer: widget.observer, log: widget.log),
            ),
          );
        }),
        _Btn('pop', () => Navigator.of(context).maybePop()),
      ],
    );
  }
}

// ============================ 10. 路由方案概览 ============================

/// ===================== 路由方案概览（文字说明） =====================
///
/// 【Navigator 1.0（命令式）】
/// - 本文件前面所有示例：push / pop / pushNamed。简单直观，学习成本低。
/// - 弱点：路由栈是"命令"的结果，难以由 URL 或应用状态直接推导；
///   Web 地址栏、浏览器前进后退、系统深度链接支持较弱。
///
/// 【Navigator 2.0（声明式 Router API）】
/// - 核心类：Router、RouterDelegate、RouteInformationParser、RouteInformationProvider、
///   `Navigator(pages: [...], onDidRemovePage: ...)`。
/// - 思想：路由栈 = 应用状态的函数；改变状态列表，页面栈自动变化。
/// - 优点：完美支持 URL、深度链接、浏览器前进后退；缺点：样板代码多、学习曲线陡，
///   所以实际开发通常使用封装好的包。
///
/// 【go_router / auto_route】
/// - go_router：Flutter 官方团队维护，基于 Router API，声明式路径（`/user/:id`），
///   支持重定向（登录守卫）、ShellRoute（底部导航保持状态）、深度链接、Web URL。
/// - auto_route：通过代码生成保证路由与参数类型安全，适合大型项目。
/// - 它们本质都是对 Router API 的封装。
///
/// 【深度链接 (Deep Link) 与 Web URL】
/// - 深度链接：点击 `myapp://shop/item/42` 或 `https://example.com/item/42` 直接打开 App 中的指定页面。
///   需要在 Android(intent-filter / App Links)、iOS(URL Types / Universal Links) 配置，
///   并且应用的路由系统要能把路径解析成页面栈。
/// - Web：地址栏 URL 与页面一一对应，刷新、分享、前进后退都依赖 Router API；
///   Navigator 1.0 的 arguments 在刷新后会丢失，所以重要信息应放进 URL。
/// - 简单应用不要求 URL 时，Navigator 1.0 + onGenerateRoute 的路径解析也可以处理基本的深度链接。
///
/// 【选型建议】
/// | 项目情况                                    | 推荐方案                       |
/// |---------------------------------------------|--------------------------------|
/// | 学习 / 小 Demo / 页面不多的 App              | Navigator 1.0（push / pushNamed） |
/// | 需要 Web URL、深度链接、登录重定向、Tab 保持栈 | go_router                      |
/// | 大型团队、强调类型安全的参数                 | auto_route 或 go_router_builder |
/// | 需要完全自定义路由行为                       | 直接实现 Router API            |
///
/// 【注意】
/// - 同一个 App 不建议混用多套路由体系；选好一种并统一封装跳转方法。
/// - 本项目不引入第三方包，下面的伪代码仅供理解，不能直接运行。
class RouterOverviewDemo extends StatelessWidget {
  const RouterOverviewDemo({super.key});

  static const _goRouterCode = r'''
// go_router 伪代码（需要依赖 go_router 包）
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = authState.isLoggedIn;
    if (!loggedIn && state.matchedLocation != '/login') return '/login';
    return null; // 不重定向
  },
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(
      path: '/user/:id',
      builder: (c, s) => UserPage(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
  ],
);

MaterialApp.router(routerConfig: router);

// 使用
context.go('/user/42');   // 替换整个栈到目标位置（URL 同步变化）
context.push('/user/42'); // 压栈，可返回
context.pop();''';

  static const _routerApiCode = r'''
// Router API 结构伪代码
MaterialApp.router(
  routeInformationParser: MyParser(),   // URL <-> 应用状态
  routerDelegate: MyDelegate(),         // 状态 -> 页面栈
);

class MyDelegate extends RouterDelegate<MyRoutePath> with ChangeNotifier {
  @override
  Widget build(BuildContext context) => Navigator(
        pages: [
          const MaterialPage(child: HomePage()),
          if (selectedId != null) MaterialPage(child: DetailPage(id: selectedId!)),
        ],
        onDidRemovePage: (page) { selectedId = null; notifyListeners(); },
      );
}''';

  static const _deepLinkCode = r'''
// Navigator 1.0 也能解析简单的深度链接
onGenerateRoute: (settings) {
  final uri = Uri.parse(settings.name ?? '/');
  if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'item') {
    return MaterialPageRoute(builder: (_) => ItemPage(id: uri.pathSegments[1]));
  }
  return null;
}''';

  Widget _card(String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _card('Navigator 1.0（命令式）', 'push / pop / pushNamed，写法简单，适合大多数小中型应用；对 URL 与深度链接支持弱。'),
        _card('Navigator 2.0（Router API，声明式）', '页面栈由应用状态推导，支持 URL、浏览器前进后退、深度链接；但样板代码多，一般通过路由包使用。'),
        _card('go_router', '官方维护的 Router API 封装：路径参数、重定向守卫、ShellRoute、深度链接，是多数新项目的首选。'),
        _card('auto_route', '基于代码生成的类型安全路由，适合大型项目与强类型参数。'),
        _card(
          '深度链接 / Web URL',
          '把 URL 或外部链接映射成页面栈；需要平台配置（App Links / Universal Links）并让路由系统可解析路径。Web 刷新会丢失 arguments，重要信息请放进 URL。',
        ),
        _card('选型建议', '学习与小项目：Navigator 1.0；需要 Web / 深度链接 / 登录守卫 / 保持 Tab 栈：go_router；追求强类型：auto_route。'),
        const _Section(title: 'go_router 示例（伪代码）', child: _Code(_goRouterCode)),
        const _Section(title: 'Router API 结构（伪代码）', child: _Code(_routerApiCode)),
        const _Section(title: '用 onGenerateRoute 解析简单深度链接', child: _Code(_deepLinkCode)),
      ],
    );
  }
}
