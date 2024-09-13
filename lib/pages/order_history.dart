import 'package:flutter/material.dart';
import 'package:projeto/services/database_service.dart';
import 'package:projeto/models/order.dart';

class OrderHistoryPage extends StatelessWidget {
  final String email;
  final DatabaseService _databaseService = DatabaseService();

  OrderHistoryPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Order>>(
        future: _databaseService.getOrdersByUser(email), // Buscar pedidos do usuário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar pedidos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum pedido encontrado'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Pedido #${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: R\$${order.totalPrice.toStringAsFixed(2)}'),
                      Text('Local de Retirada: ${order.pickupLocation}'), // Exibir local de retirada
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pedido #${order.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itens do Pedido:', style: TextStyle(fontSize: 18)),
            ...order.selectedProducts.map((orderItem) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${orderItem.product.name} - Quantidade: ${orderItem.quantity} - R\$${orderItem.product.price.toStringAsFixed(2)}',
              ),
            )),
            SizedBox(height: 10),
            Text(
              'Total: R\$${order.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Local de Retirada: ${order.pickupLocation}', // Exibir local de retirada
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}