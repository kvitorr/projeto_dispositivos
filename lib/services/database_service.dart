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
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrEmail TEXT UNIQUE, usrName TEXT UNIQUE, usrNickname TEXT UNIQUE, usrPassword TEXT, biografia TEXT)",
    );

    await db.execute(
      'CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, price REAL)',
    );
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
  }

  Future<Map<String, dynamic>?> getUserInfo(String userName) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'usrName = ?',
      whereArgs: [userName],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null; // Usuário não encontrado
    }
  }

  Future<void> updateUserInfo(String userName, String email, String biography) async {
    final db = await database;
    await db.update(
      'users',
      {
        'usrEmail': email,
        'biografia': biography,
      },
      where: 'usrName = ?',
      whereArgs: [userName],
    );
  }

  Future<bool> login(Users user) async {
    final Database db = await database;

    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [user.usrName, user.usrPassword]);
    return result.isNotEmpty;
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
  Future<void> insertOrder(Order order) async {
    final db = await database;
    
    await db.insert(
      'orders',
      order.toMap(), // Utilizando o método toMap do modelo Order
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para buscar todos os pedidos (opcional, caso queira buscar pedidos salvos)
  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }
}
