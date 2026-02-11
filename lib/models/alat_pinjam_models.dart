import 'alat_models.dart';

class AlatPinjam {
  final Alat alat; // ✅ SAMAKAN
  int jumlah;

  AlatPinjam({
    required this.alat,
    this.jumlah = 1,
  });
}
