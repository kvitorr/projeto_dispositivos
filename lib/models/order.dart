import 'package:projeto/models/product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });
}

class Order {
  final int? id;
  final double totalPrice;
  final List<OrderItem> selectedProducts;
  final String pickupLocation; // Novo campo

  Order({
    this.id,
    required this.totalPrice,
    required this.selectedProducts,
    required this.pickupLocation, // Adicionando o campo no construtor
  });

  // Converte de Map para Order
  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> products) {
    return Order(
      id: map['id'],
      totalPrice: map['total_price'],
      selectedProducts: products,
      pickupLocation: map['pickup_location'], // Mapeando o campo pickup_location
    );
  }
}
