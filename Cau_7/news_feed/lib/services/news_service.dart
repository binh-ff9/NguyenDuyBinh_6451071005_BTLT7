import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class NewsService {
  static const String _baseUrl = 'https://dummyjson.com/posts';

  // Gọi lại API để lấy danh sách tin tức (randomize bằng skip ngẫu nhiên)
  Future<List<News>> fetchNews() async {
    // Mỗi lần gọi lấy 15 bài, skip ngẫu nhiên để dữ liệu thay đổi khi refresh
    final skip =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100; // 0-99
    final uri =
        Uri.parse('$_baseUrl?limit=15&skip=$skip&select=id,title,body,userId,tags,views,reactions');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> posts = json['posts'];
      return posts.map((p) => News.fromJson(p)).toList();
    } else {
      throw Exception('Không thể tải tin tức (${response.statusCode})');
    }
  }
}
