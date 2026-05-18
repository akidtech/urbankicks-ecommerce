import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbankicks/models/product_model.dart';

class ProductService {
  static const String baseUrl = 'https://6927c568b35b4ffc5013042c.mockapi.io';

  // ============= CREATE =============
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating product: $e');
      return null;
    }
  }

  // ============= READ ALL =============
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // ============= READ ONE =============
  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  // ============= UPDATE =============
  Future<Product?> updateProduct(String id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to update product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  // ============= DELETE =============
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete product: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ============= GET BY CATEGORY =============
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?category=$category'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }
}
