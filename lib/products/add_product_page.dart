import 'package:flutter/material.dart';
import 'package:urbankicks/models/product_model.dart';
import 'package:urbankicks/services/product_service.dart';
import 'package:urbankicks/theme.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedBrand = 'Nike';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _imagePreviewUrl;

  final ProductService _productService = ProductService();

  final List<String> _brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Asics',
    'New Balance',
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'popularProducts', 'label': 'Popular Products'},
    {'value': 'newArrivals', 'label': 'New Arrivals'},
  ];

  // Preview image dari URL
  void _previewImage() {
    if (_imageUrlController.text.isNotEmpty) {
      setState(() {
        _imagePreviewUrl = _imageUrlController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor3,
      appBar: AppBar(
        title: Text('Tambah Produk', style: TextStyle(color: primaryTextColor)),
        backgroundColor: bgColor3,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
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
                    // Nama Produk
                    Text(
                      'Nama Produk',
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
                        fillColor: bgCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silahkan Masukkan Nama Produk';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Brand
                    Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBrand,
                        decoration: InputDecoration(border: InputBorder.none),
                        items: _brands
                            .map(
                              (brand) => DropdownMenuItem(
                                value: brand,
                                child: Text(brand),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Kategori
                    Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(border: InputBorder.none),
                        hint: Text('Pilih Kategori'),
                        items: [
                          DropdownMenuItem(value: null, child: Text('None')),
                          ..._categories.map(
                            (category) => DropdownMenuItem(
                              value: category['value'],
                              child: Text(category['label']!),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Harga
                    Text(
                      'Harga',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: bgCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silahkan Masukkan Harga';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Silahkan Masukkan Angka Yang Valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Image URL
                    Text(
                      'URL Gambar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Silahkan Masukkan URL Gambar';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Auto preview pas ngetik
                              if (value.startsWith('http')) {
                                _previewImage();
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _previewImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: Icon(Icons.preview, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Image Preview
                    if (_imagePreviewUrl != null) ...[
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imagePreviewUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Gagal Memuat Gambar',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Periksa URL Anda',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    categoryTextColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    SizedBox(height: 20),

                    // Description
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tambah Produk',
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

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Product newProduct = Product(
        name: _nameController.text,
        brand: _selectedBrand,
        category:
            _selectedCategory ?? _selectedBrand, // Kalau null, pakai brand
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      final result = await _productService.createProduct(newProduct);

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk Berhasil Ditambahkan!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal Menambahkan Produk, Silahkan Coba Lagi.'),
            backgroundColor: alertColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
