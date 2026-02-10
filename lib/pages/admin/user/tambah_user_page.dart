import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahUserPage extends StatefulWidget {
  const TambahUserPage({super.key});

  @override
  State<TambahUserPage> createState() => _TambahUserPageState();
}

class _TambahUserPageState extends State<TambahUserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  final Color navyColor = const Color(0xFF020B4F);

  final List<String> roleItems = ["admin", "petugas", "peminjam"];

  // ================= SIMPAN DATA =================
  Future<void> _simpanData() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty || _selectedRole == null) {
      _showSnackBar("Harap isi semua data!");
      return;
    }

    // Validasi email sangat sederhana (bisa diganti regex kalau mau lebih ketat)
    if (!email.contains('@') || !email.contains('.') || email.length < 6) {
      _showSnackBar("Format email sepertinya tidak valid");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Cek duplikat email – pakai trim juga di query
      final existing =
          await supabase
              .from('users')
              .select('email')
              .eq('email', email) // sudah trim di atas
              .maybeSingle(); // ← ini yang benar!

      if (existing != null) {
        _showSnackBar("Email sudah terdaftar!");
        return;
      }

      await supabase.from('users').insert({
        'nama_lengkap': name,
        'email': email,
        'role': _selectedRole,
      });

      if (mounted) {
        _showSnackBar("User berhasil ditambahkan!");
        FocusScope.of(context).unfocus(); // keyboard hilang
        Navigator.pop(context, true);
      }
    } catch (e) {
      String message = "Gagal menambahkan user";

      if (e is PostgrestException) {
        switch (e.code) {
          case '23505': // unique_violation
            message = "Email sudah terdaftar";
            break;
          case '42501':
            message = "Tidak memiliki izin untuk menambah user";
            break;
          default:
            message = "Kesalahan server: ${e.message}";
        }
      } else if (e.toString().toLowerCase().contains("timeout")) {
        message = "Koneksi lambat, coba lagi nanti";
      }

      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper supaya kode lebih bersih & aman
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar(); // hindari numpuk snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: navyColor,
        title: const Text(
          "Tambah User Baru",
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
                    const Text("Nama Lengkap", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: _nameController,
                        decoration: _inputStyle("Masukkan Nama Lengkap"),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Email", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: TextField(
                        controller: _emailController,
                        decoration: _inputStyle("Masukkan Email"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Role", style: labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: _cardDecoration(),
                      child: DropdownButtonFormField<String>(
                        decoration: _inputStyle("Pilih Role"),
                        value:
                            roleItems.contains(_selectedRole)
                                ? _selectedRole
                                : null,
                        items:
                            roleItems
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => _selectedRole = value),
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
