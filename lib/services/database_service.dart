import 'package:path/path.dart';
import 'package:projeto/models/users.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart'; // Certifique-se de que o caminho esteja correto
import '../models/order.dart'; // Importe o modelo de Order

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'flutter_sqflite_database.db');

    // Excluir o banco de dados existente
    await deleteDatabase(path);

    // Criar um novo banco de dados
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, usrName TEXT UNIQUE, usrNickname TEXT UNIQUE, usrPassword TEXT, biografia TEXT)",
    );

    await db.execute(
      'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, price REAL, url TEXT)',
    );
    await db.execute(
      'CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, total_price REAL, selected_products TEXT, pickup_location TEXT)',
    );

    await db.execute(
      '''CREATE TABLE order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER,
          product_id INTEGER, 
          quantity INTEGER,
          FOREIGN KEY(order_id) REFERENCES orders(id),
          FOREIGN KEY(product_id) REFERENCES products(id)
        );
      ''',
    );

    // Inserindo pratos iniciais
    await db.insert(
      'products',
      Product(
        name: 'Spaghetti à Bolonhesa',
        description:
            'Macarrão spaghetti com molho de carne moída e tomates frescos.',
        price: 35.0,
        url: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5yv4yJmGa9aIwpirzERd8q_OxLUgQnf50xg&s"
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'products',
      Product(
        name: 'Frango à Parmegiana',
        description:
            'Peito de frango empanado coberto com queijo e molho de tomate, acompanhado de arroz e batata frita.',
        price: 40.0,
        url: 'https://www.receiteria.com.br/wp-content/uploads/file-de-frango-parmegiana.jpeg'
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'products',
      Product(
        name: 'Risoto de Camarão',
        description:
            'Risoto cremoso com camarões frescos e um toque de limão siciliano.',
        price: 50.0,
        url: 'https://www.receiteria.com.br/wp-content/uploads/risoto-de-camarao-14.jpg'
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'products',
      Product(
        name: 'Salada Caesar',
        description:
            'Alface fresca, frango grelhado, croutons, e molho Caesar caseiro.',
        price: 25.0,
        url: 'https://p2.trrsf.com/image/fget/cf/1200/900/middle/images.terra.com/2023/02/28/whatsapp-image-2023-02-28-at-01-53-47-(1)-1iyhprrq5e9tc.jpeg'
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'products',
      Product(
        name: 'Filé Mignon ao Molho Madeira',
        description:
            'Corte nobre de filé mignon servido com molho madeira e batatas gratinadas.',
        price: 70.0,
        url: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRjTTu4BHXEpljv3uksYe8ggZdGLyKmhZ7kw&s'
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert(
      'products',
      Product(
        name: 'Tiramisu',
        description:
            'Sobremesa clássica italiana com camadas de biscoito champagne, café e creme mascarpone.',
        price: 20.0,
        url: 'https://static.itdg.com.br/images/1200-675/4667c6b17f2c045e601de0d092c2d318/339498-original-1-.jpg'
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserInfo(String email) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null; // Usuário não encontrado
    }
  }

  Future<void> updateUserInfo(
      String userName, String email, String biography) async {
    final db = await database;
    await db.update(
      'users',
      {
        'usrName': userName,
        'biografia': biography,
      },
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<Users?> login(Users user) async {
    final Database db = await database;

    // Realiza a consulta para encontrar o usuário com base no nome e senha fornecidos
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [user.usrName, user.usrPassword]);

    if (result.isNotEmpty) {
      // Converte o primeiro resultado para o modelo Users e o retorna
      return Users.fromMap(result.first);
    } else {
      // Retorna null se nenhum usuário for encontrado
      return null;
    }
  }

  Future<List<Order>> getOrdersByUser(String email) async {
  final db = await database;
  
  // Busca os pedidos do usuário
  final List<Map<String, dynamic>> ordersMap = await db.query(
    'orders',
    where: 'email = ?',
    whereArgs: [email],
  );

  // Para cada pedido, buscamos os produtos associados
  List<Order> orders = [];
  for (var orderMap in ordersMap) {
    final List<Map<String, dynamic>> orderItemsMap = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderMap['id']],
    );

    // Buscar os detalhes dos produtos relacionados
    List<OrderItem> orderItems = [];
    for (var itemMap in orderItemsMap) {
      final productMap = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [itemMap['product_id']],
      );

      if (productMap.isNotEmpty) {
        Product product = Product.fromMap(productMap.first);
        int quantity = itemMap['quantity'];
        orderItems.add(OrderItem(product: product, quantity: quantity));
      }
    }

    // Criar a instância de Order com os produtos e suas quantidades
    orders.add(Order.fromMap(orderMap, orderItems));
  }

  return orders;
}


  Future<int> signup(Users user) async {
    final Database db = await database;

    return db.insert('users', user.toMap());
  }

  // Método para buscar todos os produtos
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Método para inserir um pedido
  Future<void> insertOrder(Order order, String email) async {
    final db = await database;

    // Começar uma transação
    await db.transaction((txn) async {
      // Inserir o pedido na tabela orders
      int orderId = await txn.insert('orders', {
        'total_price': order.totalPrice,
        'email': email,
        'pickup_location': order.pickupLocation, // Adicionar o local de retirada
        // Se houver outros campos, inclua aqui
      });

      // Inserir cada item na tabela order_items
      for (OrderItem orderItem in order.selectedProducts) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': orderItem.product.id, // Acessa o produto dentro de OrderItem
          'quantity': orderItem.quantity,     // Acessa a quantidade dentro de OrderItem
        });
      }
    });
  }
}