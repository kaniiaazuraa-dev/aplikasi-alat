import 'package:flutter/material.dart';
import '../../models/alat_pinjam_models.dart'; // pastikan path ini benar sesuai projectmu
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPeminjamanPage extends StatefulWidget {
  final List<AlatPinjam> initialKeranjang;

  const FormPeminjamanPage({super.key, required this.initialKeranjang});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;
  final TextEditingController catatanC = TextEditingController();
  final TextEditingController namaC = TextEditingController();

  late List<AlatPinjam> keranjang;

  @override
  void initState() {
    super.initState();
    keranjang = List.from(widget.initialKeranjang);
  }

  Future<void> _pickDate(bool isPinjam) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = date;
          if (tanggalKembali != null && tanggalKembali!.isBefore(date)) {
            tanggalKembali = null;
          }
        } else {
          if (tanggalPinjam != null && date.isBefore(tanggalPinjam!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanggal kembali harus setelah tanggal pinjam'),
              ),
            );
            return;
          }
          tanggalKembali = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1C3D),
        title: const Text(
          'Form Peminjaman',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField(
                controller: namaC,
                label: 'Nama Peminjam',
                hint: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 16),
              _dateField(
                label: 'Tanggal Peminjaman',
                value: tanggalPinjam,
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 16),
              _dateField(
                label: 'Tanggal Pengembalian',
                value: tanggalKembali,
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 24),
              const Text(
                'Alat yang Dipinjam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (keranjang.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada alat yang dipilih',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...keranjang.map((item) => _alatCard(item)).toList(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _cancelButton()),
                  const SizedBox(width: 16),
                  Expanded(child: _submitButton()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= DATE FIELD =================
  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                      ? 'Masukkan $label'
                      : '${value.day}-${value.month}-${value.year}',
                  style: TextStyle(
                    color: value == null ? Colors.grey.shade500 : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= ALAT CARD DI KERANJANG =================
  Widget _alatCard(AlatPinjam item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar kecil (opsional) - tetap sama
            if (item.alat.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.alat.imageUrl ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                ),
              ),
            if (item.alat.imageUrl != null) const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.alat.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori: ${item.alat.kategori ?? "-"}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Stok tersedia: ${item.alat.stok}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _countButton(
                  icon: Icons.remove_circle_outline,
                  color: Colors.red,
                  onTap:
                      item.jumlah > 1
                          ? () => setState(() => item.jumlah--)
                          : () => setState(() {
                            keranjang.remove(item);
                          }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.jumlah.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _countButton(
                  icon: Icons.add_circle_outline,
                  color: Colors.green,
                  onTap:
                      item.jumlah < (item.alat.stok ?? 0)
                          ? () => setState(() => item.jumlah++)
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: onTap != null ? color : Colors.grey, size: 28),
    );
  }

  // ================= CANCEL BUTTON =================
  Widget _cancelButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // ================= SUBMIT BUTTON =================
  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B1C3D),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed:
          keranjang.isEmpty || tanggalPinjam == null || tanggalKembali == null
              ? null
              : () async {
                if (namaC.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama peminjam wajib diisi')),
                  );
                  return;
                }

                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu'),
                    ),
                  );
                  return;
                }

                try {
                  // Insert header peminjaman – field 'catatan' sudah dihapus
                  final peminjamanRes =
                      await Supabase.instance.client
                          .from('peminjaman')
                          .insert({
                            'id_user': user.id,
                            'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
                            'tanggal_kembali_rencana':
                                tanggalKembali!.toIso8601String(),
                            'status': 'menunggu',
                          })
                          .select('id')
                          .single();

                  final peminjamanId = peminjamanRes['id'];

                  // Insert detail per alat – tetap sama
                  final detailData =
                      keranjang
                          .map(
                            (item) => {
                              'id_peminjaman': peminjamanId,
                              'id_alat': item.alat.idAlat,
                              'jumlah': item.jumlah,
                            },
                          )
                          .toList();

                  await Supabase.instance.client
                      .from('detail_peminjaman')
                      .insert(detailData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Peminjaman berhasil diajukan!'),
                    ),
                  );

                  Navigator.popUntil(context, (route) => route.isFirst);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengajukan: $e')),
                  );
                }
              },
      child: const Text(
        'Ajukan Peminjaman',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
