import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
      join(await getDatabasesPath(), 'products_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, price REAL)',
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
            child: Text(
              'Total Selecionado: R\$ ${_totalSelectedPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
