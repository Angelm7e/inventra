class Product {
  final int? id;
  final String name;
  final int quantity;
  final int price;
  final String category;
  final String?
  description; //TODO: make it non nullable when description is added to the add product screen
  final String? image;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    this.description,
    this.image,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity'],
    price: json['price'],
    category: json['category'],
    description: json['description'],
    image: json['image'],
  );

  Map<String, dynamic> toQuote() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'price': price,
    'category': category,
    'description': description,
    'image': image,
  };
}
