import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/models/cart_model.dart';
import 'package:urbankicks/services/cart_service.dart';
import 'package:urbankicks/theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      isLoading = true;
    });

    final items = await _cartService.getCartItems();

    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  int get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _increaseQuantity(int index) async {
    final item = cartItems[index];
    await _cartService.updateQuantity(
      item.productId,
      item.size,
      item.quantity + 1,
    );
    _loadCartItems();
  }

  void _decreaseQuantity(int index) async {
    final item = cartItems[index];
    if (item.quantity > 1) {
      await _cartService.updateQuantity(
        item.productId,
        item.size,
        item.quantity - 1,
      );
      _loadCartItems();
    }
  }

  void _removeItem(int index) {
    final item = cartItems[index];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: bgColor2,
        title: Text('Hapus Item', style: TextStyle(color: primaryTextColor)),
        content: Text(
          'Apakah anda yakin ingin menghapus item ini dari keranjang?',
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: secondaryTextColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              await _cartService.removeFromCart(item.productId, item.size);

              if (!mounted) return;

              _loadCartItems();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item berhasil dihapus dari keranjang'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            child: Text('Hapus', style: TextStyle(color: alertColor)),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang anda masih kosong'),
          backgroundColor: alertColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: bgColor2,
        title: Text('Checkout', style: TextStyle(color: primaryTextColor)),
        content: Text(
          'Total pembayaran: Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: secondaryTextColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await _cartService.clearCart();

              if (!mounted) return;

              _loadCartItems();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Checkout berhasil! Terima kasih sudah berbelanja.',
                  ),
                  backgroundColor: primaryColor,
                ),
              );
            },
            child: Text(
              'Bayar Sekarang',
              style: TextStyle(color: primaryColor),
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
        automaticallyImplyLeading: false,
        title: Text(
          'Keranjang Belanja',
          style: textStyle.copyWith(
            color: primaryTextColor,
            fontSize: 22,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: bgColor3,
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: bgColor2,
                    title: Text(
                      'Hapus Semua',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    content: Text(
                      'Hapus semua item dari keranjang?',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);

                          await _cartService.clearCart();

                          if (!mounted) return;

                          _loadCartItems();
                        },
                        child: Text(
                          'Hapus Semua',
                          style: TextStyle(color: alertColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Iconsax.trash, color: alertColor),
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(index);
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shopping_cart, size: 100, color: placeholderTextColor),
          SizedBox(height: 20),
          Text(
            'Keranjang Kosong',
            style: textStyle.copyWith(
              fontSize: 22,
              fontWeight: semiBold,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada produk di keranjang anda',
            style: textStyle.copyWith(fontSize: 14, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cartItems[index];

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor2,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Iconsax.box,
                          size: 40,
                          color: placeholderTextColor,
                        );
                      },
                    ),
                  )
                : Icon(Iconsax.box, size: 40, color: placeholderTextColor),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                    color: secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  item.brand,
                  style: textStyle.copyWith(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Size: ${item.size}',
                  style: textStyle.copyWith(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: textStyle.copyWith(
                    fontSize: 15,
                    fontWeight: semiBold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: alertColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Iconsax.trash, size: 18, color: alertColor),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: bgColor3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _decreaseQuantity(index),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Iconsax.minus,
                          size: 16,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: textStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _increaseQuantity(index),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Iconsax.add,
                          size: 16,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor2,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Item',
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                '${cartItems.length} item',
                style: textStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: textStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Checkout',
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
