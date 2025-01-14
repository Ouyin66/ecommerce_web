import 'package:ecommerce_web/model/category.dart';
import 'package:ecommerce_web/model/color.dart';
import 'package:ecommerce_web/model/order_status_history.dart';
import 'package:ecommerce_web/model/picture.dart';
import 'gender.dart';
import 'promotion.dart';
import 'notification.dart';
import 'product.dart';
import 'size.dart';
import 'user.dart';
import 'variant.dart';

class MessageResponse {
  final User? user;
  final Variant? variant;
  final Product? product;
  final Promotion? promotion;
  final Category? category;
  final MyColor? color;
  final Gender? gender;
  final MySize? size;
  final Picture? picture;
  final OrderStatusHistory? status;
  final String? errorMessage;
  final String? anotherError;
  final String? successMessage;
  final String? errorMessagePassword;
  final String? errorMessageEmail;

  MessageResponse(
      {this.user,
      this.variant,
      this.product,
      this.promotion,
      this.category,
      this.size,
      this.gender,
      this.color,
      this.picture,
      this.status,
      this.successMessage,
      this.errorMessage,
      this.anotherError,
      this.errorMessagePassword,
      this.errorMessageEmail});
}
