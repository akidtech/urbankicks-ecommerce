import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/dashboard/mainpage/home_page.dart';
import 'package:urbankicks/dashboard/mainpage/cart_page.dart';
import 'package:urbankicks/dashboard/mainpage/profile_admin_page.dart';
import 'package:urbankicks/dashboard/mainpage/profile_customer_page.dart';
import 'package:urbankicks/users/users_page.dart';
import 'package:urbankicks/products/product_list_page.dart';
import 'package:urbankicks/services/auth_service.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/auth/login_page.dart';
import 'package:urbankicks/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  User? _currentUser;
  bool _isLoading = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // Pages untuk Customer
  List<Widget> _customerPages() {
    return [HomePage(), CartPage(), ProfileCustomerPage()];
  }

  // Pages untuk Admin
  List<Widget> _adminPages() {
    return [
      HomePage(),
      ProductListPage(),
      UsersPage(), //
      ProfileAdminPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor1,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final isAdmin = _currentUser?.role == 'admin';
    final pages = isAdmin ? _adminPages() : _customerPages();

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgColor1,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: isAdmin ? _adminNavItems() : _customerNavItems(),
      ),
    );
  }

  // Navigation items untuk Customer
  List<BottomNavigationBarItem> _customerNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Beranda'),
      BottomNavigationBarItem(
        icon: Icon(Iconsax.shopping_cart),
        label: 'Keranjang',
      ),
      BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profil'),
    ];
  }

  // Navigation items untuk Admin
  List<BottomNavigationBarItem> _adminNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Beranda'),
      BottomNavigationBarItem(icon: Icon(Iconsax.box), label: 'Produk'),
      BottomNavigationBarItem(icon: Icon(Iconsax.people), label: 'User'),
      BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profil'),
    ];
  }
}
