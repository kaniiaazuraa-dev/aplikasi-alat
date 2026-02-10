import 'package:aplikasi_alat/models/alat_models.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/alat_models.dart';

final supabase = Supabase.instance.client;

// MODEL KERANJANG
class AlatPinjam {
  final Alat alat;
  int jumlah;

  AlatPinjam({
    required this.alat,
    this.jumlah = 1,
  });
}

class AjukanPeminjamanPage extends StatefulWidget {
  const AjukanPeminjamanPage({super.key});

  @override
  State<AjukanPeminjamanPage> createState() => _AjukanPeminjamanPageState();
}

class _AjukanPeminjamanPageState extends State<AjukanPeminjamanPage> {
  List<Alat> listAlat = [];
  List<AlatPinjam> keranjang = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlat();
  }

  // ================= FETCH ALAT =================
  Future<void> fetchAlat() async {
    try {
      final response = await supabase
          .from('alat')
          .select()
          .order('nama_alat');

      setState(() {
        listAlat = (response as List)
            .map((e) => Alat.fromMap(e as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch alat: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Peminjaman')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listAlat.length,
              itemBuilder: (context, index) {
                final alat = listAlat[index];

                final item = keranjang.firstWhere(
                  (e) => e.alat.idAlat == alat.idAlat,
                  orElse: () => AlatPinjam(alat: alat, jumlah: 0),
                );

                return _alatCard(alat, item);
              },
            ),
    );
  }

  // ================= CARD ALAT =================
  Widget _alatCard(Alat alat, AlatPinjam item) {
    final isSelected = item.jumlah > 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alat.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${alat.status}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Stok: ${alat.stok}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // COUNTER
            Row(
              children: [
                _countButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (item.jumlah > 0) {
                      setState(() {
                        item.jumlah--;
                        if (item.jumlah == 0) {
                          keranjang.removeWhere(
                              (e) => e.alat.idAlat == alat.idAlat);
                        }
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.jumlah.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _countButton(
                  icon: Icons.add,
                  onTap: () {
                    if (item.jumlah < alat.stok) {
                      setState(() {
                        if (!isSelected) {
                          keranjang.add(AlatPinjam(alat: alat, jumlah: 1));
                        } else {
                          item.jumlah++;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _countButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
