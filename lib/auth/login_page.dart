import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/theme.dart';
import 'package:urbankicks/auth/register_page.dart';
import 'package:urbankicks/dashboard/main_page.dart';
import 'package:urbankicks/services/auth_service.dart';
import 'package:urbankicks/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Validate input
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan masukkan email anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan masukkan password anda'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        // Save login session
        await _authService.saveLoginSession(user);

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Berhasil! Selamat Datang ${user.name}'),
            backgroundColor: primaryColor,
          ),
        );

        // Navigasi ke mainpage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        // Login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email atau password tidak valid'),
            backgroundColor: alertColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Pengecualian: ', '')),
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
    // Widget header
    Widget header() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Center(
            child: Text(
              'LOGIN',
              style: textStyle.copyWith(
                color: primaryTextColor,
                fontSize: 34,
                fontWeight: bold,
              ),
            ),
          ),
        ],
      );
    }

    // Widget form login
    Widget loginForm() {
      return Container(
        margin: const EdgeInsets.only(top: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Email
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
            // Field Password
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
            // Tombol Login
            GestureDetector(
              onTap: _isLoading ? null : _handleLogin,
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
                          'Login',
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
        margin: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun?',
              style: textStyle.copyWith(
                color: primaryTextColor,
                fontSize: 14,
                fontWeight: medium,
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              ),
              child: Text(
                'Daftar Disini',
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
        margin: const EdgeInsets.only(top: 10, left: 35, right: 35),
        child: ListView(children: [header(), loginForm()]),
      ),
      bottomNavigationBar: footer(),
    );
  }
}
