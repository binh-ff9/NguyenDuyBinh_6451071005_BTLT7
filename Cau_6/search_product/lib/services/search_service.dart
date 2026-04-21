import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class SearchService {
  static const String _baseUrl = 'https://dummyjson.com';

  // GET /products?limit=20 — Lấy danh sách sản phẩm mặc định
  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> products = json['products'];
      return products.map((p) => Product.fromJson(p)).toList();
    } else {
      throw Exception('Không thể tải sản phẩm (${response.statusCode})');
    }
  }

  // GET /products/search?q=keyword — Tìm kiếm theo keyword (query param)
  Future<List<Product>> searchProducts(String keyword) async {
    final uri = Uri.parse(
      '$_baseUrl/products/search?q=${Uri.encodeComponent(keyword)}',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> products = json['products'];
      return products.map((p) => Product.fromJson(p)).toList();
    } else {
      throw Exception('Lỗi tìm kiếm (${response.statusCode})');
    }
  }
}
