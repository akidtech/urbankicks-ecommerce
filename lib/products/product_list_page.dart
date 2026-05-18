import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/theme.dart';
import 'package:urbankicks/services/product_service.dart';
import 'package:urbankicks/models/product_model.dart';
import 'package:urbankicks/dashboard/mainpage/product_detail_page.dart';
import 'package:urbankicks/products/add_product_page.dart';
import 'package:urbankicks/products/edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  List<Product> productList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load produk
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final products = await _productService.getAllProducts();

      if (!mounted) return;

      setState(() {
        productList = products;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: alertColor,
        ),
      );
    }
  }

  // Hapus Produk
  void _confirmDelete(Product product) {
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
              style: textStyle.copyWith(
                color: aktifTextColor,
                fontWeight: bold,
              ),
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
                    .deleteProduct(product.id!)
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
                print('❌ Error delete produk: $e');
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

                // Refresh data
                await _loadProducts();
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
              style: TextStyle(color: alertColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        title: Text(
          'Management Produk',
          style: TextStyle(color: primaryTextColor),
        ),
        backgroundColor: bgColor3,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : productList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.box, size: 80, color: placeholderTextColor),
                  SizedBox(height: 20),
                  Text(
                    'Belum ada produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan produk pertama anda!',
                    style: TextStyle(color: placeholderTextColor),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              color: primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.all(15),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];

                  return Card(
                    margin: EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );

                        if (!mounted) return;

                        if (result == true) {
                          _loadProducts();
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imageUrl,
                                width: 125,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: bgColor2,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Iconsax.box,
                                      size: 40,
                                      color: placeholderTextColor,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: bgColor2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                            SizedBox(width: 15),

                            // Produk Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Brand & Category
                                  Text(
                                    '${product.brand} - ${product.category}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cardTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),

                                  // Nama Produk
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),

                                  // Harga
                                  Text(
                                    'Rp.${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: placeholderTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  // Tombol Aksi
                                  Row(
                                    children: [
                                      // Edit Button
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProductPage(
                                                      product: product,
                                                    ),
                                              ),
                                            );

                                            if (!mounted) return;

                                            if (result == true) {
                                              _loadProducts();
                                            }
                                          },
                                          icon: Icon(Iconsax.edit, size: 16),
                                          label: Text('Edit'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: thirdColor,
                                            side: BorderSide(color: thirdColor),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),

                                      // Hapus Button
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _confirmDelete(product),
                                          icon: Icon(Iconsax.trash, size: 16),
                                          label: Text('Hapus'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: alertColor,
                                            side: BorderSide(color: alertColor),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );

          if (!mounted) return;

          if (result == true) {
            _loadProducts(); // Refresh setelah tambah produk
          }
        },
        backgroundColor: primaryColor,
        elevation: 4,
        icon: Icon(Iconsax.add, color: secondaryTextColor, size: 20),
        label: Text(
          'Tambah Produk',
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
