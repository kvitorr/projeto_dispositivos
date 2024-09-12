import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // Renomeia a importação para evitar conflito
import '../models/product.dart'; // Certifique-se de que o caminho esteja correto

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Database _database;
  List<Product> _products = [];
  List<Product> _selectedProducts = [];
  double _totalSelectedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      p.join(await getDatabasesPath(), 'restaurant_database.db'), // Use p.join para evitar o conflito
      onCreate: (db, version) async {
        // Criando a tabela de produtos
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, price REAL)',
        );

        // Criando a tabela de pedidos
        await db.execute(
          'CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, total_price REAL, selected_products TEXT)',
        );

        // Inserindo pratos iniciais
        await db.insert(
          'products',
          Product(
            name: 'Spaghetti à Bolonhesa',
            description: 'Macarrão spaghetti com molho de carne moída e tomates frescos.',
            price: 35.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(
            name: 'Frango à Parmegiana',
            description: 'Peito de frango empanado coberto com queijo e molho de tomate, acompanhado de arroz e batata frita.',
            price: 40.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(
            name: 'Risoto de Camarão',
            description: 'Risoto cremoso com camarões frescos e um toque de limão siciliano.',
            price: 50.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(
            name: 'Salada Caesar',
            description: 'Alface fresca, frango grelhado, croutons, e molho Caesar caseiro.',
            price: 25.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(
            name: 'Filé Mignon ao Molho Madeira',
            description: 'Corte nobre de filé mignon servido com molho madeira e batatas gratinadas.',
            price: 70.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(
            name: 'Tiramisu',
            description: 'Sobremesa clássica italiana com camadas de biscoito champagne, café e creme mascarpone.',
            price: 20.0,
          ).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
      version: 1,
    );
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final List<Map<String, dynamic>> maps = await _database.query('products');
    setState(() {
      _products = List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
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
      // Serializando os produtos selecionados em uma string para salvar no banco
      String selectedProductNames = _selectedProducts.map((p) => p.name).join(', ');

      // Salvando o pedido no banco de dados
      await _database.insert(
        'orders',
        {
          'total_price': _totalSelectedPrice,
          'selected_products': selectedProductNames,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

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
        title: Text('Cardápio de Restaurante'),
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
