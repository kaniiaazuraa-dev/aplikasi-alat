import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alat.models.dart';
import 'form_peminjaman_page.dart'; // ⬅️ TAMBAHKAN INI

class AjukanPeminjamanPage extends StatefulWidget {
  const AjukanPeminjamanPage({super.key});

  @override
  State<AjukanPeminjamanPage> createState() => _AjukanPeminjamanPageState();
}

class _AjukanPeminjamanPageState extends State<AjukanPeminjamanPage> {
  final supabase = Supabase.instance.client;

  List<AlatModel> listAlat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlat();
  }

  Future<void> fetchAlat() async {
    try {
      final response = await supabase
          .from('alat')
          .select()
          .eq('status', 'Tersedia'); // ⬅️ alat yang bisa dipinjam

      setState(() {
        listAlat =
            (response as List).map((e) => AlatModel.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat alat')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000D33),
        title: const Text('Pilih Alat', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: listAlat.length,
                itemBuilder: (context, index) {
                  final alat = listAlat[index];
                  return _buildAlatCard(alat);
                },
              ),
    );
  }

  Widget _buildAlatCard(AlatModel alat) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/alat_default.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF000D33),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.namaAlat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kategori: ${alat.kategori}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Kondisi: ${alat.kondisi}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),

                    // ================== INI YANG DIPERBAIKI ==================
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormPeminjamanPage(alat: alat),
                        ),
                      );
                    },
                    // ==========================================================
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
