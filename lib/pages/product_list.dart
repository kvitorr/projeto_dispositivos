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

        // Inserindo produtos iniciais
        await db.insert(
          'products',
          Product(name: 'Produto 1', description: 'Descrição do Produto 1', price: 10.0).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(name: 'Produto 2', description: 'Descrição do Produto 2', price: 20.0).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.insert(
          'products',
          Product(name: 'Produto 3', description: 'Descrição do Produto 3', price: 30.0).toMap(),
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

  Future<void> _deleteProduct(int id) async {
    await _database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    _loadProducts(); // Recarregar lista após a exclusão
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Produtos'),
      ),
      body: _products.isEmpty
          ? Center(child: Text('Nenhum produto encontrado.'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.description}\nR\$ ${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product.id!),
                  ),
                );
              },
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
