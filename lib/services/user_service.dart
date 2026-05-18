import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbankicks/models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://6927c568b35b4ffc5013042c.mockapi.io';

  // ============= CREATE =============
  Future<User?> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      print('Response status: ${response.statusCode}'); // DEBUG
      print('Response body: ${response.body}'); // DEBUG

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // ============= READ ALL =============
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        print('Failed to fetch users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // ============= READ ONE =============
  Future<User?> getUserById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // ============= UPDATE =============
  Future<User?> updateUser(String id, User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to update user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // ============= DELETE =============
  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // ============= LOGIN =============
  Future<User?> login(String email, String password) async {
    try {
      // Get all users from API
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<User> users = data.map((json) => User.fromJson(json)).toList();

        // Find user with matching email and password
        for (var user in users) {
          if (user.email.toLowerCase() == email.toLowerCase() &&
              user.password == password) {
            // Check if user is active
            if (!user.isActive) {
              throw Exception('Account is inactive. Please contact admin.');
            }
            return user;
          }
        }

        // No matching user found
        return null;
      } else {
        print('Failed to fetch users for login: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  // ============= REGISTER =============
  Future<User?> register(User newUser) async {
    try {
      // Check if email already exists
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<User> users = data.map((json) => User.fromJson(json)).toList();

        // Check for duplicate email (case insensitive)
        bool emailExists = users.any(
          (user) => user.email.toLowerCase() == newUser.email.toLowerCase(),
        );

        if (emailExists) {
          throw Exception('Email already registered');
        }

        // Create new user if email doesn't exist
        return await createUser(newUser);
      } else {
        print('Failed to check existing users: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  // ============= CHECK EMAIL EXISTS =============
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<User> users = data.map((json) => User.fromJson(json)).toList();

        return users.any(
          (user) => user.email.toLowerCase() == email.toLowerCase(),
        );
      }
      return false;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
