import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const MainNavigation(),
    );
  }
}

// 1. WIDGET NAVIGASI UTAMA
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Index 4 adalah posisi ikon Setting (paling kanan)
  int _selectedIndex = 4;

  // List Halaman
  final List<Widget> _pages = [
    const Center(child: Text("Home Page")),
    const Center(child: Text("Work Page")),
    const Center(child: Text("History Page")),
    const Center(child: Text("Schedule Page")),
    const ProfilePage(), // Halaman yang kita buat tadi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai index
      bottomNavigationBar: Container(
        color: const Color(0xFF000830),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.work_outline, 1),
            _buildNavItem(Icons.assignment_outlined, 2),
            _buildNavItem(Icons.access_time, 3),
            _buildNavItem(Icons.settings, 4), // Ikon Setting
          ],
        ),
      ),
    );
  }

  // Widget pendukung untuk Ikon Navbar agar bisa diklik
  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Icon(
        icon,
        color:
            isActive ? Colors.blueAccent : Colors.white, // Highlight jika aktif
        size: 28,
      ),
    );
  }
}

// 2. HALAMAN PROFIL (SAMA SEPERTI SEBELUMNYA)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userEmail = "lia.admin@gmail.com";
  bool isModalVisible = false;

  @override
  Widget build(BuildContext context) {
    String displayName = userEmail.split('@')[0].split('.')[0];
    displayName = displayName[0].toUpperCase() + displayName.substring(1);
    String initial = displayName[0].toUpperCase();

    return Stack(
      children: [
        Column(
          children: [
            // Header
            Container(
              height: 100,
              width: double.infinity,
              color: const Color(0xFF000830),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 35, bottom: 15),
              child: const Text(
                "Pengaturan",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const SizedBox(height: 40),
            // Profil
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF000830),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 35,
                        color: Color(0xFF000830),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000830),
                    ),
                  ),
                  const Text(
                    "Admin",
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Column(
                children: [
                  _buildMenuItem(Icons.badge_outlined, "Edit Profil"),
                  _buildMenuItem(null, "Ubah Password"),
                  _buildMenuItem(null, "Manajemen Akun"),
                  _buildMenuItem(null, "Tentang Aplikasi"),
                  const SizedBox(height: 15),
                  // Tombol Logout
                  GestureDetector(
                    onTap: () => setState(() => isModalVisible = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "Keluar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // MODAL OVERLAY
        if (isModalVisible)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF000830)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 0.8),
                      ),
                      child: const Center(
                        child: Text("!", style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Apakah Anda Yakin Ingin\nKeluar dari Akun ini?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000830),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => setState(() => isModalVisible = false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF000830)),
                            ),
                            child: const Text(
                              "Tidak",
                              style: TextStyle(color: Color(0xFF000830)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigasi balik ke halaman Login
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF000830),
                            ),
                            child: const Text(
                              "Iya",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(IconData? icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 22, color: const Color(0xFF000830)),
          if (icon == null) const SizedBox(width: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: Colors.black87),
        ],
      ),
    );
  }
}
