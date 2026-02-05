import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditAlatADMIN extends StatefulWidget {
  final String idAlat;
  final String namaAlat;
  final String status;
  final String kondisi;
  final String imageUrl;

  const EditAlatADMIN({
    super.key,
    required this.idAlat,
    required this.namaAlat,
    required this.status,
    required this.kondisi,
    required this.imageUrl,
  });

  @override
  State<EditAlatADMIN> createState() => _EditAlatADMINState();
}

class _EditAlatADMINState extends State<EditAlatADMIN> {
  final supabase = Supabase.instance.client;

  late TextEditingController namaController;
  String selectedStatus = "Tersedia";
  String selectedKondisi = "Baik";

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.namaAlat);
    selectedStatus = widget.status;
    selectedKondisi = widget.kondisi;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _updateAlat() async {
    String finalImageUrl = widget.imageUrl;

    if (selectedImage != null) {
      final fileName =
          '${widget.idAlat}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('alat').upload(fileName, selectedImage!);

      finalImageUrl = supabase.storage.from('alat').getPublicUrl(fileName);
    }

    await supabase
        .from('alat')
        .update({
          'nama_alat': namaController.text,
          'status': selectedStatus,
          'kondisi': selectedKondisi,
          'image_url': finalImageUrl,
        })
        .eq('id_alat', widget.idAlat);

    if (!mounted) return;

    /// ⬇️ KIRIM DATA BALIK KE DAFTAR ALAT
    Navigator.pop(context, {
      'id_alat': widget.idAlat,
      'nama_alat': namaController.text,
      'status': selectedStatus,
      'kondisi': selectedKondisi,
      'image_url': finalImageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000D33),
        title: const Text("Edit Alat"),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== GAMBAR =====
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GestureDetector(
                  onTap: _pickImage,
                  child:
                      selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : widget.imageUrl.isNotEmpty
                          ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                          : const Center(
                            child: Icon(
                              Icons.computer,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== NAMA ALAT =====
            const Text("Nama Alat"),
            const SizedBox(height: 6),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== STATUS =====
            const Text("Status"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: "Tersedia", child: Text("Tersedia")),
                DropdownMenuItem(
                  value: "Tidak Tersedia",
                  child: Text("Tidak Tersedia"),
                ),
              ],
              onChanged: (v) => setState(() => selectedStatus = v!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== KONDISI =====
            const Text("Kondisi"),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedKondisi,
              items: const [
                DropdownMenuItem(value: "Baik", child: Text("Baik")),
                DropdownMenuItem(value: "Buruk", child: Text("Buruk")),
              ],
              onChanged: (v) => setState(() => selectedKondisi = v!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== BUTTON =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000D33),
                    ),
                    onPressed: _updateAlat,
                    child: const Text("Simpan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
