import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonitoringPeminjamanAdminPage extends StatefulWidget {
  const MonitoringPeminjamanAdminPage({super.key});

  @override
  State<MonitoringPeminjamanAdminPage> createState() =>
      _MonitoringPeminjamanAdminPageState();
}

class _MonitoringPeminjamanAdminPageState
    extends State<MonitoringPeminjamanAdminPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List peminjamanList = [];

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  // 🔹 ADMIN ambil SEMUA data peminjaman
  Future<void> fetchPeminjaman() async {
    try {
      final data = await supabase
          .from('peminjaman')
          .select()
          .order('tanggal_pinjam', ascending: false);

      setState(() {
        peminjamanList = data;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil data')));
    }
  }

  // 🔹 ADMIN hanya DELETE
  Future<void> deletePeminjaman(int idPeminjaman) async {
    await supabase
        .from('peminjaman')
        .delete()
        .eq('id_peminjaman', idPeminjaman);

    fetchPeminjaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Peminjaman'),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : peminjamanList.isEmpty
              ? const Center(child: Text('Belum ada data peminjaman'))
              : ListView.builder(
                itemCount: peminjamanList.length,
                itemBuilder: (context, index) {
                  final item = peminjamanList[index];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${item['id_peminjaman']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text('Tanggal Pinjam: ${item['tanggal_pinjam']}'),
                          Text(
                            'Rencana Kembali: ${item['tanggal_kembali_rencana']}',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Status: ${item['status']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deletePeminjaman(item['id_peminjaman']);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
