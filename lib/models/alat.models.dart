class AlatModel {
  final String idAlat;
  final String namaAlat;
  final String kategori;
  final String kondisi;
  final String status;

  AlatModel({
    required this.idAlat,
    required this.namaAlat,
    required this.kategori,
    required this.kondisi,
    required this.status,
  });

  factory AlatModel.fromJson(Map<String, dynamic> json) {
    return AlatModel(
      idAlat: json['id_alat'] ?? '',
      namaAlat: json['nama_alat'] ?? '',
      kategori: json['kategori'] ?? '',
      kondisi: json['kondisi'] ?? '',
      status: json['status'] ?? 'Tersedia',
    );
  }
}
