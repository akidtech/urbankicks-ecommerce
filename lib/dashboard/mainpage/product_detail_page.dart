import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/theme.dart';
import 'package:urbankicks/models/product_model.dart';
import 'package:urbankicks/models/cart_model.dart';
import 'package:urbankicks/services/product_service.dart';
import 'package:urbankicks/services/cart_service.dart';
import 'package:urbankicks/services/auth_service.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/products/edit_product_page.dart';
import 'package:urbankicks/dashboard/mainpage/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();

  User? _currentUser;
  int selectedSize = 40; // Default size
  int quantity = 1; // Default quantity

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isCustomer = _currentUser?.role == 'customer';
    final isAdmin = _currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        backgroundColor: bgColor3,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Produk',
          style: textStyle.copyWith(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,

        // ========== TOMBOL EDIT & DELETE (ADMIN ONLY) ==========
        actions: isAdmin
            ? [
                // Tombol Edit
                IconButton(
                  icon: Icon(Iconsax.edit, color: primaryTextColor),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(product: product),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  },
                ),

                // Tombol Hapus
                IconButton(
                  icon: Icon(Iconsax.trash, color: alertColor),
                  onPressed: () => _confirmDelete(context, product),
                ),
                SizedBox(width: 8),
              ]
            : [], // Customer tidak ada tombol edit/delete
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
              Center(
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 100),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Brand
              Text(
                product.brand,
                style: textStyle.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(height: 4),

              // Nama Produk
              Text(
                product.name,
                style: textStyle.copyWith(
                  color: primaryTextColor,
                  fontSize: 24,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 4),

              // Harga
              Text(
                'Rp.${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: textStyle.copyWith(
                  color: priceColor,
                  fontSize: 20,
                  fontWeight: bold,
                ),
              ),
              const SizedBox(height: 20),

              // Deskripsi Produk
              Text(
                product.description ?? 'Tidak ada deskripsi yang tersedia',
                style: textStyle.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: regular,
                ),
              ),
              const SizedBox(height: 30),

              // ========== PILIH SIZE (CUSTOMER ONLY) ==========
              if (isCustomer) ...[
                Text(
                  'Pilih Ukuran',
                  style: textStyle.copyWith(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [38, 39, 40, 41, 42, 43, 44, 45].map((size) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSize = size;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selectedSize == size ? primaryColor : bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedSize == size ? primaryColor : bgCard,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          size.toString(),
                          style: textStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                            color: selectedSize == size
                                ? bgCard
                                : primaryTextColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ========== JUMLAH (CUSTOMER ONLY) ==========
                Text(
                  'Jumlah',
                  style: textStyle.copyWith(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Iconsax.minus, color: primaryTextColor),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        quantity.toString(),
                        style: textStyle.copyWith(
                          fontSize: 18,
                          fontWeight: semiBold,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Iconsax.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space untuk bottom button
              ],
            ],
          ),
        ),
      ),

      // ========== BOTTOM BUTTON (CUSTOMER ONLY) ==========
      bottomNavigationBar: isCustomer
          ? Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: Icon(Iconsax.shopping_cart, color: bgCard),
                  label: Text(
                    'Tambah ke Keranjang',
                    style: textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                      color: secondaryTextColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null, // Admin gak ada bottom button
    );
  }

  // ========== METHOD ADD TO CART ==========
  void _addToCart() async {
    final product = widget.product;

    CartItem item = CartItem(
      productId: product.id.toString(),
      name: product.name,
      brand: product.brand,
      price: product.price.toInt(),
      quantity: quantity,
      size: selectedSize,
      image: product.imageUrl,
    );

    bool success = await _cartService.addToCart(item);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} berhasil ditambahkan ke keranjang!'),
          backgroundColor: primaryColor,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: secondaryTextColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ),
      );

      // Reset quantity & size
      setState(() {
        quantity = 1;
        selectedSize = 40;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan ke keranjang'),
          backgroundColor: alertColor,
        ),
      );
    }
  }

  // ========== METHOD DELETE (ADMIN ONLY) ==========
  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Hapus Produk',
          style: textStyle.copyWith(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}"?',
          style: textStyle.copyWith(color: cardTextColor, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: textStyle.copyWith(color: primaryColor, fontWeight: bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Tutup dialog konfirmasi dulu
              Navigator.pop(dialogContext);

              if (product.id == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ID Produk tidak valid'),
                    backgroundColor: alertColor,
                  ),
                );
                return;
              }

              // Simpan BuildContext sebelum async
              final scaffoldContext = context;

              // Show loading dengan BuildContext baru
              showDialog(
                context: scaffoldContext,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) => PopScope(
                  canPop: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
              );

              // Proses delete
              bool deleteSuccess = false;
              String errorMessage = '';

              try {
                print('🗑️ Mulai delete produk ID: ${product.id}');

                final result = await _productService
                    .deleteProduct(product.id.toString())
                    .timeout(
                      Duration(seconds: 15),
                      onTimeout: () {
                        print('⏰ Timeout delete produk');
                        return false;
                      },
                    );

                deleteSuccess = result;
                print('✅ Delete result: $result');
              } catch (e) {
                print('❌ Error delete: $e');
                errorMessage = e.toString();
                deleteSuccess = false;
              }

              // Tutup loading - PASTI TUTUP
              if (mounted) {
                Navigator.of(scaffoldContext).pop();
              }

              // Tunggu sebentar
              await Future.delayed(Duration(milliseconds: 200));

              // Cek mounted lagi
              if (!mounted) return;

              // Tampilkan hasil
              if (deleteSuccess) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Produk Berhasil Dihapus!'),
                    backgroundColor: primaryColor,
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(Duration(milliseconds: 500));

                if (!mounted) return;

                // Kembali dengan flag refresh
                Navigator.pop(scaffoldContext, true);
              } else {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      errorMessage.isEmpty
                          ? 'Gagal menghapus produk'
                          : 'Error: $errorMessage',
                    ),
                    backgroundColor: alertColor,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(
              'Hapus',
              style: textStyle.copyWith(color: alertColor, fontWeight: bold),
            ),
          ),
        ],
      ),
    );
  }
}
