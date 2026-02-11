import 'package:flutter/material.dart';
import '../../../models/alat_models.dart';
import '../controllers/alat_controller.dart';
import '../alat/editalatADMIN.dart';
import '../../admin/alat/tambahalatADMIN.dart';
import '../kategori/kelola_kategori_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DaftarAlatPage extends StatefulWidget {
  const DaftarAlatPage({super.key});

  @override
  State<DaftarAlatPage> createState() => _DaftarAlatPageState();
}

class _DaftarAlatPageState extends State<DaftarAlatPage> {
  final _searchController = TextEditingController();
  final AlatController alatController = AlatController();
  final supabase = Supabase.instance.client;

  void _listenRealtime() {
  supabase
      .channel('public:alat')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'alat',
        callback: (payload) async {
          await alatController.getAlat();
          setState(() {});
        },
      )
      .subscribe();
}

  String _kategoriTerpilih = 'Semua';
  String _searchQuery = '';

  final Color navy = const Color(0xFF000D33);

  final List<String> _kategoriList = [
    'Semua',
    'Hardware',
    'Perlengkapan',
    'Kelola Kategori',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ AMBIL DATA ALAT SAAT HALAMAN DIBUKA
  alatController.getAlat().then((_) {
    setState(() {}); // refresh UI
  });

  _listenRealtime();

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
     supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Alat> filteredAlat = alatController.daftarAlat.isEmpty
    ? []
    :alatController.daftarAlat.where((a) {
      final matchKategori =
          _kategoriTerpilih == 'Semua' || a.kategori == _kategoriTerpilih;
      final matchSearch =
          a.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchKategori && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Daftar Alat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriList[index];
                final selected = kategori == _kategoriTerpilih;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      kategori,
                      style: TextStyle(
                        color: selected ? Colors.white : navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selected,
                    selectedColor: navy,
                    backgroundColor: Colors.grey[200],
                    onSelected: (sel) async {
                      if (kategori == 'Kelola Kategori') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KelolaKategoriPage(),
                          ),
                        );
                        await alatController.getAlat();
                      } else if (sel) {
                        setState(() => _kategoriTerpilih = kategori);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Barang.........',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: alatController.loading
                ? const Center(child: CircularProgressIndicator())
                : filteredAlat.isEmpty
                    ? const Center(child: Text('Tidak ditemukan alat'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: filteredAlat.length,
                        itemBuilder: (context, index) {
                          return _AlatCard(
                            alat: filteredAlat[index],
                            controller: alatController,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: navy,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAlatPage()),
          );
          if (added == true) {
            await alatController.getAlat();
          }
        },
      ),
    );
  }
}

class _AlatCard extends StatelessWidget {
  final Alat alat;
  final AlatController controller;

  const _AlatCard({
    required this.alat,
    required this.controller,
  });

  final Color navy = const Color(0xFF000D33);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    alat.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Alat : ${alat.nama}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Status : ${alat.status}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Stok : ${alat.stok}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ TOMBOL EDIT & DELETE (POSISI TETAP)
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditAlatADMIN(
                          idAlat: alat.idAlat,
                          namaAlat: alat.nama,
                          status: alat.status,
                          stok: alat.stok,
                          imageUrl: alat.imageUrl,
                        ),
                      ),
                    );
                    if (updated == true) {
                      await controller.getAlat();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.white, size: 18),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HARUS DI DALAM CLASS
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Alat?'),
        content: Text('Yakin ingin menghapus "${alat.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteAlat(alat.idAlat);
    }
  }
}
