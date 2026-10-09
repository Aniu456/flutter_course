import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'post_api.dart';

// 网络与异步：Future / async-await、JSON 模型、HTTP GET / POST、
// 加载-错误-空状态、下拉刷新、上拉加载更多。
//
// 速查：
// | 场景                     | 推荐方式                                        |
// |--------------------------|-------------------------------------------------|
// | 等待一个异步结果         | async / await + try / catch                     |
// | 多个请求并行             | Future.wait([...])                              |
// | 简单的一次性加载         | FutureBuilder（注意 Future 不要在 build 里创建） |
// | 需要重试 / 刷新 / 分页   | StatefulWidget 自己管理 loading / error / data  |
// | JSON → 对象              | fromJson / toJson（或 json_serializable）       |
// | 下拉刷新                 | RefreshIndicator(onRefresh: 返回 Future)        |
// | 上拉加载                 | ScrollController 监听滚动到底部                 |

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _code(BuildContext context, String text) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
  );
}

/// 加载中 / 出错 / 空数据 三种通用占位视图，多个示例复用。
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircularProgressIndicator(), SizedBox(height: 12), Text('加载中...')],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('暂无数据'),
          TextButton(onPressed: onReload, child: const Text('刷新看看')),
        ],
      ),
    );
  }
}

Widget _postTile(Post post) {
  return ListTile(
    leading: CircleAvatar(child: Text('${post.id}')),
    title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
}

/// ===================== Future 与 async / await =====================
///
/// 【是什么】
/// Future 表示"将来某个时刻才会有的结果"（网络、文件、定时器……）。
/// async / await 让异步代码写起来像同步代码一样从上往下执行。
///
/// 【常用 API】
/// - Future.delayed(duration, () => value)：延迟后返回值
/// - await future：等待结果（只能在 async 函数里用）
/// - try / catch / finally：捕获异步异常
/// - Future.wait([f1, f2])：并行执行，全部完成后一起返回
/// - future.timeout(duration)：超时抛 TimeoutException
/// - future.then(...).catchError(...)：回调写法，等价但嵌套多时可读性差
///
/// 【注意】
/// - await 之后 State 可能已经被销毁，调用 setState 前先判断 mounted
/// - 互不依赖的请求不要一个个 await，用 Future.wait 并行更快
/// - Dart 是单线程事件循环，耗时的 CPU 计算要用 Isolate.run / compute
///
/// 【常见使用场景】
/// 1. 网络请求、读写文件、数据库
/// 2. 延迟执行、倒计时
/// 3. 多个接口并行加载首页数据
class FutureAsyncDemo extends StatefulWidget {
  const FutureAsyncDemo({super.key});

  @override
  State<FutureAsyncDemo> createState() => _FutureAsyncDemoState();
}

class _FutureAsyncDemoState extends State<FutureAsyncDemo> {
  final List<String> _logs = [];
  bool _busy = false;

  Future<String> _fakeRequest(String name, int ms, {bool fail = false}) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (fail) throw Exception('$name 失败了');
    return '$name 完成（耗时 ${ms}ms）';
  }

  void _log(String text) => setState(() => _logs.add(text));

  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _logs.clear();
    });
    final watch = Stopwatch()..start();
    try {
      await task();
    } catch (e) {
      _log('❌ 捕获到异常：$e');
    } finally {
      if (mounted) {
        _log('总耗时 ${watch.elapsedMilliseconds}ms');
        setState(() => _busy = false);
      }
    }
  }

  // 顺序执行：一个接一个
  Future<void> _sequential() async {
    _log('开始顺序执行 A、B');
    _log(await _fakeRequest('请求 A', 800));
    if (!mounted) return;
    _log(await _fakeRequest('请求 B', 800));
  }

  // 并行执行：同时发出，一起等待
  Future<void> _parallel() async {
    _log('开始并行执行 A、B（Future.wait）');
    final results = await Future.wait([_fakeRequest('请求 A', 800), _fakeRequest('请求 B', 800)]);
    if (!mounted) return;
    results.forEach(_log);
  }

  // 异常：在 _run 里统一 catch
  Future<void> _error() async {
    _log('发起一个会失败的请求');
    await _fakeRequest('请求 C', 500, fail: true);
  }

  // 超时
  Future<void> _timeout() async {
    _log('请求需要 1500ms，但只等 500ms');
    try {
      await _fakeRequest('慢请求', 1500).timeout(const Duration(milliseconds: 500));
    } on TimeoutException {
      _log('⏰ TimeoutException：超时了');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('点击按钮，观察日志与耗时'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _busy ? null : () => _run(_sequential), child: const Text('顺序 await')),
              FilledButton(onPressed: _busy ? null : () => _run(_parallel), child: const Text('Future.wait 并行')),
              OutlinedButton(onPressed: _busy ? null : () => _run(_error), child: const Text('try / catch')),
              OutlinedButton(onPressed: _busy ? null : () => _run(_timeout), child: const Text('timeout')),
            ],
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        _title('日志'),
        _code(context, _logs.isEmpty ? '（暂无）' : _logs.join('\n')),
        _title('代码要点'),
        _code(
          context,
          'Future<void> load() async {\n'
          '  try {\n'
          '    final a = await api.getA();          // 顺序\n'
          '    final [b, c] = await Future.wait([   // 并行\n'
          '      api.getB(), api.getC(),\n'
          '    ]);\n'
          '    if (!mounted) return;                // await 后先判断\n'
          '    setState(() => ...);\n'
          '  } catch (e) {\n'
          '    // 处理异常\n'
          '  }\n'
          '}',
        ),
      ],
    );
  }
}

/// ===================== JSON 序列化 =====================
///
/// 【是什么】
/// dart:convert 提供 jsonDecode（字符串 → Map/List）与 jsonEncode（对象 → 字符串）。
/// 再配合模型类的 fromJson / toJson，就能在"字符串"和"有类型对象"之间来回转换。
///
/// 【属性 / API】
/// - jsonDecode(String)：返回 dynamic，通常是 `Map<String, dynamic> 或 List<dynamic>`
/// - jsonEncode(Object)：对象需要有 toJson() 方法，或本身是 Map / List / 基础类型
/// - JsonEncoder.withIndent('  ')：格式化输出，便于调试
///
/// 【注意】
/// - jsonDecode 的结果要 as 成具体类型再使用
/// - 列表数据：(json as List).map((e) => Post.fromJson(e)).toList()
/// - DateTime 需要自己转换（toIso8601String / DateTime.parse）
///
/// 【常见使用场景】
/// 1. 解析接口返回
/// 2. 把对象存到 shared_preferences / 文件
class JsonModelDemo extends StatefulWidget {
  const JsonModelDemo({super.key});

  @override
  State<JsonModelDemo> createState() => _JsonModelDemoState();
}

class _JsonModelDemoState extends State<JsonModelDemo> {
  static const String _raw = '{"userId": 1, "id": 7, "title": "学习 Flutter", "body": "从 JSON 到 Dart 对象"}';

  late Post _post = Post.fromJson(jsonDecode(_raw) as Map<String, dynamic>);

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(_post.toJson());
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 原始 JSON 字符串'),
        _code(context, _raw),
        _title('2. jsonDecode + Post.fromJson 得到对象'),
        _code(context, '$_post\npost.title = ${_post.title}\npost.id 的类型 = ${_post.id.runtimeType}'),
        _title('3. 修改对象后 toJson + jsonEncode 回字符串'),
        _code(context, pretty),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => setState(() {
              _post = Post(id: _post.id + 1, userId: _post.userId, title: '${_post.title}!', body: _post.body);
            }),
            child: const Text('修改对象（id + 1，标题加 !）'),
          ),
        ),
      ],
    );
  }
}

/// ===================== HTTP GET =====================
///
/// 【是什么】
/// 使用 http 包发起 GET 请求，拿到 JSON 后转换为 `List<Post>` 显示。
/// 请求逻辑封装在 PostApi（post_api.dart）里，页面只处理三种状态。
///
/// 【关键步骤】
/// 1. pubspec.yaml 添加依赖：http
/// 2. Android release 包需要在 AndroidManifest.xml 声明 INTERNET 权限
/// 3. final res = await client.get(Uri.parse(url));
/// 4. 判断 res.statusCode == 200，再 jsonDecode(res.body)
///
/// 【注意】
/// - 不要在 build() 里发请求，build 可能被调用很多次；放在 initState 或按钮回调
/// - 页面销毁时 client.close()
/// - iOS 默认禁止 http 明文请求（ATS），尽量都用 https
/// - 需要拦截器、取消请求、上传进度时可以换用 dio
///
/// 【常见使用场景】
/// 列表页、详情页、任何需要从服务器拉数据的地方
class HttpGetDemo extends StatefulWidget {
  const HttpGetDemo({super.key});

  @override
  State<HttpGetDemo> createState() => _HttpGetDemoState();
}

class _HttpGetDemoState extends State<HttpGetDemo> {
  final PostApi _api = PostApi();
  List<Post>? _posts;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await _api.fetchPosts(limit: 10);
      if (!mounted) return;
      setState(() => _posts = posts);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_loading && _posts == null) {
      body = const _LoadingView();
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _load);
    } else if (_posts == null || _posts!.isEmpty) {
      body = _EmptyView(onReload: _load);
    } else {
      body = ListView.separated(
        itemCount: _posts!.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) => _postTile(_posts![i]),
      );
    }
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.public),
          title: const Text('GET /posts?_limit=10'),
          subtitle: const Text(PostApi.baseUrl),
          trailing: IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ),
        if (_loading && _posts != null) const LinearProgressIndicator(),
        const Divider(height: 1),
        Expanded(child: body),
      ],
    );
  }
}

/// ===================== HTTP POST =====================
///
/// 【是什么】
/// 把表单数据编码成 JSON 提交给服务器，服务器返回新建的对象。
///
/// 【关键步骤】
/// - headers: {'Content-Type': 'application/json; charset=UTF-8'}
/// - body: jsonEncode(map)
/// - 创建成功一般返回 201 Created
///
/// 【注意】
/// - 提交过程中禁用按钮，防止重复提交
/// - jsonplaceholder 只是模拟接口：返回 id = 101，但数据不会真正保存
///
/// 【常见使用场景】
/// 登录、注册、发表评论、提交订单
class HttpPostDemo extends StatefulWidget {
  const HttpPostDemo({super.key});

  @override
  State<HttpPostDemo> createState() => _HttpPostDemoState();
}

class _HttpPostDemoState extends State<HttpPostDemo> {
  final PostApi _api = PostApi();
  final _titleController = TextEditingController(text: '我的第一篇文章');
  final _bodyController = TextEditingController(text: '用 http 包发送 POST 请求');
  bool _submitting = false;
  String _result = '（尚未提交）';

  @override
  void dispose() {
    _api.close();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final post = await _api.createPost(title: _titleController.text, body: _bodyController.text);
      if (!mounted) return;
      setState(() => _result = '✅ 创建成功（201）\n${const JsonEncoder.withIndent('  ').convert(post.toJson())}');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _result = '❌ ${e.message}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('POST ${PostApi.baseUrl}/posts'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '内容', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: Text(_submitting ? '提交中...' : '提交'),
                ),
              ),
            ],
          ),
        ),
        _title('服务器返回'),
        _code(context, _result),
      ],
    );
  }
}

enum _Outcome { success, empty, error }

/// ===================== 加载 / 错误 / 空状态 =====================
///
/// 【是什么】
/// 任何异步页面都至少有四种状态：加载中、成功、空数据、出错。
/// 这个示例用本地模拟（不联网）让你随意切换结果，观察每种状态的 UI。
///
/// 【推荐结构】
/// - 用几个字段（或 sealed class）描述状态：loading / data / error
/// - build 里根据状态返回不同的 Widget
/// - 出错时一定要给"重试"入口；空数据时给出引导
///
/// 【注意】
/// - 刷新时如果已有旧数据，可以保留旧数据 + 顶部细进度条，避免闪白
/// - 把通用的占位视图抽成组件（本文件的 _LoadingView / _ErrorView / _EmptyView）
///
/// 【常见使用场景】
/// 所有列表页、详情页、搜索结果页
class LoadStateDemo extends StatefulWidget {
  const LoadStateDemo({super.key});

  @override
  State<LoadStateDemo> createState() => _LoadStateDemoState();
}

class _LoadStateDemoState extends State<LoadStateDemo> {
  _Outcome _next = _Outcome.success;
  bool _loading = false;
  String? _error;
  List<String> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // 模拟网络耗时
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (_next) {
        case _Outcome.success:
          _items = List.generate(8, (i) => '第 ${i + 1} 条数据');
        case _Outcome.empty:
          _items = const [];
        case _Outcome.error:
          _error = '服务器开小差了（模拟错误）';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_loading) {
      body = const _LoadingView();
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _load);
    } else if (_items.isEmpty) {
      body = _EmptyView(onReload: _load);
    } else {
      body = ListView(
        children: [for (final item in _items) ListTile(leading: const Icon(Icons.article), title: Text(item))],
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('下一次加载的结果：'),
              const SizedBox(height: 8),
              SegmentedButton<_Outcome>(
                segments: const [
                  ButtonSegment(value: _Outcome.success, label: Text('成功'), icon: Icon(Icons.check)),
                  ButtonSegment(value: _Outcome.empty, label: Text('空数据'), icon: Icon(Icons.inbox)),
                  ButtonSegment(value: _Outcome.error, label: Text('失败'), icon: Icon(Icons.error_outline)),
                ],
                selected: {_next},
                onSelectionChanged: (s) => setState(() => _next = s.first),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: _loading ? null : _load, child: const Text('重新加载')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: body),
      ],
    );
  }
}

/// ===================== RefreshIndicator 下拉刷新 =====================
///
/// 【是什么】
/// Material 风格的下拉刷新：把可滚动组件包在 RefreshIndicator 里，
/// 下拉松手后调用 onRefresh，返回的 Future 完成后转圈自动消失。
///
/// 【属性】
/// - onRefresh: 必填，返回 `Future<void>`；必须 await 真正的加载过程
/// - child: 可滚动组件（ListView / CustomScrollView 等）
/// - color / backgroundColor: 指示器颜色
/// - displacement / edgeOffset: 指示器位置
/// - triggerMode: 触发方式（anywhere / onEdge）
///
/// 【注意】
/// - 列表内容不满一屏时无法下拉，给 ListView 加
///   physics: const AlwaysScrollableScrollPhysics()
/// - 错误 / 空状态时也要包在可滚动组件里，否则不能下拉重试
/// - iOS 风格可用 CupertinoSliverRefreshControl
///
/// 【常见使用场景】
/// 信息流、消息列表、订单列表
class RefreshIndicatorDemo extends StatefulWidget {
  const RefreshIndicatorDemo({super.key});

  @override
  State<RefreshIndicatorDemo> createState() => _RefreshIndicatorDemoState();
}

class _RefreshIndicatorDemoState extends State<RefreshIndicatorDemo> {
  final PostApi _api = PostApi();
  List<Post> _posts = const [];
  String? _error;
  bool _firstLoading = true;
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _refresh().whenComplete(() {
      if (mounted) setState(() => _firstLoading = false);
    });
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  // onRefresh 必须返回 Future，并且 await 到数据真正加载完成
  Future<void> _refresh() async {
    try {
      final posts = await _api.fetchPosts(limit: 15);
      if (!mounted) return;
      setState(() {
        // 打乱顺序，让每次刷新都能看出变化
        _posts = posts..shuffle();
        _error = null;
        _updatedAt = DateTime.now();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firstLoading) return const _LoadingView();
    final time = _updatedAt == null ? '--' : TimeOfDay.fromDateTime(_updatedAt!).format(context);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        // 内容不满一屏也能下拉
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ListTile(dense: true, leading: const Icon(Icons.south), title: Text('下拉刷新 · 上次更新 $time')),
          if (_error != null)
            SizedBox(
              height: 300,
              child: _ErrorView(message: _error!, onRetry: _refresh),
            )
          else
            for (final post in _posts) _postTile(post),
        ],
      ),
    );
  }
}

/// ===================== 上拉加载更多（分页） =====================
///
/// 【是什么】
/// 列表滚动到接近底部时自动请求下一页，追加到已有数据后面，
/// 也叫"无限滚动"。本例同时支持下拉刷新。
///
/// 【实现要点】
/// - ScrollController 监听滚动：position.extentAfter < 阈值 时触发加载
/// - 用 _loadingMore 标志防止重复请求
/// - 返回条数 < pageSize 说明没有更多了（_hasMore = false）
/// - 列表最后多放一项"底部状态栏"：加载中 / 没有更多 / 加载失败点击重试
///
/// 【注意】
/// - 记得在 dispose 里释放 ScrollController
/// - 下拉刷新时要重置页码和 _hasMore
/// - 也可以用 `NotificationListener<ScrollNotification>` 代替 ScrollController
///
/// 【常见使用场景】
/// 商品列表、评论列表、搜索结果
class LoadMoreDemo extends StatefulWidget {
  const LoadMoreDemo({super.key});

  @override
  State<LoadMoreDemo> createState() => _LoadMoreDemoState();
}

class _LoadMoreDemoState extends State<LoadMoreDemo> {
  static const int _pageSize = 15;

  final PostApi _api = PostApi();
  final ScrollController _controller = ScrollController();
  final List<Post> _posts = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _controller.dispose();
    _api.close();
    super.dispose();
  }

  void _onScroll() {
    // 距离底部不足 200 像素时加载下一页
    if (_controller.position.extentAfter < 200) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _error = null;
    });
    try {
      final page = await _api.fetchPosts(start: _posts.length, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _posts.addAll(page);
        _hasMore = page.length == _pageSize;
      });
      // 屏幕很高、第一页不足一屏时滚动不了，这里主动再检查一次
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients && _controller.position.extentAfter < 200) _loadMore();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _hasMore = true;
    });
    await _loadMore();
  }

  Widget _footer() {
    if (_error != null) {
      return ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(_error!),
        subtitle: const Text('点击重试'),
        onTap: _loadMore,
      );
    }
    if (_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text('—— 没有更多了 ——', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.format_list_numbered),
          title: Text('已加载 ${_posts.length} 条，每页 $_pageSize 条'),
        ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _posts.length + 1, // 最后一项是底部状态栏
              itemBuilder: (_, i) => i == _posts.length ? _footer() : _postTile(_posts[i]),
            ),
          ),
        ),
      ],
    );
  }
}
