import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbankicks/models/cart_model.dart';
import 'dart:convert';

class CartService {
  static const String _keyCart = 'cart_items';

  Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_keyCart);

      if (cartData != null) {
        List<dynamic> decoded = json.decode(cartData);
        return decoded.map((item) => CartItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  Future<bool> addToCart(CartItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();

      int existingIndex = cartItems.indexWhere(
        (cartItem) =>
            cartItem.productId == item.productId && cartItem.size == item.size,
      );

      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += item.quantity;
      } else {
        cartItems.add(item);
      }

      final jsonData = json.encode(
        cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_keyCart, jsonData);
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  Future<bool> updateQuantity(
    String productId,
    int size,
    int newQuantity,
  ) async {
    try {
      if (newQuantity < 1) return false;

      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();

      int index = cartItems.indexWhere(
        (item) => item.productId == productId && item.size == size,
      );

      if (index != -1) {
        cartItems[index].quantity = newQuantity;
        final jsonData = json.encode(
          cartItems.map((item) => item.toJson()).toList(),
        );
        await prefs.setString(_keyCart, jsonData);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(String productId, int size) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<CartItem> cartItems = await getCartItems();

      cartItems.removeWhere(
        (item) => item.productId == productId && item.size == size,
      );

      final jsonData = json.encode(
        cartItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_keyCart, jsonData);
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCart);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  Future<int> getCartCount() async {
    try {
      final items = await getCartItems();
      int total = 0;
      for (var item in items) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  Future<int> getTotalPrice() async {
    try {
      final items = await getCartItems();
      int total = 0;
      for (var item in items) {
        total += item.totalPrice;
      }
      return total;
    } catch (e) {
      print('Error getting total price: $e');
      return 0;
    }
  }
}
