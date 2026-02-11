import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aplikasi_alat/models/alat_models.dart';
import 'package:aplikasi_alat/models/alat_pinjam_models.dart';
import '../peminjam/form_peminjaman_page.dart';

final supabase = Supabase.instance.client;

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

  Future<void> fetchAlat() async {
    try {
      final response = await supabase
          .from('alat')
          .select()
          .order('nama_alat');

      listAlat = (response as List)
          .map((e) => Alat.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetch alat: $e');
    }

    setState(() => isLoading = false);
  }

  void _tambahKeKeranjang(Alat alat) {
    final stokTersedia = alat.stok ?? 0;

    if (stokTersedia <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok alat ini habis')),
      );
      return;
    }

    setState(() {
      final index =
          keranjang.indexWhere((e) => e.alat.idAlat == alat.idAlat);

      if (index != -1) {
        if (keranjang[index].jumlah < stokTersedia) {
          keranjang[index].jumlah++;
        }
      } else {
        keranjang.add(AlatPinjam(alat: alat, jumlah: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Peminjaman'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: listAlat.length,
              itemBuilder: (context, index) {
                final alat = listAlat[index];

                final jumlah = keranjang
                        .where((e) => e.alat.idAlat == alat.idAlat)
                        .isNotEmpty
                    ? keranjang
                        .firstWhere(
                            (e) => e.alat.idAlat == alat.idAlat)
                        .jumlah
                    : 0;

                return _buildAlatCard(alat, jumlah);
              },
            ),
      floatingActionButton: keranjang.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: const Icon(Icons.arrow_forward),
              label: Text('${keranjang.length}'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FormPeminjamanPage(initialKeranjang: keranjang),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildAlatCard(Alat alat, int jumlah) {
    final stok = alat.stok ?? 0;
    final gambarUrl =
        alat.imageUrl.isNotEmpty ? alat.imageUrl : 'https://via.placeholder.com/180';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Image.network(
                  gambarUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
                if (jumlah > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$jumlah',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF0D47A1),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategori: ${alat.kategori}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Stok: $stok',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: stok > 0 ? () => _tambahKeKeranjang(alat) : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
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
