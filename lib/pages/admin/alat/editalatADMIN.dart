import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/alat_controller.dart';

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

  late TextEditingController _nameController;
  late TextEditingController _stokController;
  String? _selectedStatus;

  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  bool _isLoading = false;

  final Color navyColor = const Color(0xFF000D33);
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.namaAlat);
    _stokController = TextEditingController(text: widget.stok.toString());
    _selectedStatus = widget.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _fileName = pickedFile.name;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _fileName = pickedFile.name;
        });
      }
    }
  }

  Future<void> _updateAlat() async {
    if (_nameController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data dan status")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newImageUrl = widget.imageUrl;

      // ===== UPLOAD GAMBAR JIKA ADA =====
      if (kIsWeb ? _webImage != null : _imageFile != null) {
        final fileExt = _fileName?.split('.').last ?? 'jpg';
        final path =
            'alat_images/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        const bucketName = 'alat.bucket';

        if (kIsWeb) {
          await supabase.storage
              .from(bucketName)
              .uploadBinary(path, _webImage!);
        } else {
          await supabase.storage.from(bucketName).upload(path, _imageFile!);
        }

        newImageUrl = supabase.storage.from(bucketName).getPublicUrl(path);
      }

      // ===== UPDATE DATA (TANPA BOOLEAN) =====
      await alatController.editAlat(
        idAlat: widget.idAlat,
        nama: _nameController.text.trim(),
        status: _selectedStatus!,
        stok: int.parse(_stokController.text),
        imageUrl: newImageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perubahan berhasil disimpan!")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFF000D33),
      fontWeight: FontWeight.bold,
    );

    final statusItems = ["Tersedia", "Tidak Tersedia"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: navyColor,
        title: const Text("Edit Alat", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: _cardDecoration(),
                        child:
                            (_imageFile == null && _webImage == null)
                                ? (widget.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => const Icon(
                                              Icons.broken_image,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                      ),
                                    )
                                    : const Center(
                                      child: Text(
                                        "Klik untuk upload foto baru",
                                      ),
                                    ))
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      kIsWeb
                                          ? Image.memory(
                                            _webImage!,
                                            fit: BoxFit.cover,
                                          )
                                          : Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("Nama Alat", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: _nameController,
                        decoration: _inputStyle("Masukkan Nama Alat"),
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text("Status", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: DropdownButtonFormField<String>(
                        decoration: _inputStyle("Pilih Status"),
                        value:
                            statusItems.contains(_selectedStatus)
                                ? _selectedStatus
                                : null,
                        items:
                            statusItems
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v),
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text("Stok", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: _stokController,
                        decoration: _inputStyle("Masukkan jumlah stok"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: BorderSide(color: navyColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Batal",
                              style: TextStyle(color: navyColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateAlat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navyColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Simpan Perubahan",
                              style: TextStyle(color: Colors.white),
                            ),
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
