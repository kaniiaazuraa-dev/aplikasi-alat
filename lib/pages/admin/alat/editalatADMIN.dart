import 'package:flutter/material.dart';
import '../controllers/alat_controller.dart';
import 'dart:io';
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
  final AlatController alatController = AlatController();

  late TextEditingController namaController;
  late TextEditingController stokController;
  late String selectedStatus;
  File? selectedImage;


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
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );

  if (picked != null) {
    setState(() {
      selectedImage = File(picked.path);
    });
  }
}


  Future<void> _updateAlat() async {
    if (namaController.text.isEmpty || stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Stok tidak boleh kosong")),
      );
      return;
    }

    final success = await alatController.editAlat(
      idAlat: widget.idAlat,
      nama: namaController.text,
      status: selectedStatus,
      stok: int.tryParse(stokController.text) ?? 0,
      imageUrl: widget.imageUrl,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan perubahan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alat'),
        backgroundColor: const Color(0xFF0A1A44),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= FOTO =================
                GestureDetector(
  onTap: _pickImage,
  child: Container(
    height: 180,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      image: selectedImage != null
          ? DecorationImage(
              image: FileImage(selectedImage!),
              fit: BoxFit.cover,
            )
          : widget.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
    ),
    child: selectedImage == null && widget.imageUrl.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.cloud_upload_outlined, size: 48),
              SizedBox(height: 8),
              Text('Klik untuk upload foto'),
            ],
          )
        : null,
  ),
),
                const SizedBox(height: 20),

                /// ================= NAMA ALAT =================
                const Text(
                  'Nama Alat',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: namaController,
                  decoration: _inputDecoration('Masukkan Nama Alat'),
                ),

                const SizedBox(height: 14),

                /// ================= STATUS =================
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: _inputDecoration('Pilih Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Tersedia', child: Text('Tersedia')),
                    DropdownMenuItem(
                        value: 'Tidak Tersedia',
                        child: Text('Tidak Tersedia')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedStatus = val);
                    }
                  },
                ),

                const SizedBox(height: 14),

                /// ================= STOK =================
                const Text(
                  'Stok',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Masukkan jumlah stok'),
                ),

                const SizedBox(height: 24),

                /// ================= BUTTON =================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateAlat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1A44),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ),
    );
  }
  
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

