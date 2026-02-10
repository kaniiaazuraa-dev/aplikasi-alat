import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> editAlat({
  required String idAlat,
  required String nama,
  required String status,
  required int stok,
  required String? imageUrl,
}) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('alat')
      .update({
        'nama_alat': nama,
        'status': status,
        'stok': stok,
        'image_url': imageUrl,
      })
      .eq('id_alat', idAlat);
}
