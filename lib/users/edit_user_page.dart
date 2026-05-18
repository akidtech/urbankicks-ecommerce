import 'package:flutter/material.dart';
import 'package:urbankicks/theme.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/services/user_service.dart';

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _passwordController = TextEditingController();

  late String _selectedRole;
  late bool _isActive;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final UserService _userService = UserService();

  final List<Map<String, String>> _roles = [
    {'value': 'customer', 'label': 'Customer'},
    {'value': 'admin', 'label': 'Admin'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        title: Text('Edit User', style: TextStyle(color: Colors.black)),
        backgroundColor: bgColor3,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgForm,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Iconsax.user),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silahkan masukkan nama';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Email
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgForm,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Iconsax.message),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'silahkan masukkan email';
                        }
                        if (!value.contains('@')) {
                          return 'Silahkan masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Nomor Telepon
                    Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgForm,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Iconsax.call),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silahkan masukkan nomor telepon';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Password
                    Text(
                      'Password Baru ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgForm,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Iconsax.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password harus minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Role
                    Text(
                      'Role',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgForm,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Iconsax.personalcard),
                        ),
                        items: _roles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role['value'],
                                child: Text(role['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Status Aktif
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgForm,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.tick_circle),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Status Aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Update User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
        isActive: _isActive,
        createdAt: widget.user.createdAt,
      );

      final result = await _userService.updateUser(
        widget.user.id!,
        updatedUser,
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User berhasil diperbarui!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui user. Silakan coba lagi..'),
            backgroundColor: alertColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
