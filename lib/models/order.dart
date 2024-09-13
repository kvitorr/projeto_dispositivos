import 'package:projeto/models/product.dart';

class Order {
  final int? id;
  final double totalPrice;
  final List<Product> selectedProducts;

  Order({
    this.id,
    required this.totalPrice,
    required this.selectedProducts,
  });

  // Converte de Map para Order
  factory Order.fromMap(Map<String, dynamic> map, List<Product> products) {
    return Order(
      id: map['id'],
      totalPrice: map['total_price'],
      selectedProducts: products,
    );
  }
}
