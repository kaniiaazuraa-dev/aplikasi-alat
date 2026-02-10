/// Model untuk alat yang dipilih user untuk dipinjam
class AlatPinjam {
  final AlatModel alat; // data alat dari inventaris
  int jumlah; // jumlah unit yang ingin dipinjam

  /// Constructor
  AlatPinjam({
    required this.alat,
    this.jumlah = 1, // default 1
  });
}

class AlatModel {
  late num stok;

  var status;

  late String nama;

  var idAlat;

  var imageUrl;

  var kategori;
}
