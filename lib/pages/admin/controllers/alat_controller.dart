import 'dart:io';
import 'package:aplikasi_alat/models/alat_models.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AlatController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Alat> daftarAlat = [];
  bool loading = false;

  Future<void> getAlat() async {
    loading = true;
    notifyListeners();

    try {
      final data = await _supabase.from('alat').select();
      daftarAlat = (data as List)
          .map((e) => Alat.fromMap(e))
          .toList();
    } catch (e) {
      debugPrint('Error getAlat: $e');
      daftarAlat = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> deleteAlat(String idAlat) async {
    try {
      await _supabase.from('alat').delete().eq('id_alat', idAlat);
      daftarAlat.removeWhere((a) => a.idAlat == idAlat);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete alat error: $e');
      return false;
    }
  }

  Future<bool> editAlat({
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

      final index = daftarAlat.indexWhere((a) => a.idAlat == idAlat);
      if (index != -1) {
        daftarAlat[index] = Alat(
          idAlat: idAlat,
          nama: nama,
          status: status,
          stok: stok,
          imageUrl: imageUrl,
          kategori: daftarAlat[index].kategori,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Edit alat error: $e');
      return false;
    }
  }

  Future<String> uploadImage(File file, String idAlat) async {
    final fileName = 'alat_$idAlat.jpg';

    await _supabase.storage
        .from('alat.bucket')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage
        .from('alat.bucket')
        .getPublicUrl(fileName);
  }
}
