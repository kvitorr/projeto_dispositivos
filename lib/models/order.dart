import 'product.dart'; // Certifique-se de importar o modelo de produtos

class Order {
  final int? id; // O ID do pedido, gerado automaticamente pelo banco de dados
  final double totalPrice; // O preço total dos produtos selecionados
  final List<Product> selectedProducts; // A lista de produtos selecionados

  Order({
    this.id,
    required this.totalPrice,
    required this.selectedProducts,
  });

  // Convertendo o pedido para Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    // Convertendo a lista de produtos para uma string (por exemplo, nomes separados por vírgulas)
    String productsString = selectedProducts.map((product) => product.name).join(', ');

    return {
      'id': id,
      'total_price': totalPrice,
      'selected_products': productsString,
    };
  }

  // Convertendo de Map para Order para ler do banco de dados
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      totalPrice: map['total_price'],
      // Para simplificar, estamos retornando uma lista vazia por enquanto
      selectedProducts: [], 
    );
  }
}
