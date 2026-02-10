import '../models/alat_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatService {
  final _supabase = Supabase.instance.client;

  /// Ambil semua data alat
  Future<List<Alat>> fetchAlat() async {
    try {
      final response = await _supabase.from('alat').select();
      final data = response as List<dynamic>;
      return data.map((e) => Alat.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetchAlat: $e");
      return [];
    }
  }

  /// Hapus alat berdasarkan id
  Future<void> deleteAlat(String idAlat) async {
    try {
      await _supabase.from('alat').delete().eq('id_alat', idAlat);
    } catch (e) {
      print("Error deleteAlat: $e");
      throw e;
    }
  }

  /// Update data alat
  Future<void> updateAlat({
    required String idAlat,
    required String nama,
    required String status,
    required int stok,
    required String imageUrl,
  }) async {
    try {
      await _supabase.from('alat').update({
        'nama_alat': nama,
        'status': status,
        'stok': stok,
        'image_url': imageUrl,
      }).eq('id_alat', idAlat);
    } catch (e) {
      print("Error updateAlat: $e");
      throw e;
    }
  }
}
