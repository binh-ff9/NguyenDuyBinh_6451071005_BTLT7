import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/users';

  // GET — Load dữ liệu user cũ
  Future<User> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Không thể tải thông tin user (${response.statusCode})');
    }
  }

  // PUT — Gửi dữ liệu cập nhật lên server
  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${user.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Không thể cập nhật thông tin (${response.statusCode})');
    }
  }
}
