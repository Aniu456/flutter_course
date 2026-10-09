import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_course/main.dart';
import 'package:flutter_course/widgets/catalog.dart';
import 'package:flutter_course/widgets/网络与异步/post_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 假的 jsonplaceholder：测试中不访问真实网络。
http.Client _fakeClient() {
  return MockClient((request) async {
    if (request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...body, 'id': 101}), 201);
    }
    final start = int.tryParse(request.url.queryParameters['_start'] ?? '') ?? 0;
    final limit = int.tryParse(request.url.queryParameters['_limit'] ?? '') ?? 100;
    final posts = [
      for (var id = start + 1; id <= 100 && id <= start + limit; id++)
        {'userId': 1, 'id': id, 'title': '标题 $id', 'body': '内容 $id'},
    ];
    return http.Response.bytes(utf8.encode(jsonEncode(posts)), 200);
  });
}

void main() {
  setUp(() {
    PostApi.clientFactory = _fakeClient;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('catalog shows all categories', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ExpansionTile), findsWidgets);
    expect(find.text('基础容器'), findsOneWidget);
  });

  testWidgets('HTTP GET demo renders posts from the fake client', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Builder(builder: _entry('HTTP GET').builder)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('标题 1'), findsOneWidget);
  });

  testWidgets('Post JSON round trip', (tester) async {
    final post = Post.fromJson({'id': 1, 'userId': 2, 'title': 't', 'body': 'b'});
    expect(Post.fromJson(post.toJson()).toJson(), post.toJson());
  });

  // 每个示例页面都能无异常地构建出来
  for (final category in catalog) {
    for (final entry in category.entries) {
      testWidgets('${category.name} / ${entry.title} builds', (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Builder(builder: entry.builder)),
          ),
        );
        await tester.pump();
        // 等待示例里的 Future.delayed 等定时器结束
        await tester.pump(const Duration(seconds: 10));
      });
    }
  }
}

CatalogEntry _entry(String title) {
  return catalog.expand((c) => c.entries).firstWhere((e) => e.title == title);
}
