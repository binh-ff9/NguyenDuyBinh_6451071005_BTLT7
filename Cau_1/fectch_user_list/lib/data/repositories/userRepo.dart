import 'dart:convert';
import 'package:fectch_user_list/data/models/userModel.dart';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers() async {
  try {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    print('Status code: ${response.statusCode}'); // In ra để xem mã lỗi

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      // In ra nội dung lỗi từ server nếu có
      print('Response body: ${response.body}');
      throw Exception('Server trả về lỗi: ${response.statusCode}');
    }
  } catch (e) {
    // Bắt các lỗi về kết nối (mất mạng, timeout...)
    print('Lỗi kết nối: $e');
    throw Exception('Không thể kết nối internet');
  }
}
