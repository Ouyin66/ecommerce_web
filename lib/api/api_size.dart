import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/message_response.dart';
import '../model/size.dart';

class APISize extends APIRepository {
  Future<List<MySize>?> getSizeByProduct(int productId) async {
    try {
      Uri uri =
          Uri.parse("$baseurl/Size/ListByProductId").replace(queryParameters: {
        'productId': productId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<MySize> sizes = (data['sizes'] as List)
            .map((sizeJson) => MySize.fromJson(sizeJson))
            .toList();

        return sizes;
      } else {
        print("Lỗi khi lấy danh sách kích cỡ: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi: $e");
      return [];
    }
  }

  Future<List<MySize>?> GetList() async {
    try {
      Uri uri = Uri.parse("$baseurl/Size/List");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<MySize> colors = (data['dataa'] as List)
            .map((sizeJson) => MySize.fromJson(sizeJson))
            .toList();

        return colors;
      } else {
        print("Lỗi khi lấy danh sách kích cỡ: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<MySize?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Size/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MySize.fromJson(data['size']);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy kích cỡ này");
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
      Uri uri = Uri.parse("$baseurl/Size/Insert").replace(queryParameters: {
        'name': name.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(size: MySize.fromJson(data['size']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại kích cỡ này");
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
      Uri uri = Uri.parse("$baseurl/Size/Update").replace(queryParameters: {
        'id': id.toString(),
        'name': name.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(size: MySize.fromJson(data['size']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại kích cỡ này");
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
      Uri uri = Uri.parse("$baseurl/Size/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(size: MySize.fromJson(data['size']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy kích cỡ với id này");
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
