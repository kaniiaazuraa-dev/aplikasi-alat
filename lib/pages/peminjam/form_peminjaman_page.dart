import 'package:flutter/material.dart';
import '../../models/alat.models.dart';

class FormPeminjamanPage extends StatefulWidget {
  final AlatModel alat;

  const FormPeminjamanPage({super.key, required this.alat});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;
  final TextEditingController catatanC = TextEditingController();

  Future<void> _pickDate(bool isPinjam) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = date;
        } else {
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
            children: [
              _alatCard(),
              const SizedBox(height: 20),
              _tanggalSection(),
              const SizedBox(height: 20),
              _catatanField(),
              const SizedBox(height: 30),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CARD ALAT (FIGMA STYLE) =================
  Widget _alatCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // GAMBAR ALAT
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/images/alat_default.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 14),

          // INFO ALAT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.alat.namaAlat,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.alat.kategori,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kondisi: ${widget.alat.kondisi}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TANGGAL =================
  Widget _tanggalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal Peminjaman',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          _dateTile(
            label: 'Tanggal Pinjam',
            value: tanggalPinjam,
            onTap: () => _pickDate(true),
          ),
          const SizedBox(height: 12),
          _dateTile(
            label: 'Tanggal Kembali',
            value: tanggalKembali,
            onTap: () => _pickDate(false),
          ),
        ],
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null
                  ? label
                  : '${value.day}-${value.month}-${value.year}',
              style: const TextStyle(fontSize: 13),
            ),
            const Icon(Icons.calendar_month, size: 18),
          ],
        ),
      ),
    );
  }

  // ================= CATATAN =================
  Widget _catatanField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextFormField(
        controller: catatanC,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Catatan (opsional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ================= SUBMIT =================
  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B1C3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Pengajuan dikirim')));
          }
        },
        child: const Text(
          'Ajukan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
