import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/database_service.dart'; // Importe o serviço de banco de dados

class CartPage extends StatelessWidget {
  final Map<Product, int> selectedProducts;
  final String email; // Adicionando o userId
  final DatabaseService _databaseService = DatabaseService(); // Instância do serviço de banco de dados

  CartPage({required this.selectedProducts, required this.email}); // Adicionando o userId no construtor

  // Função para finalizar o pedido e gravar no banco de dados
 // Função para finalizar o pedido e gravar no banco de dados
Future<void> _finalizeOrder(BuildContext context) async {
  if (selectedProducts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('O carrinho está vazio!')),
    );
    return;
  }

  // Calcular o preço total
  double totalPrice = selectedProducts.entries.fold(0.0, (sum, entry) {
    return sum + (entry.key.price * entry.value);
  });

  // Converter selectedProducts (Map<Product, int>) para uma lista de OrderItem
  List<OrderItem> orderItems = selectedProducts.entries.map((entry) {
    return OrderItem(product: entry.key, quantity: entry.value);
  }).toList();

  // Criar um objeto Order com a lista de OrderItem
  Order order = Order(
    totalPrice: totalPrice,
    selectedProducts: orderItems,
  );

  // Inserir o pedido no banco de dados
  await _databaseService.insertOrder(order, email);

  // Exibir uma mensagem de sucesso
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Pedido finalizado com sucesso!')),
  );

  // Voltar para a página anterior
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de Compras'),
      ),
      body: selectedProducts.isEmpty
          ? Center(child: Text('Seu carrinho está vazio!'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedProducts.length,
                    itemBuilder: (context, index) {
                      final productEntry = selectedProducts.entries.elementAt(index);
                      final product = productEntry.key;
                      final quantity = productEntry.value;

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Quantidade: $quantity\nR\$ ${(product.price * quantity).toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _finalizeOrder(context),
                    child: Text('Finalizar Pedido'),
                  ),
                ),
              ],
            ),
    );
  }
}
