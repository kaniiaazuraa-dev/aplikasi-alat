import 'package:flutter/material.dart';
import 'halaman_persetujuan_page.dart';
import 'halaman_pengembalian_page.dart';
import '../settings/settings_page.dart';

class HomePetugasPage extends StatefulWidget {
  const HomePetugasPage({super.key});

  @override
  State<HomePetugasPage> createState() => _HomePetugasPageState();
}

class _HomePetugasPageState extends State<HomePetugasPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pengajuanTerbaru = [
      {'nama': 'Kania', 'alat': 'Komputer', 'status': 'menunggu'},
      {'nama': 'Zura', 'alat': 'Keyboard', 'status': 'menunggu'},
      {'nama': 'Sari', 'alat': 'Kabel LAN', 'status': 'menunggu'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ================= BODY =================
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ===== DASHBOARD (ISI ASLI KAMU) =====
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF000D33),
              title: const Text('Dashboard Petugas'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== SUMMARY =====
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.6,
                        ),
                    children: const [
                      _SummaryCard(title: 'Menunggu', value: '3'),
                      _SummaryCard(title: 'Dipinjam', value: '5'),
                      _SummaryCard(title: 'Kembali Hari Ini', value: '2'),
                      _SummaryCard(
                        title: 'Terlambat',
                        value: '1',
                        isAlert: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== QUICK ACTION =====
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.assignment,
                        label: 'Persetujuan',
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.assignment_return,
                        label: 'Pengembalian',
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== RECENT =====
                  const Text(
                    'Pengajuan Terbaru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  ...pengajuanTerbaru.map(
                    (item) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(item['nama']!),
                        subtitle: Text(item['alat']!),
                        trailing: Chip(
                          label: Text(item['status']!),
                          backgroundColor: Colors.orange.shade200,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== MENU NAVBAR =====
          const HalamanPersetujuanPage(),
          const HalamanPengembalianPage(),
          SettingsPage(),
        ],
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF000D33),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Persetujuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}

// ================= COMPONENT ASLI =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isAlert;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF000D33)),
        color: isAlert ? Colors.red.shade50 : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF000D33),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
