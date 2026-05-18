import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urbankicks/services/auth_service.dart';
import 'package:urbankicks/models/user_model.dart';
import 'package:urbankicks/auth/login_page.dart';
import 'package:urbankicks/theme.dart';

class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor2,
        title: Text('Logout', style: TextStyle(color: primaryTextColor)),
        content: Text(
          'Apakah anda yakin ingin logout?',
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            child: Text('Logout', style: TextStyle(color: alertColor)),
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
          'Profil Admin',
          style: textStyle.copyWith(
            color: primaryTextColor,
            fontSize: 22,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: bgColor3,
        elevation: 0,
      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: bgColor1,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: secondaryColor,
                          child: Icon(
                            Iconsax.shield_tick,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _currentUser!.name,
                          style: textStyle.copyWith(
                            fontSize: 22,
                            fontWeight: semiBold,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _currentUser!.email,
                          style: textStyle.copyWith(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bgAdmin,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentUser!.role.toUpperCase(),
                            style: textStyle.copyWith(
                              fontSize: 12,
                              color: adminTextColor,
                              fontWeight: bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Info Profil
                  _buildInfoTile(
                    icon: Iconsax.call,
                    title: 'Nomor Telepon',
                    value: _currentUser!.phone,
                  ),
                  SizedBox(height: 15),
                  _buildInfoTile(
                    icon: Iconsax.calendar,
                    title: 'Bergabung Sejak',
                    value: _currentUser!.createdAt,
                  ),
                  SizedBox(height: 15),
                  _buildInfoTile(
                    icon: Iconsax.shield_tick,
                    title: 'Status Akun',
                    value: _currentUser!.isActive ? 'Aktif' : 'Tidak Aktif',
                    valueColor: _currentUser!.isActive
                        ? aktifTextColor
                        : inaktifTextColor,
                  ),
                  SizedBox(height: 30),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Iconsax.logout, color: bgCard),
                      label: Text(
                        'Logout',
                        style: textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                          color: bgCard,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alertColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: categoryColor, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textStyle.copyWith(
                    fontSize: 14,
                    color: secondaryTextColor,
                    fontWeight: regular,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: textStyle.copyWith(
                    fontSize: 15,
                    fontWeight: medium,
                    color: valueColor ?? primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
