import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/gender.dart';
import '../model/message_response.dart';

class APIGender extends APIRepository {
  Future<List<Gender>?> GetList() async {
    try {
      Uri uri = Uri.parse("$baseurl/Gender/List");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<Gender> genders = (data['dataa'] as List)
            .map((genderJson) => Gender.fromJson(genderJson))
            .toList();

        return genders;
      } else {
        print("Lỗi khi lấy danh sách giới tính: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<Gender?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Gender/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Gender.fromJson(data['gender']);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy giới tính");
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
      Uri uri = Uri.parse("$baseurl/Gender/Insert").replace(queryParameters: {
        'name': name.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(gender: Gender.fromJson(data['gender']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại giới tính này");
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
      Uri uri = Uri.parse("$baseurl/Gender/Update").replace(queryParameters: {
        'id': id.toString(),
        'name': name.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(gender: Gender.fromJson(data['gender']));
      } else if (response.statusCode == 400) {
        return MessageResponse(errorMessage: "Đã tồn tại giới tính này");
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
      Uri uri = Uri.parse("$baseurl/Gender/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(gender: Gender.fromJson(data['gender']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy giới tính với id này");
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
