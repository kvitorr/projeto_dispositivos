import 'package:flutter/material.dart';
import 'package:projeto/pages/home_page.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../pages/pickup_page.dart';
import '../services/database_service.dart'; // Importe o serviço de banco de dados

class CartPage extends StatelessWidget {
  final Map<Product, int> selectedProducts;
  final String email; // Adicionando o userId
  final DatabaseService _databaseService =
      DatabaseService(); // Instância do serviço de banco de dados

  CartPage(
      {required this.selectedProducts,
      required this.email}); // Adicionando o userId no construtor

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

    // Navegar para a página de seleção de retirada e aguardar o resultado
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectPickupLocationPage()),
    );

    // Verificar se um local de retirada foi selecionado
    if (result == null || result['location'] == null || result['name'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum local de retirada selecionado!')),
      );
      return;
    }

    // Criar um objeto Order com a lista de OrderItem e o local de retirada
    Order order = Order(
      totalPrice: totalPrice,
      selectedProducts: orderItems,
      pickupLocation: result['name'], // Adicionar o local de retirada ao pedido
    );

    // Inserir o pedido no banco de dados
    await _databaseService.insertOrder(order, email);

    // Exibir uma mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido finalizado com sucesso!')),
    );

    // Após finalizar o pedido, navegue para a tela de histórico de pedidos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(email: email, selectedProducts: selectedProducts),
      ),
    );
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
                      final productEntry =
                          selectedProducts.entries.elementAt(index);
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFBF0603), // Cor de fundo do botão
                      foregroundColor: Colors.white, // Cor do texto do botão
                    ),
                    child: Text('Escolher Local de Retirada'),
                  ),
                ),
              ],
            ),
    );
  }
}