class CartItem {
  String productId;
  String name;
  String brand;
  int price;
  int quantity;
  int size;
  String? image;

  CartItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.size,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'brand': brand,
      'price': price,
      'quantity': quantity,
      'size': size,
      'image': image,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? 0,
      image: json['image'],
    );
  }

  int get totalPrice => price * quantity;
}
