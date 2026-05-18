import 'package:flutter/material.dart';
import 'package:urbankicks/theme.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/services/user_service.dart';
import 'package:urbankicks/users/add_user_page.dart';
import 'package:urbankicks/users/edit_user_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService _userService = UserService();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    final fetchedUsers = await _userService.getAllUsers();

    if (!mounted) return;

    setState(() {
      users = fetchedUsers;
      isLoading = false;
    });
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Hapus User',
          style: textStyle.copyWith(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${user.name}"?',
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

              if (user.id == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ID User tidak valid'),
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
                print('🗑️ Mulai delete user ID: ${user.id}');

                final result = await _userService
                    .deleteUser(user.id!)
                    .timeout(
                      Duration(seconds: 15),
                      onTimeout: () {
                        print('⏰ Timeout delete user');
                        return false;
                      },
                    );

                deleteSuccess = result;
                print('✅ Delete result: $result');
              } catch (e) {
                print('❌ Error delete user: $e');
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
                    content: Text('User Berhasil Dihapus!'),
                    backgroundColor: primaryColor,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Refresh data
                await _loadUsers();
              } else {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      errorMessage.isEmpty
                          ? 'Gagal menghapus user'
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
        automaticallyImplyLeading: false,
        title: Text(
          'Management User',
          style: TextStyle(color: primaryTextColor),
        ),
        backgroundColor: bgColor3,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.people, size: 80, color: placeholderTextColor),
                  SizedBox(height: 20),
                  Text(
                    'Belum ada user',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan user pertama anda!',
                    style: TextStyle(color: placeholderTextColor),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUsers,
              color: primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    margin: EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: user.role == 'admin'
                                    ? secondaryColor
                                    : primaryColor,
                                child: Icon(
                                  user.role == 'admin'
                                      ? Iconsax.shield_tick
                                      : Iconsax.user,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: placeholderTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isActive ? bgAktif : bgInaktif,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.isActive ? 'Aktif' : 'Tidak Aktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: user.isActive
                                        ? aktifTextColor
                                        : inaktifTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Iconsax.call, size: 16, color: bgColor2),
                              SizedBox(width: 8),
                              Text(
                                user.phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryTextColor,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: user.role == 'admin'
                                      ? bgAdmin
                                      : bgcust,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: user.role == 'admin'
                                        ? adminTextColor
                                        : placeholderTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditUserPage(user: user),
                                    ),
                                  );

                                  if (!mounted) return;

                                  if (result == true) {
                                    _loadUsers();
                                  }
                                },
                                icon: Icon(Iconsax.edit, size: 18),
                                label: Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: thirdColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _confirmDelete(user),
                                icon: Icon(Iconsax.trash, size: 18),
                                label: Text('Hapus'),
                                style: TextButton.styleFrom(
                                  foregroundColor: alertColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

      // FAB - TAMBAH USER
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserPage()),
          );

          if (!mounted) return;

          if (result == true) {
            _loadUsers(); // Refresh setelah tambah user
          }
        },
        backgroundColor: primaryColor,
        elevation: 4,
        icon: Icon(Iconsax.user_add, color: Colors.white, size: 24),
        label: Text(
          'Tambah User',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
