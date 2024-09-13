import 'package:flutter/material.dart';
import '../models/product.dart'; // Certifique-se de que o caminho esteja correto
import '../services/database_service.dart'; // Importe o serviço de banco de dados
import '../models/order.dart'; // Importe o modelo Order
import 'cart_page.dart'; // Importe a página do carrinho

class ProductListPage extends StatefulWidget {
  final String email;
  ProductListPage({required this.email});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late DatabaseService _databaseService;
  List<Product> _products = [];
  Map<Product, int> _selectedProducts =
      {}; // Map para armazenar produtos e suas quantidades
  List<Product> _cartItems = []; // Lista para armazenar os produtos no carrinho
  double _totalSelectedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _databaseService =
        DatabaseService(); // Inicializa o serviço de banco de dados
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _databaseService.getAllProducts();

    setState(() {
      _products = products;
    });
  }

  void _increaseQuantity(Product product) {
    setState(() {
      if (_selectedProducts.containsKey(product)) {
        _selectedProducts[product] = _selectedProducts[product]! + 1;
      } else {
        _selectedProducts[product] = 1;
      }
      _calculateTotalPrice();
    });
  }

  void _decreaseQuantity(Product product) {
    setState(() {
      if (_selectedProducts.containsKey(product) &&
          _selectedProducts[product]! > 1) {
        _selectedProducts[product] = _selectedProducts[product]! - 1;
      } else {
        _selectedProducts.remove(product);
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    _totalSelectedPrice = _selectedProducts.entries.fold(
      0.0,
      (sum, entry) => sum + entry.key.price * entry.value,
    );
  }

  // Função para adicionar todos os itens ao carrinho
  void _addAllToCart() {
    setState(() {
      _selectedProducts.forEach((product, quantity) {
        for (int i = 0; i < quantity; i++) {
          _cartItems.add(
              product); // Adiciona os produtos ao carrinho com suas quantidades
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Todos os itens foram adicionados ao carrinho!')),
    );
  }

  // Navegar para a página do carrinho
  void _goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          selectedProducts: _selectedProducts,
          email: widget.email,
        ), // Passando os itens do carrinho para a nova página
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Color(0xFFBF0603),
            onPressed: _goToCartPage, // Navega para o carrinho
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _products.isEmpty
                ? Center(child: Text('Nenhum produto encontrado.'))
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final quantity = _selectedProducts[product] ?? 0;

                      return ListTile(
                        leading: Image.network(
                          product.url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                            '${product.description}\nR\$ ${product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: quantity > 0
                                  ? () => _decreaseQuantity(product)
                                  : null,
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _increaseQuantity(product),
                            ),
                          ],
                        ),
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
                  onPressed: _selectedProducts.isNotEmpty
                      ? _addAllToCart
                      : null, // Adiciona todos os itens ao carrinho
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBF0603), // Cor de fundo do botão
                    foregroundColor: Colors.white, // Cor do texto do botão
                  ),
                  child: Text('Adicionar Todos ao Carrinho'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
