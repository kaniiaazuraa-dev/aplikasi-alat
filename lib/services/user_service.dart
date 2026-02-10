import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart';

class UserService {
  final _client = Supabase.instance.client;

  Future<List<UserModel>> fetchUsers() async {
    final data = await _client
        .from('users')
        .select('id, nama_lengkap, email, role')
        .order('nama_lengkap');

    return (data as List)
        .map((e) => UserModel.fromMap(e))
        .toList();
  }

  Future<void> deleteUser(String id) async {
    await _client.from('users').delete().eq('id', id);
  }
}
