import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambahalatADMIN.dart';
import 'editalatADMIN.dart';
import 'kelola_kategori_page.dart'; // <- pastikan import ini ditambahkan

class DaftarAlatPage extends StatefulWidget {
  @override
  State<DaftarAlatPage> createState() => _DaftarAlatPageState();
}

class _DaftarAlatPageState extends State<DaftarAlatPage> {
  final supabase = Supabase.instance.client;
  String searchQuery = "";

  Future<void> _deleteAlat(String idAlat) async {
    try {
      await supabase.from('alat').delete().eq('id_alat', idAlat);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil dihapus"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error Delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000D33),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.handyman, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Hi! Admin",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari Barang..........",
                      suffixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip("Semua", true),
                      _buildFilterChip("Hardware", false),
                      _buildFilterChip("Perlengkapan", false),
                      _buildFilterChip(
                        "Kelola Kategori",
                        false,
                      ), // <- perbaikan
                    ],
                  ),
                ),

                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: supabase
                        .from('alat')
                        .stream(primaryKey: ['id_alat']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("Barang tidak ditemukan"),
                        );
                      }

                      final rawData = snapshot.data!;
                      final filteredData =
                          rawData.where((item) {
                            final nama =
                                item['nama_alat'].toString().toLowerCase();
                            return nama.contains(searchQuery);
                          }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          return _buildAlatCard(
                            item['id_alat'].toString(),
                            item['nama_alat'] ?? "",
                            item['status'] ?? "Tersedia",
                            item['stok'] ?? 0,
                            item['image_url'] ?? "",
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_alat',
          backgroundColor: const Color(0xFF000D33),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TambahAlatPage()),
            );
          },
        ),
      ),
    );
  }

  // ======= PERBAIKAN: Tambahkan onSelected untuk Kelola Kategori =======
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF000D33),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
        onSelected: (value) {
          if (label == "Kelola Kategori") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KelolaKategoriPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAlatCard(
    String id,
    String nama,
    String status,
    int stok,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                      )
                      : const Center(
                        child: Icon(
                          Icons.computer,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF000D33),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nama Alat : $nama",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Status : $status",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  "Stok : $stok",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditAlatADMIN(
                                  idAlat: id,
                                  namaAlat: nama,
                                  status: status,
                                  stok: stok,
                                  imageUrl: imageUrl,
                                ),
                          ),
                        );

                        if (result != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Alat berhasil diperbarui"),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _deleteAlat(id),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
