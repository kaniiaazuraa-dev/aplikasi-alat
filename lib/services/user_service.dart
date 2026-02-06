import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, dynamic>?> cekPeminjam(String emailPeminjam) async {
  final response = await supabase
      .from('users')
      .select('id, email, role')
      .eq('email', emailPeminjam)
      .single();

  if (response == null) {
    print('Email tidak ditemukan');
    return null;
  }

  final role = response['role'];
  final idPeminjam = response['id'];

  if (role != 'peminjam') {
    print('Email ini bukan peminjam');
    return null;
  }

  print('Berhasil, id peminjam: $idPeminjam');
  return {'id': idPeminjam, 'email': emailPeminjam, 'role': role};
}
