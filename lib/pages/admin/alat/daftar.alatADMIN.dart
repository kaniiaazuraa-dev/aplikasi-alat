import 'package:flutter/material.dart';
import '../controllers/alat_controller.dart';
import '../alat/editalatADMIN.dart';
import '../../admin/alat/tambahalatADMIN.dart';
import '../kategori/kelola_kategori_page.dart';

class DaftarAlatPage extends StatefulWidget {
  @override
  _DaftarAlatPageState createState() => _DaftarAlatPageState();
}

class _DaftarAlatPageState extends State<DaftarAlatPage> {
  final AlatController alatController = AlatController();
  final List<String> daftarKategori = [
    'Semua',
    'Hardware',
    'Perlengkapan',
    'Kelola Kategori'
  ];

  String kategoriTerpilih = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    alatController.getAlat();
    alatController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    alatController.removeListener(_refresh);
    alatController.dispose();
    super.dispose();
  }

  // Filter alat berdasarkan kategori & search
  List filteredAlat() {
    return alatController.daftarAlat.where((a) {
      final matchesKategori =
          kategoriTerpilih == 'Semua' || a.kategori == kategoriTerpilih;
      final matchesSearch =
          a.nama.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesKategori && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Alat')),
      body: alatController.loading
          ? Center(child: CircularProgressIndicator())
          : alatController.daftarAlat.isEmpty
              ? Center(child: Text('Belum ada alat'))
              : Column(
                  children: [
                    // Kategori card horizontal
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daftarKategori.length,
                        itemBuilder: (context, index) {
                          final kategori = daftarKategori[index];
                          final isSelected = kategori == kategoriTerpilih;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: ChoiceChip(
                              label: Text(kategori),
                              selected: isSelected,
                              onSelected: (_) async {
                                if (kategori == 'Kelola Kategori') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => KelolaKategoriPage()),
                                  );
                                  await alatController.getAlat();
                                } else {
                                  setState(() {
                                    kategoriTerpilih = kategori;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Card pencarian alat
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari alat...',
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // Daftar alat
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.builder(
                          itemCount: filteredAlat().length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 4,
                          ),
                          itemBuilder: (context, index) {
                            final alat = filteredAlat()[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: alat.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(10)),
                                            child: Image.network(
                                              alat.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(10)),
                                            ),
                                            child: Icon(Icons.image,
                                                size: 50,
                                                color: Colors.grey[700]),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alat.nama,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4),
                                        Text('Stok: ${alat.stok}'),
                                        Text('Status: ${alat.status}'),
                                        Text('Kategori: ${alat.kategori}'),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, size: 20),
                                              onPressed: () async {
                                                final updated =
                                                    await Navigator.push(
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
                                                  await alatController.getAlat();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, size: 20),
                                              onPressed: () async {
                                                final confirm =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: Text('Hapus Alat?'),
                                                    content: Text(
                                                        'Apakah yakin ingin menghapus ${alat.nama}?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child:
                                                              Text('Batal')),
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child:
                                                              Text('Hapus')),
                                                    ],
                                                  ),
                                                );
                                                if (confirm ?? false) {
                                                  final success =
                                                      await alatController
                                                          .deleteAlat(
                                                              alat.idAlat);
                                                  if (!success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Gagal menghapus alat')));
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TambahAlatPage())); // route langsung
          if (added == true) {
            await alatController.getAlat();
          }
        },
      ),
    );
  }
}
