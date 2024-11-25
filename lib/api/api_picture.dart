import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/message_response.dart';
import '../model/picture.dart';

class APIPicture extends APIRepository {
  Future<List<Picture>?> getPicturesByProduct(int productId) async {
    try {
      Uri uri = Uri.parse("$baseurl/Picture/ListByProductId")
          .replace(queryParameters: {
        'productId': productId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<Picture> pictures = (data['picutures'] as List)
            .map((pictureJson) => Picture.fromJson(pictureJson))
            .toList();

        return pictures;
      } else {
        print("Lỗi khi lấy danh sách hình ảnh: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi: $e");
      return [];
    }
  }

  Future<Picture?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Picture/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Picture.fromJson(data['picture']);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy hình ảnh này");
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

  Future<MessageResponse?> Insert(int productId, String image) async {
    try {
      Uri uri = Uri.parse("$baseurl/Picture/Insert").replace(queryParameters: {
        'productId': productId.toString(),
        'image': image.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(picture: Picture.fromJson(data['picture']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại hình ảnh này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Update(int id, int productId, String image) async {
    try {
      Uri uri = Uri.parse("$baseurl/Picture/Update").replace(queryParameters: {
        'id': id.toString(),
        'productId': productId.toString(),
        'image': image.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(picture: Picture.fromJson(data['picture']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại hình ảnh này");
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
      Uri uri = Uri.parse("$baseurl/Picture/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(picture: Picture.fromJson(data['picture']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy hình ảnh với id này");
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
