import 'dart:convert';
import 'package:ecommerce_web/model/message_response.dart';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/category.dart';

class APICategory extends APIRepository {
  Future<List<Category>?> GetList() async {
    try {
      Uri uri = Uri.parse("$baseurl/Category/List");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<Category> categories = (data['dataa'] as List)
            .map((categoryJson) => Category.fromJson(categoryJson))
            .toList();

        return categories;
      } else {
        print("Lỗi khi lấy danh sách loại sản phẩm: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<Category?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Category/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Category.fromJson(data['category']);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy loại sản phẩm này");
        return null;
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Insert(String name) async {
    try {
      Uri uri = Uri.parse("$baseurl/Category/Insert").replace(queryParameters: {
        'name': name.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(category: Category.fromJson(data['category']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại loại sản phẩm này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Update(int id, String name) async {
    try {
      Uri uri = Uri.parse("$baseurl/Category/Update").replace(queryParameters: {
        'id': id.toString(),
        'name': name.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(category: Category.fromJson(data['category']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại loại sản phẩm này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Delete(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Category/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(category: Category.fromJson(data['category']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy loại sản phẩm với id này");
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
