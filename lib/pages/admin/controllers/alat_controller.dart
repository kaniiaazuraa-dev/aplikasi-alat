import 'dart:io';
import 'package:aplikasi_alat/models/alat_models.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AlatController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Alat> daftarAlat = [];
  bool loading = false;

  /// Ambil semua alat dari Supabase
  Future<void> getAlat() async {
    loading = true;
    notifyListeners();

    try {
      final response = await _supabase.from('alat').select(); // versi terbaru tidak pakai execute()
      final data = response as List<dynamic>; // pastikan data list
      daftarAlat = data.map((e) => Alat.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getAlat: $e");
      daftarAlat = [];
    }

    loading = false;
    notifyListeners();
  }

  /// Hapus alat berdasarkan id
  Future<bool> deleteAlat(String idAlat) async {
    try {
      final response = await _supabase.from('alat').delete().eq('id_alat', idAlat);
      if (response.error != null) {
        print("Supabase delete error: ${response.error!.message}");
        return false;
      }

      daftarAlat.removeWhere((a) => a.idAlat == idAlat);
      notifyListeners();
      return true;
    } catch (e) {
      print("Exception deleteAlat: $e");
      return false;
    }
  }

  /// Update alat
  Future<bool> editAlat({
    required String idAlat,
    required String nama,
    required String status,
    required int stok,
    required String imageUrl,
  }) async {
    try {
      final response = await _supabase.from('alat').update({
        'nama_alat': nama,
        'status': status,
        'stok': stok,
        'image_url': imageUrl,
      }).eq('id_alat', idAlat);

      if (response.error != null) {
        print("Supabase edit error: ${response.error!.message}");
        return false;
      }

      // Update di local list juga
      final index = daftarAlat.indexWhere((a) => a?.idAlat == idAlat);
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
      print("Exception editAlat: $e");
      return false;
    }
  }
  Future<String> uploadImage(File file, String idAlat) async {
  final fileName = 'alat_ $idAlat.jpg';

  await Supabase.instance.client.storage
      .from('alat.bucket')
      .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

  return Supabase.instance.client.storage
      .from('alat.bucket')
      .getPublicUrl(fileName);
}

}
