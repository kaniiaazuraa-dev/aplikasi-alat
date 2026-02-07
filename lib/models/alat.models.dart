class AlatModel {
  final String idAlat;
  final String namaAlat;
  final String kategori;
  final int stok;          // ⬅️ TAMBAHAN
  final String status;
  final String? image_url;

  AlatModel({
    required this.idAlat,
    required this.namaAlat,
    required this.kategori,
    required this.stok,
    required this.status,
    this.image_url,
  });

  factory AlatModel.fromJson(Map<String, dynamic> json) {
    return AlatModel(
      idAlat: json['id_alat'] ?? '',
      namaAlat: json['nama_alat'] ?? '',
      kategori: json['kategori'] ?? '',
      stok: json['stok'] ?? 0,   // ⬅️ AMBIL DARI SUPABASE
      status: json['status'] ?? 'Tersedia',
      image_url: json['image_url'],
    );
  }
}
