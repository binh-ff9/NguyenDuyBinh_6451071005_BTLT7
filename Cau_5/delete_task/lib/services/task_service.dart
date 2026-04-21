import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  // GET — Lấy danh sách task (giới hạn 20 task đầu)
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl?_limit=20'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải danh sách task (${response.statusCode})');
    }
  }

  // DELETE — Xóa một task theo id
  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$taskId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa task (${response.statusCode})');
    }
  }
}
