import 'package:flutter/material.dart';
import '../../models/alat_pinjam_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPeminjamanPage extends StatefulWidget {
  final AlatModel? alat;

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
        title: const Text('Form Peminjaman', style: TextStyle(color: Colors.white)),
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
              ...keranjang.map((item) => _alatCard(item)).toList(),
              const SizedBox(height: 30),
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
  Widget _inputField({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null ? 'Masukkan $label' : '${value.day}-${value.month}-${value.year}',
                  style: TextStyle(color: value == null ? Colors.grey.shade500 : Colors.black),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur pilih alat akan ditambahkan di sini')),
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
      ),
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

  // ================= ALAT CARD =================
  Widget _alatCard(AlatPinjam item) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INFO ALAT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
  item.alat.nama,
  style: TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  ),
),
const SizedBox(height: 4),
Text(
  'Status: ${item.alat.status}',
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),
Text(
  'Stok: ${item.alat.stok}',
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),

              ],
            ),
          ),

          // COUNTER JUMLAH
          Row(
            children: [
              _countButton(
                icon: Icons.remove,
                onTap: () {
                  if (item.jumlah > 1) {
                    setState(() {
                      item.jumlah--;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.jumlah.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _countButton(
                icon: Icons.add,
                onTap: () {
                  if (item.jumlah < item.alat.stok) {
                    setState(() {
                      item.jumlah++;
                    });
                  }
                },
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
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16),
    ),
  );
}

  // ================= SUBMIT BUTTON =================
  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B1C3D),
        minimumSize: const Size.fromHeight(48),
      ),
      onPressed: () async {
        if (tanggalPinjam == null || tanggalKembali == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Isi tanggal pinjam dan kembali terlebih dahulu')),
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

          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengajukan peminjaman: $e')),
          );
        }
      },
      child: const Text('Ajukan Peminjaman', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
