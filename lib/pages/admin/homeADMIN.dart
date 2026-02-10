import 'package:aplikasi_alat/pages/admin/peminjaman/Monitoring_peminjaman_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat/daftar.alatADMIN.dart';
import '../settings/settings_page.dart';
import 'peminjaman/Monitoring_peminjaman_page.dart';

class HomeADMIN extends StatefulWidget {
  const HomeADMIN({super.key});

  @override
  State<HomeADMIN> createState() => _HomeADMINState();
}

class _HomeADMINState extends State<HomeADMIN> {
  int _selectedIndex = 0;

  final supabase = Supabase.instance.client;

  int totalAlat = 0;
  int totalUser = 0;
  int totalPinjam = 0;

  List<Map<String, dynamic>> peminjamanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Berhasil!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      final alat = await supabase.from('alat').select();
      final users = await supabase.from('users').select();
      final pinjam = await supabase.from('peminjaman').select();

      final peminjaman = await supabase
          .from('peminjaman')
          .select('tanggal_pinjam, users(nama), alat(nama_alat)')
          .order('tanggal_pinjam', ascending: false);

      setState(() {
        totalAlat = alat.length;
        totalUser = users.length;
        totalPinjam = pinjam.length;
        peminjamanList = List<Map<String, dynamic>>.from(peminjaman);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildDashboardContent(),
      const DaftarAlatPage(), // ← punya AppBar sendiri (navy gelap)
      const MonitoringPeminjamanAdminPage(), // ← punya AppBar sendiri jika ada
      const Center(child: Text("Halaman Riwayat")),
      SettingsPage(), // ← punya AppBar sendiri jika ada
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // TIDAK ADA appBar di sini → biar tiap halaman kontrol sendiri
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF000D33),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }

  // ================= DASHBOARD CONTENT (dengan AppBar khusus) =================
  Widget _buildDashboardContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // ← Scaffold tambahan hanya untuk dashboard
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF001F3F,
        ), // biru lebih cerah seperti di screenshot iPhone kamu
        // Alternatif warna kalau mau lebih gelap: Color(0xFF003087) atau Colors.blue[800]
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman, // × symbol (paling mirip ikon X di screenshot)
              size: 32,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Hi! Admin',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard(
                    'Total Alat',
                    totalAlat.toString(),
                    Icons.inventory,
                  ),
                  _infoCard('Total User', totalUser.toString(), Icons.people),
                  _infoCard(
                    'Total Pinjam',
                    totalPinjam.toString(),
                    Icons.assignment,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Alat Rusak/Hilang'),
                      ],
                    ),
                    Text('3 Alat'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Daftar Peminjam',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF000D33)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Nama Peminjam')),
                        DataColumn(label: Text('Alat')),
                        DataColumn(label: Text('Tanggal Pinjam')),
                      ],
                      rows:
                          peminjamanList.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['users']?['nama'] ?? '-')),
                                DataCell(
                                  Text(item['alat']?['nama_alat'] ?? '-'),
                                ),
                                DataCell(
                                  Text(
                                    item['tanggal_pinjam']?.toString() ?? '-',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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

  static Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF000D33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF000D33)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
