class Alat {
  final String idAlat;
  final String nama;
  final String status;
  final int stok;
  final String imageUrl;
  final String kategori;

  Alat({
    required this.idAlat,
    required this.nama,
    required this.status,
    required this.stok,
    required this.imageUrl,
    required this.kategori,
  });

  factory Alat.fromMap(Map<String, dynamic> map) {
    return Alat(
      idAlat: map['id_alat'] as String,
      nama: map['nama_alat'] as String,
      status: map['status'] as String,
      stok: map['stok'] as int,
      imageUrl: map['image_url'] as String,
      kategori: map['kategori'] ?? 'Semua',
    );
  }
}
