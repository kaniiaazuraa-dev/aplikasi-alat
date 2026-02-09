import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final String nama;
  final String email;
  final String role;

  const EditUserPage({
    super.key,
    required this.userId,
    required this.nama,
    required this.email,
    required this.role,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRole;
  bool _isLoading = false;

  final Color navyColor = const Color(0xFF020B4F);
  final List<String> roleItems = ["admin", "petugas", "peminjam"];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.nama;
    _emailController.text = widget.email;
    _selectedRole =
        roleItems.contains(widget.role) ? widget.role : roleItems.first;
  }

  // ================= UPDATE DATA =================
  Future<void> _updateData() async {
    final name = _nameController.text.trim();

    if (name.isEmpty || _selectedRole == null) {
      _showSnackBar("Harap isi semua data!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('users')
          .update({'nama_lengkap': name, 'role': _selectedRole})
          .eq('id', widget.userId);

      if (mounted) {
        _showSnackBar("User berhasil diperbarui!");
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar("Gagal memperbarui user");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text("Edit User", style: TextStyle(color: Colors.white)),
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
                        enabled: false, // ⬅️ email tidak bisa diedit
                        decoration: _inputStyle("Email"),
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
                            onPressed: _updateData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navyColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Simpan",
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
