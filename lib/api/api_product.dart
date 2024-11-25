import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/message_response.dart';
import '../model/product.dart';

class APIProduct extends APIRepository {
  Future<List<Product>?> GetList() async {
    try {
      Uri uri = Uri.parse("$baseurl/Product/List");

      // Gửi yêu cầu GET đến API
      final response = await http.get(uri);

      // Kiểm tra trạng thái phản hồi
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Parse danh sách sản phẩm
        List<Product> products = (data['data'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();

        return products;
      } else {
        print("Lỗi khi lấy danh sách sản phẩm: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<Product?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Product/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        Product product = Product.fromJson(data['product']);

        return product;
      } else {
        print("Lỗi khi lấy sản phẩm: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<MessageResponse?> Insert(Product product) async {
    try {
      final url = Uri.parse('$baseurl/Product/Insert');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(product: Product.fromJson(data['product']));
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Lỗi không xác định: ${data['message']}");
        return MessageResponse(errorMessage: data['message']);
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Update(Product product) async {
    try {
      final url = Uri.parse('$baseurl/Product/Update');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(product: Product.fromJson(data['product']));
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(errorMessage: data['message']);
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(errorMessage: data['message']);
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Lỗi không xác định: ${response.statusCode}");
        print("L${data['details']}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Delete(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Product/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(product: Product.fromJson(data['product']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy sản phẩm với id này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }
}
