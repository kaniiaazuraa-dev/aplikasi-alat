import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat.models.dart';

class AlatService {
  final _supabase = Supabase.instance.client;

  // Mengambil data secara Realtime
  Stream<List<AlatModel>> getAlatStream() {
    return _supabase
        .from('alat')
        .stream(primaryKey: ['id_alat'])
        .map((data) => data.map((json) => AlatModel.fromJson(json)).toList());
  }
}