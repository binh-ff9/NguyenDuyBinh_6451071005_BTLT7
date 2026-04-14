import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  // Using FakeStore API — returns a single product JSON object
  static const String _baseUrl = 'https://fakestoreapi.com/products/1';

  Future<Product> fetchProduct() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Product.fromJson(jsonData);
    } else {
      throw Exception('Không thể tải dữ liệu sản phẩm (${response.statusCode})');
    }
  }
}
