import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanPengembalianPage extends StatefulWidget {
  const HalamanPengembalianPage({super.key});

  @override
  State<HalamanPengembalianPage> createState() =>
      _HalamanPengembalianPageState();
}

class _HalamanPengembalianPageState extends State<HalamanPengembalianPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final res = await supabase
        .from('peminjaman')
        .select()
        .eq('status', 'disetujui')
        .order('tanggal_pinjam');

    setState(() {
      data = List<Map<String, dynamic>>.from(res);
      isLoading = false;
    });
  }

  Future<void> konfirmasiPengembalian(String idPeminjaman) async {
    // 1️⃣ insert ke tabel pengembalian
    await supabase.from('pengembalian').insert({
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali': DateTime.now().toIso8601String(),
      'terlambat': false,
      'total_denda': 0,
    });

    // 2️⃣ update status peminjaman
    await supabase
        .from('peminjaman')
        .update({'status': 'dikembalikan'})
        .eq('id_peminjaman', idPeminjaman);

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian'),
        backgroundColor: const Color(0xFF000D33),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : data.isEmpty
              ? const Center(child: Text('Tidak ada pengembalian'))
              : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text('ID: ${item['id_peminjaman']}'),
                      subtitle: Text('Pinjam: ${item['tanggal_pinjam']}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed:
                            () => konfirmasiPengembalian(item['id_peminjaman']),
                        child: const Text('Selesai'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
