class User {
  String? id;
  String name;
  String email;
  String phone;
  String role;
  String? password;
  bool isActive;
  String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.password,
    required this.isActive,
    required this.createdAt,
  });

  // Convert JSON ke Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      password: json['password'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
    );
  }

  // Convert Object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
