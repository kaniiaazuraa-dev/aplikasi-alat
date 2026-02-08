import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/login.dart';
import '../admin/daftar_user_page.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    // ================= NAMA USER =================
    final String nama =
        user?.userMetadata?['nama'] ?? user?.email ?? 'Pengguna';

    // ================= ROLE =================
    final String role =
        ((user?.userMetadata?['role'] ??
                user?.appMetadata['role'] ??
                'peminjam')
            .toString()
            .trim()
            .toLowerCase());

    // ================= MENU PER ROLE =================
    final List<Map<String, dynamic>> menuAdmin = [
      {'icon': Icons.person_outline, 'title': 'Edit Profil', 'onTap': () {}},
      {
        'icon': Icons.manage_accounts_outlined,
        'title': 'Manajemen Akun',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DaftarUserPage()),
          );
        },
      },
      {'icon': Icons.lock_outline, 'title': 'Ubah Password', 'onTap': () {}},
      {'icon': Icons.info_outline, 'title': 'Tentang Aplikasi', 'onTap': () {}},
    ];

    final List<Map<String, dynamic>> menuPetugas = [
      {'icon': Icons.person_outline, 'title': 'Edit Profil', 'onTap': () {}},
      {'icon': Icons.lock_outline, 'title': 'Ubah Password', 'onTap': () {}},
      {'icon': Icons.info_outline, 'title': 'Tentang Aplikasi', 'onTap': () {}},
    ];

    final List<Map<String, dynamic>> menuPeminjam = [
      {'icon': Icons.person_outline, 'title': 'Edit Profil', 'onTap': () {}},
      {'icon': Icons.lock_outline, 'title': 'Ubah Password', 'onTap': () {}},
    ];

    // ================= PILIH MENU =================
    List<Map<String, dynamic>> menus;
    switch (role) {
      case 'admin':
        menus = menuAdmin;
        break;
      case 'petugas':
        menus = menuPetugas;
        break;
      default:
        menus = menuPeminjam;
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF000D33),
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // ================= PROFIL =================
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF000D33),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      nama[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000D33),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role == 'admin'
                      ? 'Admin'
                      : role == 'petugas'
                      ? 'Petugas'
                      : 'Peminjam',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ================= MENU =================
            Column(
              children:
                  menus.map((menu) {
                    return _menuButton(
                      icon: menu['icon'],
                      title: menu['title'],
                      onTap: menu['onTap'],
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // ================= LOGOUT =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Keluar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENU BUTTON =================
  Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF000D33)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT DIALOG =================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Icon(Icons.error_outline, size: 40),
            content: const Text(
              'Apakah Anda Yakin Ingin\nKeluar dari Akun ini?',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000D33),
                ),
                onPressed: () async {
                  await supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('Iya'),
              ),
            ],
          ),
    );
  }
}
