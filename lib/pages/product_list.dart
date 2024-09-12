import 'package:flutter/material.dart';
import '../models/product.dart'; // Certifique-se de que o caminho esteja correto
import '../services/database_service.dart'; // Importe o serviço de banco de dados
import '../models/order.dart'; // Importe o modelo Order

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late DatabaseService _databaseService;
  List<Product> _products = [];
  List<Product> _selectedProducts = [];
  double _totalSelectedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(); // Inicializa o serviço de banco de dados
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _databaseService.getAllProducts();
    
    setState(() {
      _products = products;
    });
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
      _totalSelectedPrice = _selectedProducts.fold(0, (sum, item) => sum + item.price);
    });
  }

  Future<void> _confirmOrder() async {
    if (_selectedProducts.isNotEmpty) {
      // Criando um novo pedido
      Order order = Order(
        totalPrice: _totalSelectedPrice,
        selectedProducts: _selectedProducts,
      );

      // Salvando o pedido no banco de dados usando o DatabaseService
      await _databaseService.insertOrder(order);

      // Exibindo uma mensagem de confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido confirmado! Total: R\$ ${_totalSelectedPrice.toStringAsFixed(2)}')),
      );

      // Limpando a seleção após a confirmação
      setState(() {
        _selectedProducts.clear();
        _totalSelectedPrice = 0.0;
      });
    } else {
      // Caso nenhum produto tenha sido selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum prato selecionado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio do Restaurante'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _products.isEmpty
                ? Center(child: Text('Nenhum prato encontrado.'))
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isSelected = _selectedProducts.contains(product);

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('${product.description}\nR\$ ${product.price.toStringAsFixed(2)}'),
                        trailing: Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.green : null,
                        ),
                        onTap: () => _toggleProductSelection(product),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total Selecionado: R\$ ${_totalSelectedPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirmOrder,
                  child: Text('Confirmar Pedido'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aqui você pode adicionar a navegação para adicionar um novo produto, se quiser
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
