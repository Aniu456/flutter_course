import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 本地存储：shared_preferences 键值对、JSON 对象持久化、文件读写、方案对比。

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

/// ===================== SharedPreferences =====================
///
/// 【是什么】
/// shared_preferences 是官方维护的轻量键值存储插件，
/// 底层在 Android 用 SharedPreferences / DataStore，iOS 用 NSUserDefaults。
///
/// 【常用 API】
/// - final prefs = await SharedPreferences.getInstance();
/// - 写：setInt / setDouble / setBool / setString / setStringList
/// - 读：getInt / getDouble / getBool / getString / getStringList（不存在返回 null）
/// - remove(key) 删除一个；clear() 清空；getKeys() 列出所有 key
///
/// 【注意】
/// - 只适合存少量简单数据（设置项、token、开关），不适合大数据或复杂查询
/// - 不加密，敏感信息请用 flutter_secure_storage
/// - 新版本还提供 SharedPreferencesAsync / SharedPreferencesWithCache，
///   本例使用最常见的 SharedPreferences.getInstance() 写法
/// - 单元测试中用 SharedPreferences.setMockInitialValues({}) 模拟
///
/// 【常见使用场景】
/// 1. 记住用户名、是否首次启动、主题 / 语言设置
/// 2. 计数、简单缓存
class SharedPreferencesDemo extends StatefulWidget {
  const SharedPreferencesDemo({super.key});

  @override
  State<SharedPreferencesDemo> createState() => _SharedPreferencesDemoState();
}

class _SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  static const _kCounter = 'demo_counter';
  static const _kName = 'demo_name';
  static const _kNotify = 'demo_notify';

  SharedPreferences? _prefs;
  String? _error;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _nameController.text = prefs.getString(_kName) ?? '';
      });
    } catch (e) {
      if (mounted) setState(() => _error = '当前环境无法使用 shared_preferences：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Center(child: Text(_error!));
    final prefs = _prefs;
    if (prefs == null) return const Center(child: CircularProgressIndicator());

    final counter = prefs.getInt(_kCounter) ?? 0;
    final notify = prefs.getBool(_kNotify) ?? true;
    final keys = prefs.getKeys().where((k) => k.startsWith('demo_')).toList()..sort();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. setInt：计数器（退出页面 / 重启 App 后仍然保留）'),
        ListTile(
          title: Text('计数：$counter'),
          trailing: FilledButton(
            onPressed: () async {
              await prefs.setInt(_kCounter, counter + 1);
              setState(() {});
            },
            child: const Text('+1 并保存'),
          ),
        ),
        _title('2. setString：用户名'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await prefs.setString(_kName, _nameController.text);
                  setState(() {});
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
        _title('3. setBool：开关设置'),
        SwitchListTile(
          title: const Text('接收通知'),
          value: notify,
          onChanged: (v) async {
            await prefs.setBool(_kNotify, v);
            setState(() {});
          },
        ),
        _title('4. 当前已保存的键值（getKeys）'),
        _code(context, keys.isEmpty ? '（空）' : keys.map((k) => '$k = ${prefs.get(k)}').join('\n')),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () async {
              for (final k in keys) {
                await prefs.remove(k);
              }
              _nameController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('删除以上所有键（remove）'),
          ),
        ),
      ],
    );
  }
}

class _Todo {
  const _Todo(this.title, {this.done = false});

  final String title;
  final bool done;

  factory _Todo.fromJson(Map<String, dynamic> json) => _Todo(json['title'] as String, done: json['done'] as bool);

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}

/// ===================== JSON 对象持久化 =====================
///
/// 【是什么】
/// shared_preferences 只能存基础类型。要保存对象 / 列表时，
/// 先 toJson + jsonEncode 成字符串存进去，读出来再 jsonDecode + fromJson。
///
/// 【注意】
/// - 适合几十上百条的小数据；数据多、需要查询排序时改用数据库（sqflite / drift）
/// - 模型字段变化时要考虑旧数据的兼容（字段缺失给默认值）
///
/// 【常见使用场景】
/// 待办清单、搜索历史、草稿、简单的离线缓存
class JsonPersistenceDemo extends StatefulWidget {
  const JsonPersistenceDemo({super.key});

  @override
  State<JsonPersistenceDemo> createState() => _JsonPersistenceDemoState();
}

class _JsonPersistenceDemoState extends State<JsonPersistenceDemo> {
  static const _kTodos = 'demo_todos';

  SharedPreferences? _prefs;
  List<_Todo> _todos = [];
  String? _error;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kTodos);
      final list = raw == null
          ? const [_Todo('学习 shared_preferences'), _Todo('学习 JSON 序列化', done: true)]
          : (jsonDecode(raw) as List<dynamic>).map((e) => _Todo.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _todos = List.of(list);
      });
    } catch (e) {
      if (mounted) setState(() => _error = '读取失败：$e');
    }
  }

  Future<void> _save(List<_Todo> todos) async {
    setState(() => _todos = todos);
    // 对象列表 → JSON 字符串 → 存储
    await _prefs?.setString(_kTodos, jsonEncode(todos.map((t) => t.toJson()).toList()));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Center(child: Text(_error!));
    if (_prefs == null) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: '新的待办', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  _controller.clear();
                  _save([..._todos, _Todo(text)]);
                },
                child: const Text('添加'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < _todos.length; i++)
                CheckboxListTile(
                  value: _todos[i].done,
                  title: Text(_todos[i].title),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _save([..._todos]..removeAt(i)),
                  ),
                  onChanged: (v) => _save([..._todos]..[i] = _Todo(_todos[i].title, done: v ?? false)),
                ),
              _title('实际存储的字符串（key = $_kTodos）'),
              _code(context, _prefs!.getString(_kTodos) ?? '（还没保存过，修改列表后会写入）'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===================== 文件读写（path_provider） =====================
///
/// 【是什么】
/// path_provider 获取各平台的标准目录，再用 dart:io 的 File 读写。
///
/// 【常用目录】
/// - getApplicationDocumentsDirectory()：文档目录，用户数据，长期保存
/// - getTemporaryDirectory()：临时目录，系统可能随时清理，适合缓存
/// - getApplicationSupportDirectory()：App 内部支持文件，不对用户可见
///
/// 【常用 API】
/// - File('$dir/a.txt').writeAsString(text)            覆盖写入
/// - writeAsString(text, mode: FileMode.append)       追加
/// - readAsString() / readAsBytes() / readAsLines()   读取
/// - exists() / delete() / length()                   判断、删除、大小
///
/// 【注意】
/// - Web 平台没有文件系统，path_provider 大部分方法不可用
/// - 读写都是异步的，注意 await 和异常处理
/// - 大文件建议用 openRead / openWrite 流式处理
///
/// 【常见使用场景】
/// 日志、导出文件、下载内容、较大的 JSON 缓存
class FileStorageDemo extends StatefulWidget {
  const FileStorageDemo({super.key});

  @override
  State<FileStorageDemo> createState() => _FileStorageDemoState();
}

class _FileStorageDemoState extends State<FileStorageDemo> {
  final _controller = TextEditingController(text: '你好，文件！');
  File? _file;
  String _content = '';
  String _status = '正在获取文档目录...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!mounted) return;
      setState(() {
        _file = File('${dir.path}/flutter_course_note.txt');
        _status = '就绪';
      });
      await _read();
    } catch (e) {
      if (mounted) setState(() => _status = '当前平台无法获取文档目录：$e');
    }
  }

  Future<void> _guard(String action, Future<void> Function(File file) task) async {
    final file = _file;
    if (file == null) return;
    try {
      await task(file);
      if (mounted) setState(() => _status = '$action 成功');
    } catch (e) {
      if (mounted) setState(() => _status = '$action 失败：$e');
    }
  }

  Future<void> _read() => _guard('读取', (file) async {
    final text = await file.exists() ? await file.readAsString() : '（文件不存在）';
    if (mounted) setState(() => _content = text);
  });

  @override
  Widget build(BuildContext context) {
    final ready = _file != null;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('文件路径'),
        _code(context, _file?.path ?? '--'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: '要写入的内容', border: OutlineInputBorder()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: !ready
                    ? null
                    : () => _guard('覆盖写入', (f) => f.writeAsString('${_controller.text}\n')).then((_) => _read()),
                child: const Text('覆盖写入'),
              ),
              FilledButton.tonal(
                onPressed: !ready
                    ? null
                    : () => _guard(
                        '追加',
                        (f) => f.writeAsString('${_controller.text}\n', mode: FileMode.append),
                      ).then((_) => _read()),
                child: const Text('追加一行'),
              ),
              OutlinedButton(onPressed: !ready ? null : _read, child: const Text('读取')),
              OutlinedButton(
                onPressed: !ready
                    ? null
                    : () => _guard('删除', (f) async {
                        if (await f.exists()) await f.delete();
                      }).then((_) => _read()),
                child: const Text('删除文件'),
              ),
            ],
          ),
        ),
        _title('状态'),
        _code(context, _status),
        _title('文件内容'),
        _code(context, _content.isEmpty ? '（空）' : _content),
      ],
    );
  }
}

/// ===================== 存储方案对比 =====================
///
/// 【怎么选】
/// 数据量小、结构简单 → shared_preferences；
/// 需要保存整份文件 / 大文本 → 文件；
/// 需要查询、排序、关联 → 数据库；
/// 敏感信息 → 安全存储。
class StorageOverviewDemo extends StatelessWidget {
  const StorageOverviewDemo({super.key});

  static const _rows = [
    ('shared_preferences', '键值对', '设置项、开关、简单标记', '不加密，不适合大数据'),
    ('文件 (path_provider + dart:io)', '任意文本 / 二进制', '日志、导出、下载、JSON 缓存', '需自己管理格式与并发'),
    ('sqflite', 'SQLite 关系数据库', '大量结构化数据、复杂查询', '需写 SQL，注意迁移'),
    ('drift', '类型安全的 SQLite ORM', '中大型项目的本地数据库', '需要代码生成'),
    ('hive / isar 等', 'NoSQL 对象存储', '读写频繁的对象缓存', '关注项目维护状态'),
    ('flutter_secure_storage', 'Keychain / Keystore', 'token、密码等敏感信息', '只适合少量数据'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (name, type, scene, note) in _rows)
          Card(
            child: ListTile(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('类型：$type\n适合：$scene\n注意：$note'),
              isThreeLine: true,
            ),
          ),
      ],
    );
  }
}
