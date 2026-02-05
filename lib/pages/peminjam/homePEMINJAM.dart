import 'package:flutter/material.dart';
import 'ajukan_peminjaman_page.dart';
import '../settings/settings_page.dart'; // ✅ TAMBAHAN

class HomePEMINJAM extends StatefulWidget {
  const HomePEMINJAM({super.key});

  @override
  State<HomePEMINJAM> createState() => _HomePEMINJAMState();
}

class _HomePEMINJAMState extends State<HomePEMINJAM> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    SettingsPage(), // ✅ SETTINGS MASUK DI SINI
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B1C3D),
        title: Row(
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Hi! Peminjam!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0B1C3D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}

// ================= ISI HOME PEMINJAM =================
class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _pengajuanPeminjamanCard(),
          const SizedBox(height: 24),
          _ajukanPeminjamanButton(context),
        ],
      ),
    );
  }

  Widget _pengajuanPeminjamanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E88E5), width: 2),
      ),
      child: const Text('Pengajuan Peminjaman'),
    );
  }

  Widget _ajukanPeminjamanButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AjukanPeminjamanPage()),
        );
      },
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF0B1C3D), width: 2),
        ),
        child: const Text(
          'Ajukan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
