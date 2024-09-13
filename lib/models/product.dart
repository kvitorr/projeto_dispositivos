class Product {
  final int? id; // Deixe o id como opcional, pois ele será gerado automaticamente pelo banco de dados
  final String name;
  final String description;
  final double price;
  final String url;

  Product({
    this.id, // Torne o id opcional
    required this.name,
    required this.description,
    required this.price,
    required this.url
  });

  // Convertendo Produto para Map para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'url': url
    };
  }

  // Convertendo de Map para Produto para ler do banco de dados
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      url: map['url']
    );
  }
}
