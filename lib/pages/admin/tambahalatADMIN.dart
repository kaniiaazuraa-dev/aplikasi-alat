import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahAlatPage extends StatefulWidget {
  const TambahAlatPage({super.key});

  @override
  State<TambahAlatPage> createState() => _TambahAlatPageState();
}

class _TambahAlatPageState extends State<TambahAlatPage> {
  final _nameController = TextEditingController();
  final _stokController = TextEditingController();
  String? _selectedStatus;

//---vARIABEL UNTUK MENYIMPAN GAMBAR---
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  bool _isLoading = false;

  final Color navyColor = const Color(0xFF000D33);


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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

//SIMPAN DATA KE SUPABASE
  Future<void> _simpanData() async {
    if (_nameController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _selectedStatus == null ||
        (kIsWeb ? _webImage == null : _imageFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua data, status, stok, dan foto!"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

//------------UPLOAD GAMBAR KE SUUPABASE-------
      final String fileExt = _fileName?.split('.').last ?? 'jpg';
      final String path =
          'alat_images/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      const String bucketName = 'alat.bucket';

      if (kIsWeb) {
        await supabase.storage.from(bucketName).uploadBinary(path, _webImage!);
      } else {
        await supabase.storage.from(bucketName).upload(path, _imageFile!);
      }

      final String imageUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(path);

      await supabase.from('alat').insert({
        'nama_alat': _nameController.text,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'status': _selectedStatus,
        'image_url': imageUrl,
        'kategori': 'Hardware',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal simpan: $e")));
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

    final List<String> statusItems= ["Tersedia", "Tidak Tersedia"];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: navyColor,
        title: const Text(
          "Tambah Alat Baru",
          style: TextStyle(color: Colors.white),
        ),
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

          //====UPLOAD GAMBAR----
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: _cardDecoration(),
                        child:
                            (kIsWeb ? _webImage == null : _imageFile == null)
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 40,
                                      color: navyColor,
                                    ),
                                    const Text("Klik untuk upload foto"),
                                  ],
                                )
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

//------DROPDOWN STATUS---------
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
                        onChanged:
                            (value) => setState(() => _selectedStatus = value),
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

///---------TOMBOL BATAL DAN TAMBAH--
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
                            onPressed: _simpanData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navyColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Tambah",
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
