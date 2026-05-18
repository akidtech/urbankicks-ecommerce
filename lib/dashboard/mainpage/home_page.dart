import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/dashboard/mainpage/product_detail_page.dart';
import 'package:urbankicks/theme.dart';
import 'package:urbankicks/models/product_model.dart';
import 'package:urbankicks/services/product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentCategories = 'all';

  final ProductService _productService = ProductService();
  List<Product> allProducts = [];
  bool isLoading = true;

  final listCategories = [
    {'key': 'all', 'value': 'All Shoes'},
    {'key': 'nike', 'value': 'Nike'},
    {'key': 'adidas', 'value': 'Adidas'},
    {'key': 'puma', 'value': 'Puma'},
    {'key': 'asics', 'value': 'Asics'},
    {'key': 'new balance', 'value': 'New Balance'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    final products = await _productService.getAllProducts();

    if (!mounted) return;

    setState(() {
      allProducts = products;
      isLoading = false;
    });
  }

  List<Product> get filteredProducts {
    if (currentCategories == 'all') {
      return allProducts;
    }
    return allProducts
        .where((p) => p.brand.toLowerCase() == currentCategories.toLowerCase())
        .toList();
  }

  List<Product> get popularProducts {
    final filtered = currentCategories == 'all'
        ? allProducts
        : allProducts
              .where(
                (p) => p.brand.toLowerCase() == currentCategories.toLowerCase(),
              )
              .toList();

    return filtered
        .where((p) => p.category == 'popularProducts')
        .take(10)
        .toList();
  }

  List<Product> get newArrivals {
    final filtered = currentCategories == 'all'
        ? allProducts
        : allProducts
              .where(
                (p) => p.brand.toLowerCase() == currentCategories.toLowerCase(),
              )
              .toList();

    return filtered.where((p) => p.category == 'newArrivals').take(10).toList();
  }

  List<Product> get uncategorizedProducts {
    final filtered = currentCategories == 'all'
        ? allProducts
        : allProducts
              .where(
                (p) => p.brand.toLowerCase() == currentCategories.toLowerCase(),
              )
              .toList();

    return filtered
        .where(
          (p) => p.category != 'popularProducts' && p.category != 'newArrivals',
        )
        .take(10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    Widget header() {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urban Kicks',
                  style: textStyle.copyWith(
                    color: primaryTextColor,
                    fontSize: 26,
                    fontWeight: bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Selamat Datang! Pilih Sepatu yang Pas untuk Gaya Kamu.',
                  style: textStyle.copyWith(
                    color: placeholderTextColor,
                    fontSize: 16,
                    fontWeight: regular,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget categories() {
      return Container(
        margin: const EdgeInsets.only(top: 35),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: listCategories.map((e) {
              final isActive = currentCategories == e['key'];

              return GestureDetector(
                onTap: () => setState(() {
                  currentCategories = e['key']!;
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color.fromRGBO(0, 0, 0, 1)
                        : const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(186, 0, 0, 0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    e['value']!,
                    style: textStyle.copyWith(
                      fontSize: 14,
                      color: isActive ? secondaryTextColor : categoryTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    Widget popularProductsWidget() {
      if (popularProducts.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            'Popular Products',
            style: textStyle.copyWith(
              fontSize: 22,
              color: primaryTextColor,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: popularProducts.map((product) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                        settings: RouteSettings(arguments: product),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      _loadProducts();
                    }
                  },
                  child: Card(
                    color: bgCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(right: 15),
                    child: SizedBox(
                      width: isSmallScreen ? 140 : 160,
                      height: isSmallScreen ? 220 : 245,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              height: isSmallScreen ? 100 : 120,
                              width: isSmallScreen ? 140 : 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: isSmallScreen ? 100 : 120,
                                  width: isSmallScreen ? 140 : 160,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.brand,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle.copyWith(
                                    color: cardTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.name,
                                  style: textStyle.copyWith(
                                    color: primaryTextColor,
                                    fontWeight: semiBold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp.${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: textStyle.copyWith(
                                    color: priceColor,
                                    fontSize: 12,
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    Widget newArrivalsProductsWidget() {
      if (newArrivals.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            'New Arrivals',
            style: textStyle.copyWith(
              fontSize: 22,
              color: primaryTextColor,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: newArrivals.map((product) {
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                      settings: RouteSettings(arguments: product),
                    ),
                  );

                  if (!mounted) return;

                  if (result == true) {
                    _loadProducts();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            product.imageUrl,
                            height: isSmallScreen ? 100 : 120,
                            width: isSmallScreen ? 100 : 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: isSmallScreen ? 100 : 120,
                                width: isSmallScreen ? 100 : 120,
                                color: bgCard,
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: bgCard,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.brand,
                              style: textStyle.copyWith(
                                color: cardTextColor,
                                fontSize: 12,
                                fontWeight: regular,
                              ),
                            ),
                            Text(
                              product.name,
                              style: textStyle.copyWith(
                                color: primaryTextColor,
                                fontSize: 16,
                                fontWeight: semiBold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Rp.${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: textStyle.copyWith(
                                color: priceColor,
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    Widget buildBrandProducts() {
      if (filteredProducts.isEmpty) {
        return Column(
          children: [
            SizedBox(height: 100),
            Icon(Iconsax.box, size: 80, color: secondaryTextColor),
            SizedBox(height: 20),
            Text(
              'Tidak ada produk yang ditemukan',
              style: textStyle.copyWith(
                fontSize: 18,
                color: primaryTextColor,
                fontWeight: semiBold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba pilih merek lain',
              style: textStyle.copyWith(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(
            '${currentCategories.substring(0, 1).toUpperCase()}${currentCategories.substring(1)} Produk',
            style: textStyle.copyWith(
              fontSize: 22,
              color: primaryTextColor,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isSmallScreen ? 0.70 : 0.75,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                      settings: RouteSettings(arguments: product),
                    ),
                  );

                  if (!mounted) return;

                  if (result == true) {
                    _loadProducts();
                  }
                },
                child: Card(
                  color: bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.network(
                          product.imageUrl,
                          height: isSmallScreen ? 110 : 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: isSmallScreen ? 110 : 150,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle.copyWith(
                                color: cardTextColor,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              product.name,
                              style: textStyle.copyWith(
                                color: primaryTextColor,
                                fontWeight: semiBold,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              'Rp.${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: textStyle.copyWith(
                                color: priceColor,
                                fontSize: 11,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    // Loading state
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor3,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    // Empty state
    if (allProducts.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor3,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.box, size: 80, color: secondaryTextColor),
              SizedBox(height: 20),
              Text(
                'Belum ada produk',
                style: textStyle.copyWith(
                  fontSize: 18,
                  color: primaryTextColor,
                  fontWeight: semiBold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tambahkan produk pertama Anda!',
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor3,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
          child: ListView(
            children: [
              header(),
              categories(),

              if (currentCategories != 'all')
                buildBrandProducts()
              else ...[
                popularProductsWidget(),
                newArrivalsProductsWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
