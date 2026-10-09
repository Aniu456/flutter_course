import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// 网络层：数据模型 Post + 请求封装 PostApi。
// 演示用的公开接口：https://jsonplaceholder.typicode.com （假数据，POST 不会真正保存）

/// ===================== JSON 数据模型 =====================
///
/// 【是什么】
/// 把服务端返回的 JSON（`Map<String, dynamic>`）转换成有类型的 Dart 对象，
/// 避免在 UI 里到处写 json['title'] 这种字符串取值。
///
/// 【约定写法】
/// - factory Post.fromJson(`Map<String, dynamic>` json)：JSON → 对象
/// - `Map<String, dynamic>` toJson()：对象 → JSON（jsonEncode 会自动调用它）
///
/// 【注意】
/// - 字段类型要与接口一致，int / double 混用时可写 (json['x'] as num).toDouble()
/// - 字段可能缺失时用可空类型或 ?? 给默认值
/// - 字段很多时可用 json_serializable / freezed 自动生成这些代码
class Post {
  const Post({required this.id, required this.userId, required this.title, required this.body});

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'title': title, 'body': body};

  @override
  String toString() => 'Post(id: $id, title: $title)';
}

/// 请求失败时抛出的异常，message 直接展示给用户。
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 创建 http.Client 的工厂。
///
/// 默认创建真实的 http.Client；测试里会替换成 MockClient，
/// 这样 `flutter test` 不会访问网络，结果也稳定可控。
typedef HttpClientFactory = http.Client Function();

/// ===================== 请求封装 =====================
///
/// 【为什么要封装】
/// - UI 只关心"拿到 `List<Post>`"或"失败原因"，不关心 URL、状态码、JSON 解析
/// - 统一处理超时、状态码、编码问题
/// - 依赖注入 http.Client，便于测试时替换
class PostApi {
  PostApi({http.Client? client}) : _client = client ?? clientFactory();

  /// 全局可替换的 Client 工厂（测试用）。
  static HttpClientFactory clientFactory = http.Client.new;

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration timeout = Duration(seconds: 8);

  final http.Client _client;

  /// GET /posts?_start=0&_limit=20 —— 分页获取文章列表。
  Future<List<Post>> fetchPosts({int start = 0, int limit = 20}) async {
    final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: {'_start': '$start', '_limit': '$limit'});
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw ApiException('请求失败（HTTP ${response.statusCode}）');
      }
      // 用 bodyBytes + utf8.decode，避免服务端没声明 charset 时中文乱码
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw const ApiException('请求超时，请检查网络后重试');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('网络异常：$e');
    }
  }

  /// POST /posts —— 提交 JSON，服务端返回带 id 的新对象（状态码 201）。
  Future<Post> createPost({required String title, required String body}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/posts'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
          )
          .timeout(timeout);
      if (response.statusCode != 201) {
        throw ApiException('提交失败（HTTP ${response.statusCode}）');
      }
      return Post.fromJson(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    } on TimeoutException {
      throw const ApiException('请求超时，请检查网络后重试');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('网络异常：$e');
    }
  }

  /// 页面销毁时关闭 Client，释放底层连接。
  void close() => _client.close();
}
