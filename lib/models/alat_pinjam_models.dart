

import 'package:aplikasi_alat/models/alat_models.dart';

/// Model untuk alat yang dipilih user untuk dipinjam
class AlatPinjam {
  final Alat alat; // data alat dari inventaris
  int jumlah;      // jumlah unit yang ingin dipinjam

  /// Constructor
  AlatPinjam({
    required this.alat,
    this.jumlah = 1, // default 1
  });
}
