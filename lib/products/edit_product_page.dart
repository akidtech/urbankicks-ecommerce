import 'package:flutter/material.dart';
import 'package:urbankicks/models/product_model.dart';
import 'package:urbankicks/services/product_service.dart';
import 'package:urbankicks/theme.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;

  late String _selectedBrand;
  String? _selectedCategory; // Nullable - Optional category
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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with product data
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );

    // Pastikan brand yang dipilih ada di list
    _selectedBrand = _brands.contains(widget.product.brand)
        ? widget.product.brand
        : 'Nike';

    // Pastikan category valid (bisa null)
    final categoryValues = _categories.map((c) => c['value']).toList();
    if (categoryValues.contains(widget.product.category)) {
      _selectedCategory = widget.product.category;
    } else {
      _selectedCategory = null; // Default null kalau category gak valid
    }

    _imagePreviewUrl = widget.product.imageUrl;
  }

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
        title: Text('Edit Produk', style: TextStyle(color: primaryTextColor)),
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

                    // Gambar URL
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
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
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

                    // Deskripsi
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

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Update Produk',
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

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Product updatedProduct = Product(
        id: widget.product.id,
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

      final result = await _productService.updateProduct(
        widget.product.id!,
        updatedProduct,
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk Berhasil Diperbarui!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui produk. Silakan coba lagi.'),
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
