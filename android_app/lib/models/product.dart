import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String shopifyId;
  final String title;
  final String sku;
  final String price;
  final String? imageUrl;
  final int inventoryQuantity;

  Product({
    required this.id,
    required this.shopifyId,
    required this.title,
    required this.sku,
    required this.price,
    this.imageUrl,
    required this.inventoryQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  double get priceAsDouble => double.parse(price);
}