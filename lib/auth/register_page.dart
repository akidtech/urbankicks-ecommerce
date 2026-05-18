import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/services/auth_service.dart';
import 'package:urbankicks/services/user_service.dart';
import 'package:urbankicks/theme.dart';
import 'package:urbankicks/dashboard/main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Validasi Input
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan masukkan nama lengkap anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan masukkan nomor telepon anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan masukkan email anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan masukkan email yang valid'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan masukkan password anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password harus minimal 6 karakter'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      User newUser = User(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: 'customer', // Default role
        isActive: true,
        createdAt: formattedDate,
      );

      final user = await _userService.register(newUser);

      if (user != null) {
        // Login otomatis setelah mendaftar
        await _authService.saveLoginSession(user);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran Berhasil! Selamat Datang ${user.name}'),
            backgroundColor: primaryColor,
          ),
        );

        // Navigasi ke mainpage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: alertColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          Center(
            child: Text(
              'Daftar Disini',
              style: textStyle.copyWith(
                color: primaryTextColor,
                fontSize: 28,
                fontWeight: semiBold,
              ),
            ),
          ),
        ],
      );
    }

    Widget registerForm() {
      return Container(
        margin: const EdgeInsets.only(top: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Lengkap
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Nama Lengkap',
                    style: textStyle.copyWith(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.user, color: primaryTextColor, size: 30),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            style: textStyle.copyWith(
                              color: secondaryTextColor,
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Nama Lengkap',
                              hintStyle: textStyle.copyWith(
                                color: placeholderTextColor,
                                fontSize: 16,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Nomor Telepon
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Nomor Telepon',
                    style: textStyle.copyWith(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.call, color: primaryTextColor, size: 30),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: textStyle.copyWith(
                              color: secondaryTextColor,
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Nomor Telepon',
                              hintStyle: textStyle.copyWith(
                                color: placeholderTextColor,
                                fontSize: 16,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Email
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Email',
                    style: textStyle.copyWith(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.message,
                          color: primaryTextColor,
                          size: 30,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: textStyle.copyWith(
                              color: secondaryTextColor,
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Email',
                              hintStyle: textStyle.copyWith(
                                color: placeholderTextColor,
                                fontSize: 16,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Password
            Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Password',
                    style: textStyle.copyWith(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.lock, color: primaryTextColor, size: 25),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            style: textStyle.copyWith(
                              color: secondaryTextColor,
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Password',
                              hintStyle: textStyle.copyWith(
                                color: placeholderTextColor,
                                fontSize: 16,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                            color: placeholderTextColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Register
            GestureDetector(
              onTap: _isLoading ? null : _handleRegister,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: primaryTextColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Daftar',
                          style: textStyle.copyWith(
                            color: primaryTextColor,
                            fontSize: 18,
                            fontWeight: semiBold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget footer() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30, top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sudah punya akun?',
              style: textStyle.copyWith(
                color: primaryTextColor,
                fontSize: 14,
                fontWeight: medium,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Login',
                style: textStyle.copyWith(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor1,
      body: Container(
        margin: const EdgeInsets.only(top: 15, left: 30, right: 30),
        child: ListView(children: [header(), registerForm()]),
      ),
      bottomNavigationBar: footer(),
    );
  }
}
