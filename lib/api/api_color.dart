import 'dart:convert';
import '../model/color.dart';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/message_response.dart';

class APIColor extends APIRepository {
  Future<List<MyColor>?> getColorByProduct(int productId) async {
    try {
      Uri uri =
          Uri.parse("$baseurl/Color/ListByProductId").replace(queryParameters: {
        'productId': productId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<MyColor> colors = (data['colors'] as List)
            .map((colorJson) => MyColor.fromJson(colorJson))
            .toList();

        return colors;
      } else {
        print("Lỗi khi lấy danh sách màu sắc: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi: $e");
      return [];
    }
  }

  Future<List<MyColor>?> GetList() async {
    try {
      Uri uri = Uri.parse("$baseurl/Color/List");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<MyColor> colors = (data['dataa'] as List)
            .map((colorJson) => MyColor.fromJson(colorJson))
            .toList();

        return colors;
      } else {
        print("Lỗi khi lấy danh sách màu sắc: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<MyColor?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Color/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MyColor.fromJson(data['color']);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy màu này");
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

  Future<MessageResponse?> Insert(String name, String image) async {
    try {
      Uri uri = Uri.parse("$baseurl/Color/Insert").replace(queryParameters: {
        'name': name.toString(),
        'image': image.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(color: MyColor.fromJson(data['color']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại màu này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Update(int id, String name, String image) async {
    try {
      Uri uri = Uri.parse("$baseurl/Color/Update").replace(queryParameters: {
        'id': id.toString(),
        'name': name.toString(),
        'image': image.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(color: MyColor.fromJson(data['color']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại màu này");
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
      Uri uri = Uri.parse("$baseurl/Color/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(color: MyColor.fromJson(data['color']));
      } else if (response.statusCode == 404) {
        return MessageResponse(errorMessage: "Không tìm thấy màu với id này");
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
