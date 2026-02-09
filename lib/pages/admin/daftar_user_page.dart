import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/tambah_user_page.dart';
import '../admin/edit_user_page.dart';

class DaftarUserPage extends StatefulWidget {
  const DaftarUserPage({super.key});

  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= DELETE USER =================
  Future<void> _deleteUser(String userId) async {
    try {
      await supabase.from('users').delete().eq('id', userId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));

      fetchUsers(); // refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus user')));
    }
  }

  void _confirmDelete(String userId, String nama) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus User'),
            content: Text('Yakin ingin menghapus user "$nama"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(userId);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    try {
      final data = await supabase
          .from('users')
          .select('id, nama_lengkap, email, role')
          .order('nama_lengkap', ascending: true);

      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      debugPrint('ERROR FETCH USER: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B4F),
        title: const Text(
          'User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF020B4F),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahUserPage()),
          );

          if (result == true) {
            fetchUsers(); // refresh list user
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ================= BODY =================
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _userCard(users[index]);
                },
              ),
    );
  }

  // ================= USER CARD =================
  Widget _userCard(Map user) {
    final String nama = user['nama_lengkap'] ?? '-';
    final String email = user['email'] ?? '-';
    final String role = user['role'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF020B4F)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= AVATAR =================
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF020B4F)),
            ),
            alignment: Alignment.center,
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF020B4F),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ================= INFO =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text('Role : $role', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          // ================= BUTTON =================
          // ================= BUTTON =================
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _actionButton('Edit', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditUserPage(
                            userId: user['id'],
                            nama: user['nama_lengkap'],
                            email: user['email'],
                            role: user['role'],
                          ),
                    ),
                  ).then((value) {
                    if (value == true) {
                      fetchUsers(); // refresh setelah edit
                    }
                  });
                }),
                const SizedBox(width: 8),
                _actionButton('Hapus', () {
                  _confirmDelete(user['id'], user['nama_lengkap'] ?? '');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON KECIL =================
  Widget _actionButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: 56,
      height: 24,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFF020B4F)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Color(0xFF020B4F)),
        ),
      ),
    );
  }
}
