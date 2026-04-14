import 'package:fectch_user_list/data/models/userModel.dart';
import 'package:fectch_user_list/data/repositories/userRepo.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers(); // Gọi API ngay khi widget khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh bạ User')),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: futureUsers,
          builder: (context, snapshot) {
            // 1. Khi đang chờ dữ liệu (Loading)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            // 2. Khi có lỗi xảy ra
            else if (snapshot.hasError) {
              return Text('Lỗi: ${snapshot.error}');
            }
            // 3. Khi đã có dữ liệu thành công
            else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(user.id.toString())),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.email),
                  );
                },
              );
            }
            return Text('Không có dữ liệu');
          },
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: UserListScreen()));
