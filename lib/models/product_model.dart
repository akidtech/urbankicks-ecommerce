class Product {
  String? id;
  String name;
  String brand;
  String? category;
  double price;
  String imageUrl;
  String? description;

  Product({
    this.id,
    required this.name,
    required this.brand,
    this.category,
    required this.price,
    required this.imageUrl,
    this.description,
  });

  // Convert JSON ke Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'],
    );
  }

  // Convert Object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
