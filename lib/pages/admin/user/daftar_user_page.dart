import 'package:flutter/material.dart';

import '../controllers/user_controller.dart';
import '../../../services/user_service.dart';
import 'widgets/user_card.dart';
import 'tambah_user_page.dart';
import 'edit_user_page.dart';
import '../../../models/user_models.dart';

class DaftarUserPage extends StatefulWidget {
  const DaftarUserPage({super.key});

  @override
  State<DaftarUserPage> createState() => _DaftarUserPageState();
}

class _DaftarUserPageState extends State<DaftarUserPage> {
  late final UserController controller;

  @override
  void initState() {
    super.initState();
    controller = UserController(UserService());
    controller.loadUsers();
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user "${user.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await controller.delete(user.id);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'User berhasil dihapus' : 'Gagal menghapus user',
                  ),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B4F),
        title: const Text('User', style: TextStyle(color: Colors.white)),
      ),

      // ➕ FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF020B4F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahUserPage(),
            ),
          );

          if (result == true) {
            controller.loadUsers();
          }
        },
      ),

      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            itemBuilder: (_, i) {
              final user = controller.users[i];

              return UserCard(
                user: user,

                // ✏️ EDIT
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditUserPage(
                        userId: user.id,
                        nama: user.nama,
                        email: user.email,
                        role: user.role,
                      ),
                    ),
                  );

                  if (result == true) {
                    controller.loadUsers();
                  }
                },

                // 🗑️ DELETE (pakai dialog)
                onDelete: () {
                  _confirmDelete(user);
                },
              );
            },
          );
        },
      ),
    );
  }
}
