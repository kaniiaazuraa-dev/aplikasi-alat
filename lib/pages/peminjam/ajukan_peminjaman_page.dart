import 'package:aplikasi_alat/models/alat_models.dart';
import 'package:aplikasi_alat/models/alat_pinjam_models.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman form - sesuaikan path ini kalau masih error
import '../peminjam/form_peminjaman_page.dart'; // ← ini path yang kamu pakai terakhir

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
      final response = await supabase.from('alat').select().order('nama_alat');
      setState(() {
        listAlat =
            (response as List)
                .map((e) => Alat.fromMap(e as Map<String, dynamic>))
                .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch alat: $e');
      setState(() => isLoading = false);
    }
  }

  void _tambahKeKeranjang(Alat alat) {
    setState(() {
      final existingIndex = keranjang.indexWhere(
        (e) => e.alat.idAlat == alat.idAlat,
      );

      if (existingIndex != -1) {
        // Sudah ada di keranjang → tambah jumlah kalau stok masih cukup
        final stokTersedia = alat.stok ?? 0;
        if (keranjang[existingIndex].jumlah < stokTersedia) {
          keranjang[existingIndex].jumlah++;
        }
      } else {
        // Belum ada → tambah item baru kalau stok > 0
        final stokTersedia = alat.stok ?? 0;
        if (stokTersedia > 0) {
          keranjang.add(AlatPinjam(alat: alat, jumlah: 1));
        } else {
          // Optional: beri tahu user kalau stok habis
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Stok alat ini habis')));
        }
      }
    });

    debugPrint('Keranjang sekarang: ${keranjang.length} item');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Peminjaman'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: listAlat.length,
                itemBuilder: (context, index) {
                  final alat = listAlat[index];

                  // Ini cara paling aman dan bersih
                  final jumlah =
                      keranjang.any((e) => e.alat.idAlat == alat.idAlat)
                          ? keranjang
                              .firstWhere((e) => e.alat.idAlat == alat.idAlat)
                              .jumlah
                          : 0;

                  final stok = alat.stok ?? 0;

                  return _buildAlatCard(alat, jumlah, stok);
                },
              ),
      floatingActionButton:
          keranjang.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  debugPrint('FAB diklik, keranjang: ${keranjang.length}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              FormPeminjamanPage(initialKeranjang: keranjang),
                    ),
                  );
                },
                label: Text('${keranjang.length}'),
                icon: const Icon(Icons.arrow_forward),
                backgroundColor: Colors.green,
              )
              : null,
    );
  }

  Widget _buildAlatCard(Alat alat, int jumlah, int stok) {
    final gambarUrl = alat.imageUrl ?? 'https://via.placeholder.com/180';

    return GestureDetector(
      onTap: () {
        debugPrint(
          'Card ${alat.nama ?? "Tidak ada nama"} diklik | jumlah: $jumlah',
        );

        if (jumlah > 0) {
          debugPrint('→ Langsung ke form peminjaman');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FormPeminjamanPage(initialKeranjang: keranjang),
            ),
          );
        } else if (stok > 0) {
          debugPrint('→ Tambah ke keranjang');
          _tambahKeKeranjang(alat);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Stok habis')));
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                        ),
                  ),
                  if (jumlah > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$jumlah',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                    alat.nama ?? 'Nama Alat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori: ${alat.kategori ?? '-'}',
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
                        child: Icon(
                          Icons.add,
                          color: const Color(0xFF0D47A1),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
