import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HalamanPersetujuanPage extends StatefulWidget {
  const HalamanPersetujuanPage({super.key});

  @override
  State<HalamanPersetujuanPage> createState() => _HalamanPersetujuanPageState();
}

class _HalamanPersetujuanPageState extends State<HalamanPersetujuanPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> peminjamanList = [];

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  // 🔹 ambil semua data peminjaman
  Future<void> fetchPeminjaman() async {
    try {
      final res = await supabase
          .from('peminjaman')
          .select('''
      id_peminjaman,
      tanggal_pinjam,
      tanggal_kembali_rencana,
      status,
      users!inner(nama_lengkap)
    ''')
          .eq('status', 'menunggu') // 🔹 filter menunggu
          .order('tanggal_pinjam', ascending: false);
      setState(() {
        peminjamanList = List<Map<String, dynamic>>.from(res);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil data')));
    }
  }

  // 🔹 update status peminjaman
  Future<void> updateStatus(int index, String statusBaru) async {
     final id = peminjamanList[index]['id_peminjaman'];
      setState(() {
    peminjamanList[index]['status'] = statusBaru;
  });
    await supabase
        .from('peminjaman')
        .update({'status': statusBaru})
        .eq('id_peminjaman', statusBaru);

    fetchPeminjaman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Persetujuan'),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : peminjamanList.isEmpty
              ? const Center(child: Text('Tidak ada data peminjaman'))
              : ListView.builder(
                itemCount: peminjamanList.length,
                itemBuilder: (context, index) {
                  final item = peminjamanList[index];
                  final status = item['status'].toString().trim().toLowerCase();
                  final notReturned = item['pengembalian'] == null;

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Peminjam: ${item['users']['nama_lengkap']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text('Tanggal Pinjam: ${item['tanggal_pinjam']}'),
                          const SizedBox(height: 6),
                          Text(
                            'Rencana Kembali: ${item['tanggal_kembali_rencana']}',
                          ),
                          const SizedBox(height: 12),

                         if (status == 'menunggu') ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => updateStatus(index, 'ditolak'),
                                  child: const Text('Tolak'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () => updateStatus(index, 'disetujui'),
                                  child: const Text('Setujui'),
                                ),
                              ],
                            ),
                          ] else ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Chip(
                                label: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    status == 'disetujui' ? Colors.green : Colors.red,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
