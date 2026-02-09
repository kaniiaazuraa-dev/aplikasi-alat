import 'package:flutter/material.dart';
import '../../models/alat.models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model sementara untuk keranjang
class AlatPinjam {
  final AlatModel alat;
  int jumlah;

  AlatPinjam({required this.alat, this.jumlah = 1});
}

// Model sementara untuk keranjang
class AlatPinjam {
  final AlatModel alat;
  int jumlah;

  AlatPinjam({required this.alat, this.jumlah = 1});
}

// Model sementara untuk keranjang
class AlatPinjam {
  final AlatModel alat;
  int jumlah;

  AlatPinjam({required this.alat, this.jumlah = 1});
}

class FormPeminjamanPage extends StatefulWidget {
  final AlatModel? alat; // bisa null karena keranjang multi-alat

class FormPeminjamanPage extends StatefulWidget {
  final AlatModel? alat; // bisa null karena keranjang multi-alat

  const FormPeminjamanPage({super.key, this.alat});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;
  final TextEditingController catatanC = TextEditingController();
  final TextEditingController namaC = TextEditingController();

  // Keranjang multi-alat
  List<AlatPinjam> keranjang = [];

  @override
  void initState() {
    super.initState();
    // jika ada alat default, tambahkan ke keranjang
    if (widget.alat != null) {
      keranjang.add(AlatPinjam(alat: widget.alat!));
    }
  }

  Future<void> _pickDate(bool isPinjam) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      if (!isPinjam && tanggalPinjam != null && date.isBefore(tanggalPinjam!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal kembali harus setelah tanggal pinjam')),
HEAD
          const SnackBar(content: Text('Tanggal kembali harus setelah tanggal pinjam')),
=======
          const SnackBar(
            content: Text('Tanggal kembali harus setelah tanggal pinjam'),
          ),
          7f7b701e3fa98a10442c061ac2409681a6192bb4
        );
        return;
      }
      setState(() {
        if (isPinjam) {
          tanggalPinjam = date;
        } else {
          tanggalKembali = date;
        }
      });
    }
  }

  void tambahKeKeranjang(AlatModel alat) {
    final index = keranjang.indexWhere((e) => e.alat.idAlat == alat.idAlat);
    if (index >= 0) {
      setState(() => keranjang[index].jumlah++);
    } else {
      setState(() => keranjang.add(AlatPinjam(alat: alat)));
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
              _inputField(controller: namaC, label: 'Nama Peminjam', hint: 'Masukkan Nama Peminjam'),
              const SizedBox(height: 16),
              _dateField(label: 'Tanggal Peminjaman', value: tanggalPinjam, onTap: () => _pickDate(true)),
              const SizedBox(height: 16),
              _dateField(label: 'Tanggal Pengembalian', value: tanggalKembali, onTap: () => _pickDate(false)),
              const SizedBox(height: 20),
              const Text('Keranjang Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _addCartButton(),
              const SizedBox(height: 10),
              // Tampilkan semua alat di keranjang
              _inputField(
                controller: namaC,
                label: 'Nama Peminjam',
                hint: 'Masukkan Nama Peminjam',
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
              const SizedBox(height: 20),
              const Text(
                'Keranjang Peminjaman',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _addCartButton(),
              const SizedBox(height: 10),
              ...keranjang.map((item) => _alatCard(item)).toList(),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _cancelButton()),
                  const SizedBox(width: 16),
                  Expanded(child: _submitButton()),
                ],
              )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
  Widget _dateField({required String label, required DateTime? value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
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
                  value == null ? 'Masukkan $label' : '${value.day}-${value.month}-${value.year}',
                  style: TextStyle(color: value == null ? Colors.grey.shade500 : Colors.black),
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

  // ================= ADD CART BUTTON =================
  Widget _addCartButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Ganti dengan navigasi ke halaman pilih alat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur pilih alat akan ditambahkan di sini')),
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur pilih alat akan ditambahkan di sini'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1C3D),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text('+ Tambah Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        child: const Text(
          '+ Tambah Keranjang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ================= CARD ALAT =================
  Widget _alatCard(AlatPinjam item) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.alat.image_url != null && item.alat.image_url!.isNotEmpty
                ? Image.network(item.alat.image_url!, width: 60, height: 60, fit: BoxFit.cover)
                : Image.asset('assets/images/alat_default.png', width: 60, height: 60, fit: BoxFit.cover),
            child:
                item.alat.image_url != null && item.alat.image_url!.isNotEmpty
                    ? Image.network(
                      item.alat.image_url!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      'assets/images/alat_default.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.alat.namaAlat, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Status: Tersedia', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                const Text('Kondisi: Baik', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                const Text('Status: Tersedia', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                const Text('Kondisi: Baik', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  item.alat.namaAlat,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Status: Tersedia',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Kondisi: Baik',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _countButton('-', onTap: () {
                if (item.jumlah > 1) setState(() => item.jumlah--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('${item.jumlah}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _countButton('+', onTap: () => setState(() => item.jumlah++)),
            ],
          )
              _countButton(
                '-',
                onTap: () {
                  if (item.jumlah > 1) setState(() => item.jumlah--);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${item.jumlah}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _countButton('+', onTap: () => setState(() => item.jumlah++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================= CANCEL & SUBMIT =================
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

  Widget _submitButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1C3D),
        borderRadius: BorderRadius.circular(12),
      ),
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B1C3D),
        minimumSize: const Size.fromHeight(48),
      ),
      onPressed: () async {
        // Validasi tanggal
        if (tanggalPinjam == null || tanggalKembali == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Isi tanggal pinjam dan kembali terlebih dahulu'),
            ),
          );
          return;
        }

        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu')),
          );
          return;
        }

        try {
          await Supabase.instance.client.from('peminjaman').insert({
            'id_user': user.id,
            'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
            'tanggal_kembali_rencana': tanggalKembali!.toIso8601String(),
            'status': 'menunggu',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Peminjaman berhasil diajukan!')),
          );

          Navigator.pop(context); // kembali ke halaman sebelumnya
        } catch (e) {
          print('Error insert peminjaman: $e'); // lihat error di console
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengajukan peminjaman: $e')),
          );
        }
      },
      child: const Text(
        'Ajukan Peminjaman',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      alignment: Alignment.center,
      child: const Text('Ajukan Peminjaman', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
