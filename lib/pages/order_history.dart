import 'package:flutter/material.dart';
import 'package:projeto/services/database_service.dart';
import 'package:projeto/models/order.dart';

class OrderHistoryPage extends StatelessWidget {
  final DatabaseService dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Pedidos'),
      ),
      body: FutureBuilder<List<Order>>(
        future: dbService.getAllOrders(), // Método para buscar pedidos salvos
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
                  subtitle: Text('Total: R\$${order.totalPrice.toStringAsFixed(2)}'),
                  onTap: () {
                    // Detalhes do pedido podem ser mostrados em uma nova tela
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
            Text(order.toString()),
            SizedBox(height: 10),
            Text('Total: R\$${order.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
