import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKategoriPage extends StatefulWidget {
  final Map<String, dynamic> kategori;
  const EditKategoriPage({super.key, required this.kategori});

  @override
  State<EditKategoriPage> createState() => _EditKategoriPageState();
}

class _EditKategoriPageState extends State<EditKategoriPage> {
  final supabase = Supabase.instance.client;
  late TextEditingController namaController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(
      text: widget.kategori['nama_kategori'],
    );
  }

  Future<void> _updateKategori() async {
    if (namaController.text.isEmpty) return;

    await supabase
        .from('kategori')
        .update({'nama_kategori': namaController.text})
        .eq('id_kategori', widget.kategori['id_kategori']);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Kategori berhasil diperbarui"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000D33),
        title: const Text("Edit Kategori"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Kategori",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000D33),
                  ),
                  onPressed: _updateKategori,
                  child: const Text("Simpan"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
