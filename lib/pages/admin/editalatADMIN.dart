import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditAlatADMIN extends StatefulWidget {
  final String idAlat;
  final String namaAlat;
  final String status;
  final int stok;
  final String imageUrl;

  const EditAlatADMIN({
    super.key,
    required this.idAlat,
    required this.namaAlat,
    required this.status,
    required this.stok,
    required this.imageUrl,
  });

  @override
  State<EditAlatADMIN> createState() => _EditAlatADMINState();
}

class _EditAlatADMINState extends State<EditAlatADMIN> {
  final supabase = Supabase.instance.client;

  late TextEditingController namaController;
  late TextEditingController stokController;

  String selectedStatus = "Tersedia";
  File? selectedImage; // untuk Mobile
  Uint8List? webImage; // untuk Web

  final String bucketName = 'alat.bucket'; // ✅ sesuaikan dengan bucket Supabase

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.namaAlat);
    stokController = TextEditingController(text: widget.stok.toString());
    selectedStatus = widget.status;
  }

  @override
  void dispose() {
    namaController.dispose();
    stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    }
  }

  Future<void> _updateAlat() async {
    if (namaController.text.isEmpty || stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Stok tidak boleh kosong!")),
      );
      return;
    }

    String finalImageUrl = widget.imageUrl;

    // Upload image jika ada
    if (selectedImage != null || webImage != null) {
      final fileName =
          '${widget.idAlat}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kIsWeb && webImage != null) {
        await supabase.storage
            .from(bucketName)
            .uploadBinary(fileName, webImage!);
      } else if (selectedImage != null) {
        await supabase.storage
            .from(bucketName)
            .upload(fileName, selectedImage!);
      }
      finalImageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
    }

    // Update data di Supabase
    await supabase
        .from('alat')
        .update({
          'nama_alat': namaController.text,
          'status': selectedStatus,
          'stok': int.tryParse(stokController.text) ?? 0,
          'image_url': finalImageUrl,
        })
        .eq('id_alat', widget.idAlat);

    if (!mounted) return;

    Navigator.pop(context, {
      'id_alat': widget.idAlat,
      'nama_alat': namaController.text,
      'status': selectedStatus,
      'stok': int.tryParse(stokController.text) ?? 0,
      'image_url': finalImageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = 14.0;
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
            // IMAGE PICKER
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child:
                      kIsWeb
                          ? (webImage != null
                              ? Image.memory(webImage!, fit: BoxFit.cover)
                              : widget.imageUrl.isNotEmpty
                              ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                              )
                              : const Center(
                                child: Icon(
                                  Icons.computer,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ))
                          : (selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : widget.imageUrl.isNotEmpty
                              ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                              )
                              : const Center(
                                child: Icon(
                                  Icons.computer,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              )),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("Nama Alat"),
            const SizedBox(height: 6),
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),

            const SizedBox(height: 16),
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
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Stok"),
            const SizedBox(height: 6),
            TextField(
              controller: stokController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 30),
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
