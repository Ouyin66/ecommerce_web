import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../model/message_response.dart';
import '../model/variant.dart';

class APIVariant extends APIRepository {
  // Future<List<Category>?> GetList() async {
  //   try {
  //     Uri uri = Uri.parse("$baseurl/Category/List");

  //     // Gửi yêu cầu GET đến API
  //     final response = await http.get(uri);

  //     // Kiểm tra trạng thái phản hồi
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);

  //       // Parse danh sách sản phẩm
  //       List<Category> categories = (data['dataa'] as List)
  //           .map((categoryJson) => Category.fromJson(categoryJson))
  //           .toList();

  //       return categories;
  //     } else {
  //       print("Lỗi khi lấy danh sách loại sản phẩm: ${response.statusCode}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Lỗi: $e");
  //     return null;
  //   }
  // }
  Future<Variant?> Get(int id) async {
    try {
      Uri uri = Uri.parse("$baseurl/Variant/Get").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        Variant variant = Variant.fromJson(data['variant']);

        return variant;
      } else {
        print("Lỗi khi lấy sản phẩm: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi: $e");
      return null;
    }
  }

  Future<List<Variant>?> GetVariantByProduct(int productId) async {
    try {
      Uri uri = Uri.parse("$baseurl/Variant/ListByProductId")
          .replace(queryParameters: {
        'productId': productId.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<Variant> variants = (data['variants'] as List)
            .map((variantJson) => Variant.fromJson(variantJson))
            .toList();

        return variants;
      } else {
        print("Lỗi khi lấy danh sách sản phẩm: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi: $e");
      return [];
    }
  }

  Future<MessageResponse?> Insert(int productId, int colorId, int sizeId,
      String picture, int quantity) async {
    try {
      Uri uri = Uri.parse("$baseurl/Variant/Insert").replace(queryParameters: {
        'product': productId.toString(),
        'color': colorId.toString(),
        'size': sizeId.toString(),
        'picture': picture.toString(),
        'quantity': quantity.toString(),
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(variant: Variant.fromJson(data['variant']));
      } else if (response.statusCode == 400) {
        return MessageResponse(
            errorMessage: "Đã tồn tại sản phẩm biến thể này");
      } else {
        print("Lỗi không xác định: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến máy chủ: $e");
      return null;
    }
  }

  Future<MessageResponse?> Update(int id, int productId, int colorId,
      int sizeId, String picture, int price, int quantity) async {
    try {
      Uri uri = Uri.parse("$baseurl/Variant/Update").replace(queryParameters: {
        'id': id.toString(),
        'product': productId.toString(),
        'color': colorId.toString(),
        'size': sizeId.toString(),
        'picture': picture.toString(),
        'price': price.toString(),
        'quantity': quantity.toString(),
      });

      final response = await http.put(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(variant: Variant.fromJson(data['variant']));
      } else if (response.statusCode == 400) {
        return MessageResponse(
            errorMessage: "Đã tồn tại sản phẩm biến thể này");
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
      Uri uri = Uri.parse("$baseurl/Variant/Delete").replace(queryParameters: {
        'id': id.toString(),
      });

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MessageResponse(variant: Variant.fromJson(data['variant']));
      } else if (response.statusCode == 404) {
        return MessageResponse(
            errorMessage: "Không tìm thấy sản phẩm biến thể với id này");
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
