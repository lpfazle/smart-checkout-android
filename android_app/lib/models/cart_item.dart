import 'package:json_annotation/json_annotation.dart';
import 'package:smart_checkout/models/product.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  final int id;
  final String sessionId;
  final int productId;
  final int quantity;
  final String price;
  final Product? product;

  CartItem({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get priceAsDouble => double.parse(price);
  double get totalPrice => priceAsDouble * quantity;
}